-- Task 12: Product and Category Retail Aggregation
-- Student: Han-Pin Hung
-- Input: transformed_retail_events
-- Outputs:
--   aggregated_product_sales
--   aggregated_category_sales

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

-- --------------------------------------------------
-- Product-Level Analytics
-- --------------------------------------------------

product_groups = GROUP events BY
    (product_id, product_name, category);

product_sales = FOREACH product_groups GENERATE
    group.product_id AS product_id:chararray,
    group.product_name AS product_name:chararray,
    group.category AS category:chararray,
    SUM(events.quantity) AS total_quantity:long,
    SUM(events.net_sales) AS total_revenue:double,
    AVG(events.unit_price) AS average_selling_price:double,
    COUNT(events) AS event_count:long,
    MAX(events.unit_price) AS max_selling_price:double,
    MIN(events.unit_price) AS min_selling_price:double;

STORE product_sales
INTO '/user/hanpin/loblaw-retail/processed/aggregated_product_sales'
USING PigStorage(',');

-- --------------------------------------------------
-- Category-Level Analytics
-- --------------------------------------------------

category_groups = GROUP events BY category;

category_sales = FOREACH category_groups GENERATE
    group AS category:chararray,
    SUM(events.net_sales) AS total_sales:double,
    SUM(events.quantity) AS quantity_sold:long,
    AVG(events.discount_amount) AS average_discount:double,
    AVG(events.discount_percentage) AS average_discount_percentage:double,
    MAX(events.discount_amount) AS max_discount:double,
    MIN(events.discount_amount) AS min_discount:double;

STORE category_sales
INTO '/user/hanpin/loblaw-retail/analytics/aggregated_category_sales'
USING PigStorage(',');