-- Task 12: Store-Level Retail Aggregation
-- Student: Han-Pin Hung
-- Input: transformed_retail_events
-- Output: aggregated_store_sales

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

-- Group retail events by store.
store_groups = GROUP events BY (store_id, store_city);

-- Calculate store-level business metrics.
store_sales = FOREACH store_groups {
    distinct_transactions = DISTINCT events.transaction_id;

    GENERATE
        group.store_id AS store_id:chararray,
        group.store_city AS store_city:chararray,
        SUM(events.net_sales) AS total_sales:double,
        AVG(events.net_sales) AS average_sales:double,
        COUNT(distinct_transactions) AS transaction_count:long,
        SUM(events.quantity) AS quantity_sold:long,
        MAX(events.net_sales) AS max_event_sales:double,
        MIN(events.net_sales) AS min_event_sales:double;
};

STORE store_sales
INTO '/user/hanpin/loblaw-retail/processed/aggregated_store_sales'
USING PigStorage(',');