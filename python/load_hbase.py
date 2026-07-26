from datetime import datetime
from pathlib import Path
from typing import Any, Mapping
import csv
import logging

import happybase
import pandas as pd


# ---------------------------------------------------------
# Project configuration
# ---------------------------------------------------------
BASE_DIR = Path(__file__).resolve().parent.parent
DATA_DIR = BASE_DIR / "data"
OUTPUT_DIR = BASE_DIR / "output"

INPUT_FILE = DATA_DIR / "retail_events.csv"
STORES_FILE = DATA_DIR / "stores.csv"
PRODUCTS_FILE = DATA_DIR / "products.csv"
ERROR_LOG_FILE = OUTPUT_DIR / "load_hbase_errors.log"

HBASE_HOST = "localhost"
HBASE_PORT = 9090
TABLE_NAME = "retail_events"
BATCH_SIZE = 1000

MAX_LONG = 9223372036854775807


# ---------------------------------------------------------
# Logging
# ---------------------------------------------------------
def configure_logging() -> None:
    OUTPUT_DIR.mkdir(exist_ok=True)

    logging.basicConfig(
        filename=ERROR_LOG_FILE,
        level=logging.ERROR,
        format="%(asctime)s | %(levelname)s | %(message)s",
        filemode="w",
    )


# ---------------------------------------------------------
# Helper functions
# ---------------------------------------------------------
def clean_value(value: Any) -> str:
    """Convert CSV values to clean strings."""

    if value is None or pd.isna(value):
        return ""

    return str(value).strip()


def encode(value: Any) -> bytes:
    """Encode a value for HBase storage."""

    return clean_value(value).encode("utf-8")


def create_row_key(row: Mapping[str, Any]) -> str:
    """
    Create an HBase row key:

    store_id#reverse_timestamp#event_id
    """

    required_fields = [
        "store_id",
        "event_timestamp",
        "event_id",
    ]

    for field in required_fields:
        if not clean_value(row.get(field)):
            raise ValueError(f"Missing required field: {field}")

    try:
        timestamp = datetime.strptime(
            clean_value(row["event_timestamp"]),
            "%Y-%m-%d %H:%M:%S",
        )
    except ValueError as error:
        raise ValueError(
            "event_timestamp must use YYYY-MM-DD HH:MM:SS format"
        ) from error

    timestamp_ms = int(timestamp.timestamp() * 1000)
    reverse_timestamp = MAX_LONG - timestamp_ms

    return (
        f"{clean_value(row['store_id'])}"
        f"#{reverse_timestamp}"
        f"#{clean_value(row['event_id'])}"
    )


def validate_record(
    row: Mapping[str, Any],
    valid_stores: set[str],
    valid_products: set[str],
) -> list[str]:
    """Validate one retail event before inserting it."""

    errors: list[str] = []

    required_fields = [
        "event_id",
        "transaction_id",
        "store_id",
        "product_id",
        "event_timestamp",
    ]

    for field in required_fields:
        if not clean_value(row.get(field)):
            errors.append(f"Missing required field: {field}")

    timestamp_value = clean_value(row.get("event_timestamp"))

    if timestamp_value:
        try:
            datetime.strptime(
                timestamp_value,
                "%Y-%m-%d %H:%M:%S",
            )
        except ValueError:
            errors.append("Invalid timestamp")

    try:
        quantity = float(clean_value(row.get("quantity")))

        if quantity <= 0:
            errors.append("Quantity must be positive")
    except ValueError:
        errors.append("Invalid quantity")

    numeric_fields = [
        ("unit_price", "Unit price"),
        ("discount_amount", "Discount amount"),
        ("final_price", "Final price"),
    ]

    for field, label in numeric_fields:
        try:
            value = float(clean_value(row.get(field)))

            if value < 0:
                errors.append(f"{label} cannot be negative")
        except ValueError:
            errors.append(f"Invalid {label.lower()}")

    store_id = clean_value(row.get("store_id"))
    product_id = clean_value(row.get("product_id"))

    if store_id and store_id not in valid_stores:
        errors.append("Unknown store")

    if product_id and product_id not in valid_products:
        errors.append("Unknown product")

    return errors


def build_hbase_record(
    row: Mapping[str, Any],
) -> dict[bytes, bytes]:
    """Map one CSV record to HBase column families."""

    return {
        # Transaction column family
        b"transaction:transaction_id":
            encode(row.get("transaction_id")),
        b"transaction:event_timestamp":
            encode(row.get("event_timestamp")),
        b"transaction:payment_type":
            encode(row.get("payment_type")),
        b"transaction:loyalty_flag":
            encode(row.get("loyalty_flag")),

        # Product column family
        b"product:product_id":
            encode(row.get("product_id")),
        b"product:product_name":
            encode(row.get("product_name")),
        b"product:category":
            encode(row.get("category")),

        # Store column family
        b"store:store_id":
            encode(row.get("store_id")),
        b"store:city":
            encode(row.get("store_city")),
        b"store:province":
            encode(row.get("province")),
        b"store:region":
            encode(row.get("store_region")),

        # Sales column family
        b"sales:quantity":
            encode(row.get("quantity")),
        b"sales:unit_price":
            encode(row.get("unit_price")),
        b"sales:discount_amount":
            encode(row.get("discount_amount")),
        b"sales:final_price":
            encode(row.get("final_price")),
        b"sales:promotion_flag":
            encode(row.get("promotion_flag")),
        b"sales:promotion_id":
            encode(row.get("promotion_id")),
    }


