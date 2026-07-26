from pathlib import Path

import pandas as pd

project_root = Path(__file__).resolve().parent.parent
csv_path = project_root / "output" / "transaction_summary.csv"

if not csv_path.exists():
    raise FileNotFoundError(
        f"Transaction summary file was not found: {csv_path}"
    )

df = pd.read_csv(csv_path)

numeric_columns = [
    "transaction_value",
    "total_quantity",
    "distinct_products"
]

for column in numeric_columns:
    df[column] = pd.to_numeric(df[column], errors="coerce")

print("Rows:", len(df))
print("\nDescriptive Statistics:")
print(df[numeric_columns].describe().round(2))

transaction_values = df["transaction_value"].dropna()

q1 = transaction_values.quantile(0.25)
q3 = transaction_values.quantile(0.75)
iqr = q3 - q1

lower_bound = q1 - 1.5 * iqr
upper_bound = q3 + 1.5 * iqr

outliers = df[
    (df["transaction_value"] < lower_bound)
    | (df["transaction_value"] > upper_bound)
]

print("\nIQR Outlier Analysis:")
print("Q1:", round(q1, 2))
print("Q3:", round(q3, 2))
print("IQR:", round(iqr, 2))
print("Lower bound:", round(lower_bound, 2))
print("Upper bound:", round(upper_bound, 2))
print("Number of outliers:", len(outliers))
print("Outlier percentage:", round(len(outliers) / len(df) * 100, 2), "%")