# Loblaw HBase–Hive Retail Analytics

## Student Information

- **Name:** Han-Pin, Hung
- **Student ID:** N01747642
- **Course:** Big Data – CPAN 361 – ONA
- **Project:** HBase–Hive Retail Analytics Assignment
- **Overall Status:** 12 / 12 Master Tasks Completed

---

## Project Overview

This project implements an end-to-end big-data retail analytics workflow using Apache HBase, Apache Hive, Python, Pandas, Docker, and Apache Zeppelin.

The source retail data was first validated using Python. Valid retail event records were then loaded into HBase through a Python ingestion program. Hive was integrated with HBase through an external table to support business analytics across stores, regions, products, categories, payment methods, loyalty status, promotions, transaction dates, and transaction times.

Python was also used to perform transaction-level statistical analysis, including descriptive statistics, transaction-value distribution analysis, and IQR-based outlier detection.

The project concludes with integrated business findings and recommendations based on both HiveQL and Python results.

---

## Technologies

- Apache HBase
- Apache Hive
- Apache Zeppelin
- Python
- Pandas
- Docker
- Docker Compose
- Git
- GitHub

---

## Dataset Summary

The project uses retail transaction data containing:

- **38,143 retail event records**
- **12,725 unique transactions**
- Store information
- Regional information
- Product information
- Product categories
- Transaction quantities
- Transaction values
- Payment methods
- Loyalty indicators
- Promotion indicators
- Transaction dates
- Transaction times

The source and supporting CSV files are stored in the `data/` directory.

---

## Project Objectives

The main objectives of this project were to:

1. Validate the source retail dataset
2. Detect and document malformed records
3. Design an HBase data model
4. Design a unique and traceable HBase row key
5. Create the HBase retail-events table
6. Establish a Python-to-HBase connection
7. Load valid retail records into HBase
8. Validate the HBase records
9. Integrate Hive with HBase
10. Perform core and advanced HiveQL analytics
11. Perform Python statistical analytics
12. Produce integrated findings and business recommendations

---

## Project Workflow

```text
Source CSV Files
       |
       v
Python Data Validation
       |
       v
Malformed Record Handling
       |
       v
HBase Data Model and Row Key
       |
       v
Python-to-HBase Connection
       |
       v
HBase Data Ingestion
       |
       v
HBase Validation
       |
       v
Hive–HBase External Table
       |
       v
Core and Advanced HiveQL Analytics
       |
       v
Transaction Summary Export
       |
       v
Python Statistical Analytics
       |
       v
Integrated Findings and Recommendations
```

---

# Master Task Completion Summary

## Master Task 1 — Environment Setup

The Docker-based big-data environment was started and validated.

The required services included:

- Apache HBase
- Apache Hive
- Apache Zeppelin
- Hadoop supporting services
- Docker networking and containers

Apache Zeppelin was accessed through:

```text
http://localhost:8888
```

**Status:** Completed

---

## Master Task 2 — Source Data Validation

The source dataset and supporting CSV files were reviewed before ingestion.

The validation included:

- File availability
- Column structure
- Required fields
- Numeric fields
- Date and time formats
- Product references
- Store references
- Missing values
- Invalid records

The main retail dataset contained:

```text
38,143 retail event records
```

**Status:** Completed

---

## Master Task 3 — HBase Data Model and Row-Key Design

An HBase data model was designed for retail-event storage.

The design included:

- HBase table structure
- Column families
- Retail-event attributes
- Transaction information
- Store and product information
- Promotion and loyalty information

A unique row-key design was used to identify each stored retail event and support transaction-level record retrieval.

**Status:** Completed

---

## Master Task 4 — HBase Table and Python Connection

The HBase retail-events table was created using the HBase shell script:

```text
hbase/create_table.hbase
```

Python connectivity to HBase was established and tested successfully.

The main Python ingestion file is:

```text
python/load_hbase.py
```

**Status:** Completed

---

## Master Task 5 — HBase Data Ingestion

Validated retail-event records were loaded into HBase using Python.

### Ingestion Results

- **Inserted records:** 38,143
- **Rejected records during ingestion:** 0
- **Ingestion errors:** 0

The successful load confirmed that all valid source records were inserted into HBase.

**Status:** Completed

---

## Master Task 6 — HBase Validation

The HBase table and stored records were validated using HBase shell commands.

The validation included:

- Table existence
- Table structure
- Column families
- Record count
- Sample rows
- Selected transaction records
- Stored column values

The validation commands are stored in:

```text
hbase/validation_commands.hbase
```

**Status:** Completed

---

## Master Task 7 — Hive–HBase Integration

