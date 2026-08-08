-- Task 11: Transform Retail Data
-- Student: Han-Pin Hung
-- Input: /user/hanpin/loblaw-retail/processed/clean_retail_events
-- Output: /user/hanpin/loblaw-retail/processed/transformed_retail_events

-- Load the cleaned dataset produced in Task 10.
clean_events = LOAD '/user/hanpin/loblaw-retail/processed/clean_retail_events'
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

-- Convert the timestamp string into a Pig DateTime value.
dated_events = FOREACH clean_events GENERATE
    event_id,
    transaction_id,
    store_id,
    store_city,
    province,
    store_region,
    event_timestamp,
    product_id,
    product_name,
    category,
    quantity,
    unit_price,
    discount_amount,
    final_price,
    promotion_flag,
    promotion_id,
    payment_type,
    loyalty_flag,
    ToDate(event_timestamp, 'yyyy-MM-dd HH:mm:ss') AS event_dt;

-- Generate the required derived analytical attributes.
transformed_retail_events = FOREACH dated_events GENERATE
    event_id,
    transaction_id,
    store_id,
    store_city,
    province,
    store_region,
    event_timestamp,
    product_id,
    product_name,
    category,
    quantity,
    unit_price,
    discount_amount,
    final_price,
    promotion_flag,
    promotion_id,
    payment_type,
    loyalty_flag,

    GetHour(event_dt) AS hour_of_day:int,

    ToString(event_dt, 'EEEE') AS day_of_week:chararray,

    GetMonth(event_dt) AS month:int,

    (
        ToString(event_dt, 'E') == 'Sat'
        OR ToString(event_dt, 'E') == 'Sun'
        ? 'Y'
        : 'N'
    ) AS weekend_indicator:chararray,

    (
        (quantity * unit_price) - discount_amount
    ) AS net_sales:double,

    (
        (quantity * unit_price) > 0.0
        ? (discount_amount / (quantity * unit_price)) * 100.0
        : 0.0
    ) AS discount_percentage:double,

    (
        promotion_flag == 'Y'
        ? 'Promotional'
        : 'Non-Promotional'
    ) AS promotion_status:chararray;

-- Create a compact sample containing the derived attributes.
sample_view = FOREACH transformed_retail_events GENERATE
    event_id,
    event_timestamp,
    hour_of_day,
    day_of_week,
    month,
    weekend_indicator,
    net_sales,
    discount_percentage,
    promotion_status;

sample_transformed = LIMIT sample_view 5;

DESCRIBE transformed_retail_events;
DUMP sample_transformed;

-- Store the transformed dataset in HDFS.
STORE transformed_retail_events
INTO '/user/hanpin/loblaw-retail/processed/transformed_retail_events'
USING PigStorage(',');