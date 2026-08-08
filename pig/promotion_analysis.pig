-- Task 13: Analyze Promotional Activity
-- Student: Han-Pin Hung
-- Input: transformed_retail_events
-- Output: promotion_analysis

events = LOAD '/user/hanpin/loblaw-retail/processed/transformed_retail_events'
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
    loyalty_flag:chararray,
    hour_of_day:int,
    day_of_week:chararray,
    month:int,
    weekend_indicator:chararray,
    net_sales:double,
    discount_percentage:double,
    promotion_status:chararray
);

-- Group events into Promotional and Non-Promotional activity.
promotion_groups = GROUP events BY promotion_status;

-- Calculate the required promotional metrics.
promotion_analysis = FOREACH promotion_groups GENERATE
    group AS promotion_status:chararray,
    SUM(events.net_sales) AS total_sales:double,
    SUM(events.quantity) AS quantity_sold:long,
    AVG(events.unit_price) AS average_selling_price:double,
    AVG(events.discount_amount) AS average_discount:double,
    COUNT(events) AS event_count:long;

STORE promotion_analysis
INTO '/user/hanpin/loblaw-retail/processed/promotion_analysis'
USING PigStorage(',');