A Hive external table named:

```text
retail_events_hive
```

was connected to the HBase retail-events table.

The Hive external-table definition is stored in:

```text
hive/create_external_table.hql
```

### Integration Validation

- **Retail event records:** 38,143
- **Distinct transactions:** 12,725

An integration test record was inserted into HBase, queried successfully through Hive, and then removed.

After cleanup, the final retail-event count returned to:

```text
38,143
```

**Status:** Completed

---

## Master Task 8 — Core HiveQL Analytics

Core HiveQL analysis was completed using the integrated Hive–HBase data.

The analysis included:

- Dataset validation
- Revenue by store
- Sales by category
- Payment-method analysis
- Loyalty analysis
- Promotion impact
- Top-product analysis

The queries are stored in:

```text
hive/analytics.hql
```

**Status:** Completed

---

## Master Task 9 — Advanced HiveQL Analytics

Advanced HiveQL analysis was completed to provide deeper business insights.

The analysis included:

- Typed analytical view
- Transaction-level summary
- Regional performance
- Hourly transaction patterns
- Day-of-week performance
- Category revenue contribution
- Promotion performance by category
- Store ranking
- Store revenue deviation

The transaction-level analytical result contained:

```text
12,725 transaction records
```

All core and advanced analytical queries were retained in:

```text
hive/analytics.hql
```

A separate advanced analytics SQL file was not required.

**Status:** Completed

---

## Master Task 10 — Python Statistical Analytics

The Hive transaction summary was exported to:

```text
output/transaction_summary.csv
```

Python and Pandas were used to analyze:

```text
12,725 transaction-level records
```

The Python analysis included:

- Data loading
- Column validation
- Numeric data-type validation
- Missing-value validation
- Descriptive statistics
- Mean and median comparison
- Standard deviation
- Minimum and maximum values
- Quartile analysis
- Transaction-value frequency distribution
- IQR-based outlier detection
- Review of the highest-value transactions

No missing values were found in:

- `transaction_value`
- `total_quantity`
- `distinct_products`

### IQR Outlier Results

- **Q1:** $21.87
- **Q3:** $57.85
- **IQR:** $35.98
- **Lower bound:** -$32.10
- **Upper bound:** $111.82
- **Potential outliers:** 216
- **Outlier percentage:** 1.70%

Because the dataset did not contain negative transaction values, the identified potential outliers were transactions above:

```text
$111.82
```

The potential outliers were retained because they may represent legitimate large purchases rather than data errors.

The reusable statistical-analysis script is stored in:

```text
python/analytics.py
```

**Status:** Completed

---

## Master Task 11 — Integrated Investigation, Findings and Recommendations

HiveQL business analytics and Python statistical analytics were combined into an integrated investigation.

The investigation covered:

- Store performance
- Regional performance
- Transaction-hour performance
- Day-of-week performance
- Category performance
- Promotion performance
- Transaction-value distribution
- Potential transaction outliers

### Main Findings

- **Highest-performing store:** ST-CAL-001
- **ST-CAL-001 revenue:** $55,573.77
- **ST-CAL-001 transactions:** 1,167
- **ST-CAL-001 average transaction value:** $47.62
- **Revenue above the store average:** 23.56%

- **Average revenue per store:** $44,977.58

- **Largest negative store deviation:** ST-KIT-001
- **Deviation amount:** -$7,102.69
- **Percentage deviation:** -15.79%

- **Highest total regional revenue:** Central
- **Highest average revenue per store:** Western
- **Western average revenue per store:** $50,941.11

- **Peak transaction hour:** 18:00
- **Transactions at 18:00:** 1,809
- **Revenue at 18:00:** $76,526.71
- **Average transaction value at 18:00:** $42.30

- **Highest transaction-count day:** Sunday
- **Sunday transactions:** 2,106
- **Sunday revenue:** $89,770.68

- **Highest daily revenue:** Saturday
- **Saturday revenue:** $90,570.71

- **Highest promotional revenue category:** Grocery
- **Grocery promotional revenue:** $3,962.47
- **Promotional share of Grocery revenue:** 2.31%

- **Potential transaction outliers:** 216
- **Outlier percentage:** 1.70%

### Main Recommendations

1. Study the product mix and operating practices of ST-CAL-001.
2. Investigate the causes of weaker performance at ST-KIT-001.
3. Strengthen staffing and inventory availability during weekends and around 18:00.
4. Evaluate promotions using revenue, margin, transaction count, and customer response.
5. Investigate high-value transactions by store, region, category, loyalty status, and payment method.
6. Use both aggregate business metrics and transaction-level statistical measures in future reporting.

The final analysis report is stored in:

