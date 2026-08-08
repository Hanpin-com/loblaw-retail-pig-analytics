# Loblaw Retail Pig Analytics

## Student Information

- **Name:** Han-Pin Hung
- **Student ID:** N01747642
- **Project:** Loblaw Retail Operations and Customer Shopping Analytics Platform
- **Technology:** Apache Pig, Hadoop HDFS, MapReduce, Docker

---

## 1. Project Overview

This project implements an Apache Pig ETL and analytical pipeline for synthetic Loblaw retail data.

The workflow processes raw retail transaction events stored in HDFS and performs:

- Data exploration
- Data cleaning
- Data transformation
- Store, product, and category aggregation
- Promotion analysis
- Business ranking
- Dataset joins and enrichment
- Processed data export

The main pipeline is:

```text
Raw CSV Files
     |
     v
    HDFS
     |
     v
 Apache Pig
     |
     +--> Explore
     +--> Clean
     +--> Transform
     +--> Aggregate
     +--> Promotion Analysis
     +--> Rank
     +--> Join / Enrich
     +--> Export
```

---

## 2. Dataset

The primary dataset is `retail_events.csv`.

Each retail event represents one purchased product within a transaction.

Reference datasets include:

```text
stores.csv
products.csv
promotions.csv
```

The raw datasets are stored in:

```text
/user/hanpin/loblaw-retail/raw/
```

Main raw files:

```text
retail_events.csv
stores.csv
products.csv
promotions.csv
malformed_retail_events.csv
data_dictionary.csv
```

The retail events dataset contains:

```text
38,143 valid retail event records
```

---

## 3. HDFS Structure

```text
/user/hanpin/loblaw-retail/
|
├── raw/
│   ├── retail_events.csv
│   ├── stores.csv
│   ├── products.csv
│   ├── promotions.csv
│   ├── malformed_retail_events.csv
│   └── data_dictionary.csv
│
├── processed/
│   ├── clean_retail_events
│   ├── transformed_retail_events
│   ├── aggregated_store_sales
│   ├── aggregated_product_sales
│   ├── promotion_analysis
│   └── joined_retail_dataset
│
├── analytics/
│   ├── aggregated_category_sales
│   ├── promotion_cogroup_summary
│   └── rankings/
│       ├── top_10_stores
│       ├── top_10_products
│       ├── bottom_10_products
│       ├── highest_discounts
│       └── highest_sales_categories
│
└── exports/
    ├── clean_retail_events
    ├── transformed_retail_events
    ├── aggregated_store_sales
    ├── aggregated_product_sales
    ├── promotion_analysis
    └── joined_retail_dataset
```

---

## 4. Pig Scripts

```text
pig/
├── explore_retail_events.pig
├── clean_retail_events.pig
├── transform_retail_events.pig
├── aggregate_store_sales.pig
├── aggregate_product_sales.pig
├── promotion_analysis.pig
├── ranking_analysis.pig
├── join_retail_data.pig
└── export_results.pig
```

---

# 5. Task Summary

## Task 9 – Explore Retail Events

Script:

```text
pig/explore_retail_events.pig
```

Purpose:

- Load the retail dataset from HDFS
- Define the Pig schema
- Inspect sample records
- Examine the relation structure

Pig operations demonstrated include:

```text
LOAD
DESCRIBE
ILLUSTRATE
LIMIT
DUMP
```

---

## Task 10 – Clean Retail Events

Script:

```text
pig/clean_retail_events.pig
```

Purpose:

- Remove the CSV header
- Validate mandatory identifiers
- Validate timestamps
- Validate numeric fields
- Convert fields to appropriate data types
- Remove invalid values

Output:

```text
/user/hanpin/loblaw-retail/processed/clean_retail_events
```

Result:

```text
38,143 cleaned records
```

---

## Task 11 – Transform Retail Events

Script:

```text
pig/transform_retail_events.pig
```

Derived attributes include:

```text
Hour of Day
Day of Week
Month
Weekend Indicator
Net Sales
Discount Percentage
Promotion Status
```

Example transformation:

```text
event_timestamp -> hour_of_day / day_of_week / month
```

Net sales is calculated from the retail event values.

Output:

```text
/user/hanpin/loblaw-retail/processed/transformed_retail_events
```

Result:

```text
38,143 transformed records
```

---

## Task 12 – Aggregate Retail Data

Scripts:

```text
pig/aggregate_store_sales.pig
pig/aggregate_product_sales.pig
```

### Store Aggregation

Metrics include:

- Total sales
- Average sales
- Transaction count
- Quantity sold
- Maximum event sales
- Minimum event sales

