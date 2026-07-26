from pathlib import Path
import pandas as pd


BASE_DIR = Path(__file__).resolve().parent.parent
DATA_DIR = BASE_DIR / "data"
OUTPUT_DIR = BASE_DIR / "output"
OUTPUT_DIR.mkdir(exist_ok=True)


def load_datasets():
    events = pd.read_csv(DATA_DIR / "retail_events.csv")
    stores = pd.read_csv(DATA_DIR / "stores.csv")
    products = pd.read_csv(DATA_DIR / "products.csv")
    promotions = pd.read_csv(DATA_DIR / "promotions.csv")
    malformed = pd.read_csv(DATA_DIR / "malformed_retail_events.csv")

    return events, stores, products, promotions, malformed


def explore_source_data(events, stores, products, promotions):
    parsed_timestamps = pd.to_datetime(
        events["event_timestamp"],
        errors="coerce"
    )

    print("=" * 65)
    print("PART A - SOURCE DATA EXPLORATION")
    print("=" * 65)

    print("\nDATASET SUMMARY")
    print("-" * 65)
    print(f"Retail events: {len(events)}")
    print(f"Unique transactions: {events['transaction_id'].nunique()}")
    print(f"Stores in retail events: {events['store_id'].nunique()}")
    print(f"Products in retail events: {events['product_id'].nunique()}")
    print(f"Stores in stores.csv: {len(stores)}")
    print(f"Products in products.csv: {len(products)}")
    print(f"Promotions in promotions.csv: {len(promotions)}")

    print("\nPRODUCT CATEGORIES")
    print("-" * 65)
    print(sorted(events["category"].dropna().unique()))

    print("\nSTORE REGIONS")
    print("-" * 65)
    print(sorted(events["store_region"].dropna().unique()))

    print("\nDATE RANGE")
    print("-" * 65)
    print("Start date:", parsed_timestamps.min())
    print("End date:", parsed_timestamps.max())

    print("\nFIRST FIVE RECORDS")
    print("-" * 65)
    print(events.head())

    print("\nDATA TYPES AND STRUCTURE")
    print("-" * 65)
    events.info()

    print("\nMISSING VALUES")
    print("-" * 65)
    print(events.isnull().sum())


def validate_normal_data(events, stores, products):
    valid_store_ids = set(stores["store_id"].astype(str))
    valid_product_ids = set(products["product_id"].astype(str))

    parsed_timestamps = pd.to_datetime(
        events["event_timestamp"],
        errors="coerce"
    )

    numeric_quantity = pd.to_numeric(
        events["quantity"],
        errors="coerce"
    )

    numeric_unit_price = pd.to_numeric(
        events["unit_price"],
        errors="coerce"
    )

    numeric_final_price = pd.to_numeric(
        events["final_price"],
        errors="coerce"
    )

    duplicate_event_ids = events["event_id"].duplicated().sum()
    invalid_timestamps = parsed_timestamps.isna().sum()

    invalid_quantities = (
        numeric_quantity.isna()
        | (numeric_quantity <= 0)
    ).sum()

    invalid_unit_prices = (
        numeric_unit_price.isna()
        | (numeric_unit_price < 0)
    ).sum()

    invalid_final_prices = (
        numeric_final_price.isna()
        | (numeric_final_price < 0)
    ).sum()

    unknown_stores = (
        ~events["store_id"].astype(str).isin(valid_store_ids)
    ).sum()

    unknown_products = (
        ~events["product_id"].astype(str).isin(valid_product_ids)
    ).sum()

    print("\n" + "=" * 65)
    print("PART B - NORMAL DATA VALIDATION")
    print("=" * 65)

    print("\nDATA VALIDATION SUMMARY")
    print("-" * 65)
    print(f"Total Events: {len(events)}")
    print(f"Unique Transactions: {events['transaction_id'].nunique()}")
    print(f"Duplicate Event IDs: {duplicate_event_ids}")
    print(f"Invalid Timestamps: {invalid_timestamps}")
    print(f"Invalid Quantities: {invalid_quantities}")
    print(f"Invalid Unit Prices: {invalid_unit_prices}")
    print(f"Invalid Final Prices: {invalid_final_prices}")
    print(f"Unknown Stores: {unknown_stores}")
    print(f"Unknown Products: {unknown_products}")


