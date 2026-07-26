-- ============================================================
-- Master Task 7 - Hive-HBase Integration
-- ============================================================

DROP TABLE IF EXISTS retail_events_hive_v2;

CREATE EXTERNAL TABLE retail_events_hive_v2
(
    row_key STRING,
    transaction_id STRING,
    event_timestamp STRING,
    payment_type STRING,
    loyalty_flag STRING,
    product_id STRING,
    product_name STRING,
    category STRING,
    store_id STRING,
    store_city STRING,
    province STRING,
    store_region STRING,
    quantity STRING,
    unit_price STRING,
    discount_amount STRING,
    final_price STRING,
    promotion_flag STRING,
    promotion_id STRING
)
STORED BY
'org.apache.hadoop.hive.hbase.HBaseStorageHandler'
WITH SERDEPROPERTIES
(
    "hbase.columns.mapping" =
    ":key,
     transaction:transaction_id,
     transaction:event_timestamp,
     transaction:payment_type,
     transaction:loyalty_flag,
     product:product_id,
     product:product_name,
     product:category,
     store:store_id,
     store:city,
     store:province,
     store:region,
     sales:quantity,
     sales:unit_price,
     sales:discount_amount,
     sales:final_price,
     sales:promotion_flag,
     sales:promotion_id"
)
TBLPROPERTIES
(
    "hbase.table.name" = "retail_events"
);