```text
docs/Final_Analysis_Report.md
```

**Status:** Completed

---

## Master Task 12 — Final Documentation, Export and Submission Preparation

The completed project files were organized for final review and GitHub submission.

The final deliverables include:

- Source datasets
- Data-validation script
- HBase table-creation script
- HBase validation commands
- Python HBase loader
- Hive external-table script
- HiveQL analytics
- Python statistical-analysis script
- Rejected-record output
- Transaction-summary output
- Apache Zeppelin notebook export
- Final analysis report
- Organized execution screenshots
- Complete project README

The Zeppelin notebook was exported as:

```text
zeppelin/Loblaw_HBase_Hive_Analytics.zpln
```

**Status:** Completed

---

## Overall Completion Status

| Component | Result |
|---|---:|
| Retail event records validated | 38,143 |
| Retail event records inserted | 38,143 |
| Unique transactions analyzed | 12,725 |
| Ingestion errors | 0 |
| Potential transaction outliers | 216 |
| Outlier percentage | 1.70% |
| Master Tasks completed | 12 / 12 |
| Final project status | Complete |

---

# Project Structure

```text
loblaw-hbase-hive-analytics/
├── data/
│   ├── data_dictionary.csv
│   ├── malformed_retail_events.csv
│   ├── products.csv
│   ├── promotions.csv
│   ├── retail_events.csv
│   └── stores.csv
│
├── docs/
│   └── Final_Analysis_Report.md
│
├── hbase/
│   ├── create_table.hbase
│   └── validation_commands.hbase
│
├── hive/
│   ├── analytics.hql
│   └── create_external_table.hql
│
├── output/
│   ├── rejected_records.csv
│   └── transaction_summary.csv
│
├── python/
│   ├── analytics.py
│   ├── load_hbase.py
│   └── validate_data.py
│
├── screenshots/
│   ├── advanced_analytics/
│   ├── analytics/
│   ├── final/
│   ├── investigation/
│   ├── python/
│   ├── task01_environment/
│   ├── task02_source_data/
│   ├── task03_validation/
│   ├── task04_malformed_data/
│   ├── task05_hbase_model/
│   ├── task06_row_key/
│   ├── task07_hbase_table/
│   ├── task08_hbase_connection/
│   ├── task09_ingestion/
│   ├── task10_hbase_validation/
│   ├── task11_hive_integration/
│   └── task12_integration_test/
│
├── zeppelin/
│   └── Loblaw_HBase_Hive_Analytics.zpln
│
├── README.md
└── .gitignore
```

---

# Main Project Files

## Data Validation

```text
python/validate_data.py
```

Validates source records and identifies malformed data.

## HBase Table Creation

```text
hbase/create_table.hbase
```

Creates the HBase retail-events table and required column families.

## HBase Validation

```text
hbase/validation_commands.hbase
```

Contains commands for validating the HBase table and stored records.

## HBase Data Loader

```text
python/load_hbase.py
```

Connects to HBase and loads the validated retail-event records.

## Hive External Table

```text
hive/create_external_table.hql
```

Creates the Hive external table connected to HBase.

## HiveQL Analytics

```text
hive/analytics.hql
```

Contains the core and advanced HiveQL analytical queries.

## Python Statistical Analytics

```text
python/analytics.py
```

Loads the exported transaction summary and performs descriptive statistics and IQR outlier analysis.

## Transaction Summary

```text
output/transaction_summary.csv
```

Contains the transaction-level data exported from Hive for Python analysis.

## Final Analysis Report

```text
docs/Final_Analysis_Report.md
```

Contains the integrated findings and business recommendations.

## Zeppelin Notebook

```text
zeppelin/Loblaw_HBase_Hive_Analytics.zpln
```

Contains the completed Zeppelin notebook and execution results.

---

# Running the Project

## Prerequisites

The project requires:

- Docker Desktop
- Docker Compose
- Python 3
- Pandas
- Apache HBase environment
- Apache Hive environment
- Apache Zeppelin environment

---

## Start the Docker Environment

The Docker environment used for the project is located separately from this analytics project.

Start the professor-provided environment before running the HBase or Hive components.

Example:

```bash
cd ~/Desktop/Big_Data
docker compose start
```

Check the running containers:

```bash
docker compose ps
```

Avoid using:

```bash
docker compose down -v
```

because container-local configuration changes and stored Docker volumes may be removed.

---

## Access Apache Zeppelin

Open:

```text
http://localhost:8888
```

The exported project notebook can be imported from:

```text
zeppelin/Loblaw_HBase_Hive_Analytics.zpln
```

---

## Run the Data-Validation Script

