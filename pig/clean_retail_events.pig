-- Task 10: Clean the Retail Dataset
-- Student: Han-Pin Hung
-- Input: /user/hanpin/loblaw-retail/raw/retail_events.csv
-- Output: /user/hanpin/loblaw-retail/processed/clean_retail_events

-- Load all source fields as chararray first.
-- This prevents the CSV header or malformed numeric values from being
-- converted before validation.
raw_events = LOAD '/user/hanpin/loblaw-retail/raw/retail_events.csv'
USING PigStorage(',')
AS (
    event_id:chararray,
    transaction_id:chararray,
    store_id:chararray,
    store_city:chararray,
    province:chararray,
    store_region:chararray,
    event_timestamp:chararray,
    product_id:chararray,
    product_name:chararray,
    category:chararray,
    quantity_raw:chararray,
    unit_price_raw:chararray,
    discount_amount_raw:chararray,
    final_price_raw:chararray,
    promotion_flag:chararray,
    promotion_id:chararray,
    payment_type:chararray,
    loyalty_flag:chararray
);

-- Remove CSV header and records with missing mandatory identifiers.
valid_ids = FILTER raw_events BY
    event_id IS NOT NULL AND event_id != 'event_id' AND
    transaction_id IS NOT NULL AND TRIM(transaction_id) != '' AND
    store_id IS NOT NULL AND TRIM(store_id) != '' AND
    product_id IS NOT NULL AND TRIM(product_id) != '';

-- Validate timestamp format: YYYY-MM-DD HH:MM:SS
valid_timestamp = FILTER valid_ids BY
    event_timestamp IS NOT NULL AND
    event_timestamp MATCHES '[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2}';

-- Validate numeric text before casting.
valid_numeric = FILTER valid_timestamp BY
    quantity_raw MATCHES '[0-9]+' AND
    unit_price_raw MATCHES '[0-9]+([.][0-9]+)?' AND
    discount_amount_raw MATCHES '[0-9]+([.][0-9]+)?' AND
    final_price_raw MATCHES '[0-9]+([.][0-9]+)?';

-- Convert validated numeric fields to their proper data types.
typed_events = FOREACH valid_numeric GENERATE
    TRIM(event_id) AS event_id:chararray,
    TRIM(transaction_id) AS transaction_id:chararray,
    TRIM(store_id) AS store_id:chararray,
    TRIM(store_city) AS store_city:chararray,
    TRIM(province) AS province:chararray,
    TRIM(store_region) AS store_region:chararray,
    TRIM(event_timestamp) AS event_timestamp:chararray,
    TRIM(product_id) AS product_id:chararray,
    TRIM(product_name) AS product_name:chararray,
    TRIM(category) AS category:chararray,
    (int)quantity_raw AS quantity:int,
    (double)unit_price_raw AS unit_price:double,
    (double)discount_amount_raw AS discount_amount:double,
    (double)final_price_raw AS final_price:double,
    promotion_flag AS promotion_flag:chararray,
    promotion_id AS promotion_id:chararray,
    payment_type AS payment_type:chararray,
    loyalty_flag AS loyalty_flag:chararray;

-- Reject invalid business values.
valid_values = FILTER typed_events BY
    quantity > 0 AND
    unit_price >= 0.0 AND
    discount_amount >= 0.0 AND
    final_price >= 0.0;

-- Final cleaned relation.
clean_retail_events = FOREACH valid_values GENERATE *;

-- Show the cleaned schema and a small sample.
DESCRIBE clean_retail_events;

sample_clean = LIMIT clean_retail_events 5;
DUMP sample_clean;

-- Store cleaned data in HDFS for later tasks.
STORE clean_retail_events
INTO '/user/hanpin/loblaw-retail/processed/clean_retail_events'
USING PigStorage(',');