Output:

```text
/user/hanpin/loblaw-retail/processed/aggregated_store_sales
```

Result:

```text
12 stores
```

### Product Aggregation

Metrics include:

- Total quantity sold
- Total revenue
- Average selling price
- Event count
- Maximum selling price
- Minimum selling price

Output:

```text
/user/hanpin/loblaw-retail/processed/aggregated_product_sales
```

Result:

```text
45 products
```

### Category Aggregation

Metrics include:

- Total sales
- Quantity sold
- Average discount
- Average discount percentage
- Maximum discount
- Minimum discount

Output:

```text
/user/hanpin/loblaw-retail/analytics/aggregated_category_sales
```

Result:

```text
8 categories
```

Pig operators demonstrated include:

```text
GROUP
COUNT
SUM
AVG
MAX
MIN
```

---

## Task 13 – Analyze Promotional Activity

Script:

```text
pig/promotion_analysis.pig
```

The analysis compares:

```text
Promotional
vs.
Non-Promotional
```

Metrics include:

- Total sales
- Quantity sold
- Average selling price
- Average discount
- Event count

Results:

```text
Promotional:
Events = 1,106
Total Sales = 17,410.39
Average Selling Price = 12.53
Average Discount = 3.21

Non-Promotional:
Events = 37,037
Total Sales = 522,320.56
Average Selling Price = 9.14
Average Discount = 0.00
```

The dataset contains substantially fewer promotional events than non-promotional events. Promotional events show different purchasing patterns, including a higher average selling price, but the observational data does not establish that promotions caused these differences.

Output:

```text
/user/hanpin/loblaw-retail/processed/promotion_analysis
```

---

## Task 14 – Sort and Rank Business Results

Script:

```text
pig/ranking_analysis.pig
```

Rankings produced:

```text
Top 10 Stores
Top 10 Products
Bottom 10 Products
Highest Discounts
Highest Sales Categories
```

Required Pig operators:

```text
ORDER
LIMIT
```

Result counts:

```text
top_10_stores              = 10
top_10_products            = 10
bottom_10_products         = 10
highest_discounts          = 10
highest_sales_categories   = 8
```

Only eight sales categories exist in the dataset, so the highest-sales-category result contains eight records even though `LIMIT 10` is used.

### Ranking Implementation Note

The Docker environment uses:

```text
Apache Pig 0.17.0
Hadoop 3.5.0
```

Global `ORDER BY` produced a MapReduce plan deserialization error in this environment.

The ranking logic therefore uses:

```text
GROUP ALL
   |
   v
Nested ORDER
   |
   v
LIMIT
```

This preserves the required `ORDER` and `LIMIT` operations while successfully producing the ranking outputs.

---

## Task 15 – Join Retail Datasets

Script:

```text
pig/join_retail_data.pig
```

The transformed retail events are enriched using:

```text
stores.csv
products.csv
promotions.csv
```

Join flow:

```text
Transformed Retail Events
        |
        +--> LEFT JOIN Stores
        |
        +--> LEFT JOIN Products
        |
        +--> LEFT JOIN Promotions
        |
        v
Enriched Retail Dataset
```

`LEFT OUTER JOIN` is used so that valid retail events without promotions are preserved.

The enriched dataset includes information such as:

- Store reference information
- Product catalogue information
- Base unit price
- Promotion name
- Promotion dates
- Promotion discount rate

Required Pig operators demonstrated:

```text
JOIN
COGROUP
```

The COGROUP analysis compares promotional retail events with the promotion reference dataset.

Outputs:

```text
/user/hanpin/loblaw-retail/processed/joined_retail_dataset

/user/hanpin/loblaw-retail/analytics/promotion_cogroup_summary
```

Results:

```text
Joined retail dataset       = 38,143 records
Promotion COGROUP summary   = 8 records
```

The joined dataset retains the complete transformed retail-event record count.

---

## Task 16 – Export Processed Data

Script:

```text
pig/export_results.pig
```

Required Pig operations:

```text
STORE
PigStorage()
```

The completed datasets are exported from `/processed/` to `/exports/`.

Exported datasets:

```text
clean_retail_events
transformed_retail_events
aggregated_store_sales
aggregated_product_sales
promotion_analysis
joined_retail_dataset
```

Export validation:

```text
Dataset                      Processed   Exported
-------------------------------------------------
clean_retail_events             38143      38143
transformed_retail_events       38143      38143
aggregated_store_sales             12         12
aggregated_product_sales           45         45
promotion_analysis                  2          2
joined_retail_dataset           38143      38143
```