From the project root directory:

```bash
python3 python/validate_data.py
```

---

## Run the HBase Loader

Ensure that the HBase Docker services are running.

From the project root directory:

```bash
python3 python/load_hbase.py
```

---

## Run the Python Statistical Analysis

From the project root directory:

```bash
python3 python/analytics.py
```

The script automatically locates:

```text
output/transaction_summary.csv
```

It produces:

- Record count
- Descriptive statistics
- Q1
- Q3
- IQR
- Lower bound
- Upper bound
- Outlier count
- Outlier percentage

---

# HiveQL Analytics

The HiveQL file is:

```text
hive/analytics.hql
```

It contains both core and advanced analysis.

The analysis includes:

- Revenue by store
- Store ranking
- Regional performance
- Category contribution
- Payment methods
- Loyalty status
- Promotion impact
- Top products
- Transaction summaries
- Hourly patterns
- Day-of-week patterns
- Store revenue deviation

---

# Screenshot Evidence

All execution evidence is stored under:

```text
screenshots/
```

The screenshot folders document:

- Environment setup
- Source-data review
- Data validation
- Malformed-record handling
- HBase model design
- Row-key design
- HBase table creation
- Python-to-HBase connection
- HBase data ingestion
- HBase validation
- Hive–HBase integration
- Integration testing
- Core HiveQL analytics
- Advanced HiveQL analytics
- Python statistical analytics
- Integrated investigation
- Final documentation

---

# Key Business Findings

## Store Performance

ST-CAL-001 was the strongest-performing store:

- Revenue: **$55,573.77**
- Transactions: **1,167**
- Average transaction value: **$47.62**
- Performance above average store revenue: **23.56%**

ST-KIT-001 had the largest negative revenue deviation:

- Deviation: **-$7,102.69**
- Percentage deviation: **-15.79%**

---

## Regional Performance

- Highest total regional revenue: **Central**
- Highest average revenue per store: **Western**
- Western average revenue per store: **$50,941.11**

---

## Time-Based Performance

- Peak transaction hour: **18:00**
- Transactions at 18:00: **1,809**
- Revenue at 18:00: **$76,526.71**

- Highest transaction-count day: **Sunday**
- Sunday transactions: **2,106**

- Highest daily revenue: **Saturday**
- Saturday revenue: **$90,570.71**

---

## Promotion Performance

- Highest promotional revenue category: **Grocery**
- Promotional revenue: **$3,962.47**
- Promotional share of Grocery revenue: **2.31%**

Most Grocery revenue was generated without promotions.

---

## Transaction Distribution

The transaction-value distribution was right-skewed.

Most transactions occurred in the lower and middle transaction-value ranges. A smaller number of transactions occurred in the highest-value ranges.

High-value transactions can increase the mean, so both the mean and median should be considered when describing typical customer spending.

---

# Business Recommendations

1. Review the successful operations and product mix of ST-CAL-001.
2. Investigate performance issues at ST-KIT-001.
3. Increase staffing and inventory readiness during weekends and around 18:00.
4. Evaluate promotion performance using revenue, margins, transaction counts, and customer response.
5. Investigate high-value transactions by store, region, category, loyalty status, and payment method.
6. Use revenue totals, averages, medians, deviations, and transaction distributions together when making decisions.

---

# Final Submission Checklist

- [x] Source dataset included
- [x] Data-validation script included
- [x] Malformed-record output included
- [x] HBase table-creation script included
- [x] HBase validation commands included
- [x] Python HBase loader included
- [x] Hive external-table script included
- [x] Core and advanced HiveQL analytics included
- [x] Transaction summary CSV included
- [x] Python statistical-analysis script included
- [x] Zeppelin notebook exported
- [x] Final analysis report included
- [x] Master Tasks 1–12 documented
- [x] Screenshots organized by task
- [x] Final Master Task 12 screenshots included
- [x] README completed
- [x] GitHub repository created
- [x] Complete project pushed to GitHub
- [x] GitHub repository screenshot included
- [x] Final changes committed and pushed
- [x] Git working tree confirmed clean

---

# Conclusion

This project demonstrates a complete big-data retail analytics workflow using HBase, Hive, Python, Pandas, Docker, and Apache Zeppelin.

HBase provided scalable event-level data storage. HiveQL provided aggregated business analysis across stores, regions, categories, promotions, and transaction periods. Python added transaction-level statistical analysis and IQR-based outlier detection.

The combined investigation identified meaningful performance differences across stores, regions, time periods, promotion activity, and transaction values.

The final results support practical decisions related to store operations, staffing, inventory planning, promotion evaluation, and high-value customer behavior.