-- Task 14: Sort and Rank Business Results
-- Student: Han-Pin Hung
--
-- Required Pig Operators:
-- ORDER
-- LIMIT
--
-- Rankings:
-- 1. Top 10 stores
-- 2. Top 10 products
-- 3. Bottom 10 products
-- 4. Highest discounts
-- 5. Highest sales categories


-- ==================================================
-- 1. LOAD STORE AGGREGATION
-- ==================================================

store_sales = LOAD '/user/hanpin/loblaw-retail/processed/aggregated_store_sales'
USING PigStorage(',')
AS (
    store_id:chararray,
    store_city:chararray,
    total_sales:double,
    average_sales:double,
    transaction_count:long,
    quantity_sold:long,
    max_event_sales:double,
    min_event_sales:double
);


-- ==================================================
-- 2. TOP 10 STORES BY TOTAL SALES
-- ==================================================

store_all = GROUP store_sales ALL;

top_10_stores = FOREACH store_all {
    ranked = ORDER store_sales BY total_sales DESC;
    limited = LIMIT ranked 10;

    GENERATE FLATTEN(limited);
};


-- ==================================================
-- 3. LOAD PRODUCT AGGREGATION
-- ==================================================

product_sales = LOAD '/user/hanpin/loblaw-retail/processed/aggregated_product_sales'
USING PigStorage(',')
AS (
    product_id:chararray,
    product_name:chararray,
    category:chararray,
    total_quantity:long,
    total_revenue:double,
    average_selling_price:double,
    event_count:long,
    max_selling_price:double,
    min_selling_price:double
);


-- ==================================================
-- 4. TOP 10 PRODUCTS BY TOTAL REVENUE
-- ==================================================

product_all = GROUP product_sales ALL;

top_10_products = FOREACH product_all {
    ranked = ORDER product_sales BY total_revenue DESC;
    limited = LIMIT ranked 10;

    GENERATE FLATTEN(limited);
};


-- ==================================================
-- 5. BOTTOM 10 PRODUCTS BY TOTAL REVENUE
-- ==================================================

bottom_10_products = FOREACH product_all {
    ranked = ORDER product_sales BY total_revenue ASC;
    limited = LIMIT ranked 10;

    GENERATE FLATTEN(limited);
};


-- ==================================================
-- 6. LOAD TRANSFORMED RETAIL EVENTS
-- ==================================================

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


-- ==================================================
-- 7. HIGHEST DISCOUNTS
-- ==================================================

discount_events = FILTER events BY discount_amount > 0.0;

discount_view = FOREACH discount_events GENERATE
    event_id AS event_id,
    product_id AS product_id,
    product_name AS product_name,
    category AS category,
    discount_amount AS discount_amount,
    discount_percentage AS discount_percentage,
    net_sales AS net_sales,
    promotion_status AS promotion_status;

discount_all = GROUP discount_view ALL;

highest_discounts = FOREACH discount_all {
    ranked = ORDER discount_view
        BY discount_amount DESC, discount_percentage DESC;

    limited = LIMIT ranked 10;

    GENERATE FLATTEN(limited);
};


-- ==================================================
-- 8. LOAD CATEGORY AGGREGATION
-- ==================================================

category_sales = LOAD '/user/hanpin/loblaw-retail/analytics/aggregated_category_sales'
USING PigStorage(',')
AS (
    category:chararray,
    total_sales:double,
    quantity_sold:long,
    average_discount:double,
    average_discount_percentage:double,
    max_discount:double,
    min_discount:double
);


-- ==================================================
-- 9. HIGHEST SALES CATEGORIES
-- ==================================================

category_all = GROUP category_sales ALL;

highest_sales_categories = FOREACH category_all {
    ranked = ORDER category_sales BY total_sales DESC;
    limited = LIMIT ranked 10;

    GENERATE FLATTEN(limited);
};


-- ==================================================
-- 10. STORE RANKING RESULTS IN HDFS
-- ==================================================

STORE top_10_stores
INTO '/user/hanpin/loblaw-retail/analytics/rankings/top_10_stores'
USING PigStorage(',');


STORE top_10_products
INTO '/user/hanpin/loblaw-retail/analytics/rankings/top_10_products'
USING PigStorage(',');


STORE bottom_10_products
INTO '/user/hanpin/loblaw-retail/analytics/rankings/bottom_10_products'
USING PigStorage(',');


STORE highest_discounts
INTO '/user/hanpin/loblaw-retail/analytics/rankings/highest_discounts'
USING PigStorage(',');


STORE highest_sales_categories
INTO '/user/hanpin/loblaw-retail/analytics/rankings/highest_sales_categories'
USING PigStorage(',');