All processed and exported record counts match.

---

# 6. Screenshots

Evidence for each task is stored under:

```text
screenshots/pig/
```

Structure:

```text
screenshots/pig/
|
├── task09_explore/
│   ├── task09_01_schema.png
│   ├── task09_02_illustrate.png
│   └── task09_03_sample_records.png
│
├── task10_clean/
│   ├── task10_01_clean_execution.png
│   └── task10_02_hdfs_clean_output.png
│
├── task11_transform/
│   ├── task11_01_transformed_sample.png
│   └── task11_02_hdfs_transformed_output.png
│
├── task12_aggregate/
│   ├── task12_01_store_aggregation.png
│   ├── task12_02_product_category_aggregation.png
│   └── task12_03_hdfs_aggregated_outputs.png
│
├── task13_promotion/
│   ├── task13_01_promotion_comparison.png
│   └── task13_02_hdfs_promotion_output.png
│
├── task14_ranking/
│   ├── task14_01_top_stores_products.png
│   ├── task14_02_bottom_products_discounts.png
│   └── task14_03_categories_ranking_counts.png
│
├── task15_join/
│   ├── task15_01_joined_dataset_sample.png
│   └── task15_02_join_cogroup_hdfs.png
│
└── task16_export/
    ├── task16_01_export_success.png
    └── task16_02_export_record_counts.png
```

---

# 7. How to Run

## Prerequisites

The Big Data Docker environment must be running.

Check the containers:

```bash
docker compose ps
```

The Pig container should be available as:

```text
pig
```

Check Pig:

```bash
docker exec pig pig -version
```

---

## Copy a Pig Script into the Container

Example:

```bash
docker cp \
pig/clean_retail_events.pig \
pig:/tmp/clean_retail_events.pig
```

---

## Execute a Pig Script

Example:

```bash
docker exec pig \
pig \
-Dpig.tmpfilecompression=false \
-x mapreduce \
/tmp/clean_retail_events.pig
```

The project uses:

```text
-Dpig.tmpfilecompression=false
```

because the Pig container enables temporary-file compression without a configured compression codec.

---

## Example: Task 15

```bash
docker cp \
pig/join_retail_data.pig \
pig:/tmp/join_retail_data.pig
```

Run:

```bash
docker exec pig \
pig \
-Dpig.tmpfilecompression=false \
-Dopt.multiquery=false \
-x mapreduce \
/tmp/join_retail_data.pig
```

---

## Example: Task 16

```bash
docker cp \
pig/export_results.pig \
pig:/tmp/export_results.pig
```

Run:

```bash
docker exec pig \
pig \
-Dpig.tmpfilecompression=false \
-Dopt.multiquery=false \
-x mapreduce \
/tmp/export_results.pig
```

---

# 8. Verify HDFS Outputs

List the processed datasets:

```bash
docker exec pig \
hdfs dfs -ls \
/user/hanpin/loblaw-retail/processed
```

List analytical outputs:

```bash
docker exec pig \
hdfs dfs -ls -R \
/user/hanpin/loblaw-retail/analytics
```

List exported datasets:

```bash
docker exec pig \
hdfs dfs -ls \
/user/hanpin/loblaw-retail/exports
```

Check a record count:

```bash
docker exec pig sh -lc \
"hdfs dfs -cat /user/hanpin/loblaw-retail/processed/clean_retail_events/part-* | wc -l"
```

Expected result:

```text
38143
```

---

# 9. Environment Notes

Environment used:

```text
Apache Pig 0.17.0
Hadoop 3.5.0
Docker
HDFS
MapReduce
```

The following warning may appear:

```text
WARN util.NativeCodeLoader:
Unable to load native-hadoop library for your platform...
using builtin-java classes where applicable
```

This warning does not prevent the Pig jobs from completing successfully in the project environment.

---

# 10. Final Results

The Apache Pig pipeline successfully completed the full retail-data preparation workflow:

```text
Raw Retail Data
      |
      v
Exploration
      |
      v
Cleaning
      |
      v
Transformation
      |
      v
Aggregation
      |
      v
Promotion Analysis
      |
      v
Business Ranking
      |
      v
Dataset Enrichment
      |
      v
Processed Data Export
```

Final validation confirms:

```text
Clean records              : 38,143
Transformed records        : 38,143
Stores aggregated          : 12
Products aggregated        : 45
Categories aggregated      : 8
Promotion groups           : 2
Joined retail records      : 38,143
Exported joined records    : 38,143
```

The final joined dataset preserves all valid transformed retail events, and all exported datasets match their corresponding processed record counts.