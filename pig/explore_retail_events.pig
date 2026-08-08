-- Task 9: Explore Retail Events using Apache Pig
-- Student: Han-Pin Hung
-- Source: /user/hanpin/loblaw-retail/raw/retail_events.csv

-- Load the raw retail events dataset from HDFS
raw_retail_events = LOAD '/user/hanpin/loblaw-retail/raw/retail_events.csv'
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
    quantity:int,
    unit_price:double,
    discount_amount:double,
    final_price:double,
    promotion_flag:chararray,
    promotion_id:chararray,
    payment_type:chararray,
    loyalty_flag:chararray
);

-- Remove the CSV header row
retail_events = FILTER raw_retail_events
BY event_id IS NOT NULL
AND event_id != 'event_id';

-- Select a small sample
sample_events = LIMIT retail_events 5;

-- Display schema
DESCRIBE retail_events;

-- Demonstrate Pig relation processing
ILLUSTRATE retail_events;

-- Display sample records
DUMP sample_events;