# ---------------------------------------------------------
# Reference-data loading
# ---------------------------------------------------------
def load_reference_ids() -> tuple[set[str], set[str]]:
    stores = pd.read_csv(STORES_FILE, dtype=str)
    products = pd.read_csv(PRODUCTS_FILE, dtype=str)

    valid_stores = set(
        stores["store_id"].dropna().astype(str).str.strip()
    )

    valid_products = set(
        products["product_id"].dropna().astype(str).str.strip()
    )

    return valid_stores, valid_products


# ---------------------------------------------------------
# HBase ingestion
# ---------------------------------------------------------
def load_retail_events() -> None:
    configure_logging()

    valid_stores, valid_products = load_reference_ids()

    processed = 0
    inserted = 0
    rejected = 0
    error_count = 0

    connection = happybase.Connection(
        host=HBASE_HOST,
        port=HBASE_PORT,
        timeout=30000,
        autoconnect=False,
    )

    print("=" * 68)
    print("MASTER TASK 5 - PYTHON-TO-HBASE DATA INGESTION")
    print("=" * 68)
    print(f"Input file: {INPUT_FILE}")
    print(f"HBase table: {TABLE_NAME}")
    print(f"Batch size: {BATCH_SIZE}")

    try:
        print("\nOpening HBase Thrift connection...")
        connection.open()

        available_tables = [
            table.decode("utf-8")
            if isinstance(table, bytes)
            else str(table)
            for table in connection.tables()
        ]

        if TABLE_NAME not in available_tables:
            raise RuntimeError(
                f"HBase table does not exist: {TABLE_NAME}"
            )

        print("Connected successfully.")
        print(f"Required table found: {TABLE_NAME}")
        print("\nStarting CSV ingestion...")

        table = connection.table(TABLE_NAME)

        with INPUT_FILE.open(
            mode="r",
            encoding="utf-8-sig",
            newline="",
        ) as csv_file:

            reader = csv.DictReader(csv_file)

            with table.batch(
                batch_size=BATCH_SIZE,
            ) as batch:

                for row_number, row in enumerate(
                    reader,
                    start=2,
                ):
                    processed += 1

                    try:
                        validation_errors = validate_record(
                            row=row,
                            valid_stores=valid_stores,
                            valid_products=valid_products,
                        )

                        if validation_errors:
                            rejected += 1

                            logging.error(
                                "Row %s | Event %s | %s",
                                row_number,
                                clean_value(row.get("event_id")),
                                "; ".join(validation_errors),
                            )

                            continue

                        row_key = create_row_key(row)
                        hbase_record = build_hbase_record(row)

                        batch.put(
                            row_key.encode("utf-8"),
                            hbase_record,
                        )

                        inserted += 1

                        if processed % 5000 == 0:
                            print(
                                f"Processed {processed:,} records..."
                            )

                    except Exception as record_error:
                        rejected += 1
                        error_count += 1

                        logging.exception(
                            "Row %s | Event %s | %s",
                            row_number,
                            clean_value(row.get("event_id")),
                            record_error,
                        )

        print("\nCSV ingestion completed.")

    except (
        FileNotFoundError,
        OSError,
        RuntimeError,
        happybase.HBaseException,
    ) as connection_error:
        error_count += 1
        logging.exception(
            "Ingestion process failed: %s",
            connection_error,
        )

        print(f"\nERROR: {connection_error}")
        raise SystemExit(1) from connection_error

    finally:
        connection.close()
        print("HBase connection closed.")

    print("\n" + "=" * 68)
    print("INGESTION SUMMARY")
    print("=" * 68)
    print(f"Records processed: {processed:,}")
    print(f"Records inserted: {inserted:,}")
    print(f"Records rejected: {rejected:,}")
    print(f"Errors: {error_count:,}")
    print(f"Error log: {ERROR_LOG_FILE}")
    print("=" * 68)

    if (
        processed == 38143
        and inserted == 38143
        and rejected == 0
        and error_count == 0
    ):
        print("MASTER TASK 5 COMPLETED SUCCESSFULLY")
    else:
        print(
            "INGESTION COMPLETED, BUT THE RESULTS REQUIRE REVIEW"
        )


if __name__ == "__main__":
    load_retail_events()