def validate_record(row, valid_stores, valid_products):
    errors = []

    required_fields = [
        "event_id",
        "transaction_id",
        "store_id",
        "product_id",
        "event_timestamp",
    ]

    for field in required_fields:
        value = row.get(field, "")

        if pd.isna(value) or str(value).strip() == "":
            errors.append(f"Missing required field: {field}")

    timestamp_value = row.get("event_timestamp", "")

    try:
        pd.to_datetime(timestamp_value, errors="raise")
    except Exception:
        errors.append("Invalid timestamp")

    quantity_value = row.get("quantity", "")

    try:
        quantity = float(quantity_value)

        if quantity <= 0:
            errors.append("Quantity must be positive")
    except (TypeError, ValueError):
        errors.append("Invalid quantity")

    unit_price_value = row.get("unit_price", "")

    try:
        unit_price = float(unit_price_value)

        if unit_price < 0:
            errors.append("Unit price cannot be negative")
    except (TypeError, ValueError):
        errors.append("Invalid unit price")

    final_price_value = row.get("final_price", "")

    try:
        final_price = float(final_price_value)

        if final_price < 0:
            errors.append("Final price cannot be negative")
    except (TypeError, ValueError):
        errors.append("Invalid final price")

    store_id = str(row.get("store_id", "")).strip()
    product_id = str(row.get("product_id", "")).strip()

    if store_id and store_id not in valid_stores:
        errors.append("Unknown store")

    if product_id and product_id not in valid_products:
        errors.append("Unknown product")

    return errors


def validate_malformed_data(malformed, stores, products):
    valid_store_ids = set(stores["store_id"].astype(str))
    valid_product_ids = set(products["product_id"].astype(str))

    rejected_records = []

    for _, row in malformed.iterrows():
        errors = validate_record(
            row=row,
            valid_stores=valid_store_ids,
            valid_products=valid_product_ids,
        )

        if errors:
            rejected_records.append(
                {
                    "event_id": row.get("event_id", ""),
                    "validation_status": "REJECTED",
                    "rejection_reason": "; ".join(errors),
                }
            )

    rejected_df = pd.DataFrame(
        rejected_records,
        columns=[
            "event_id",
            "validation_status",
            "rejection_reason",
        ],
    )

    output_path = OUTPUT_DIR / "rejected_records.csv"
    rejected_df.to_csv(output_path, index=False)

    print("\n" + "=" * 65)
    print("PART C - MALFORMED DATA VALIDATION")
    print("=" * 65)

    print(f"\nMalformed records processed: {len(malformed)}")
    print(f"Rejected records: {len(rejected_df)}")
    print(f"Output file: {output_path}")

    print("\nREJECTION DETAILS")
    print("-" * 65)

    if rejected_df.empty:
        print("No malformed records were rejected.")
    else:
        print(rejected_df.to_string(index=False))


def main():
    try:
        events, stores, products, promotions, malformed = load_datasets()

        explore_source_data(
            events=events,
            stores=stores,
            products=products,
            promotions=promotions,
        )

        validate_normal_data(
            events=events,
            stores=stores,
            products=products,
        )

        validate_malformed_data(
            malformed=malformed,
            stores=stores,
            products=products,
        )

        print("\n" + "=" * 65)
        print("TASK 2 COMPLETED SUCCESSFULLY")
        print("=" * 65)

    except FileNotFoundError as error:
        print(f"File not found: {error}")

    except KeyError as error:
        print(f"Missing required CSV column: {error}")

    except Exception as error:
        print(f"Unexpected error: {error}")


if __name__ == "__main__":
    main()