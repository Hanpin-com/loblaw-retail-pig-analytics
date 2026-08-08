-- Task 15: Join Retail Datasets
-- Student: Han-Pin Hung
--
-- Required Pig Operators:
-- JOIN
-- COGROUP
--
-- Inputs:
-- transformed_retail_events
-- stores.csv
-- products.csv
-- promotions.csv
--
-- Main Output:
-- /user/hanpin/loblaw-retail/processed/joined_retail_dataset


-- ==================================================
-- 1. LOAD TRANSFORMED RETAIL EVENTS
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
-- 2. LOAD STORE REFERENCE DATA
-- ==================================================

stores_raw = LOAD '/user/hanpin/loblaw-retail/raw/stores.csv'
USING PigStorage(',')
AS (
    store_id:chararray,
    store_city:chararray,
    province:chararray,
    store_region:chararray
);

stores = FILTER stores_raw BY store_id != 'store_id';


-- ==================================================
-- 3. LOAD PRODUCT REFERENCE DATA
-- ==================================================

products_raw = LOAD '/user/hanpin/loblaw-retail/raw/products.csv'
USING PigStorage(',')
AS (
    product_id:chararray,
    product_name:chararray,
    category:chararray,
    base_unit_price_raw:chararray
);

products_no_header =
    FILTER products_raw BY product_id != 'product_id';

products = FOREACH products_no_header GENERATE
    product_id,
    product_name,
    category,
    (double)base_unit_price_raw AS base_unit_price;


-- ==================================================
-- 4. LOAD PROMOTION REFERENCE DATA
-- ==================================================

promotions_raw = LOAD '/user/hanpin/loblaw-retail/raw/promotions.csv'
USING PigStorage(',')
AS (
    promotion_id:chararray,
    product_id:chararray,
    promotion_name:chararray,
    start_date:chararray,
    end_date:chararray,
    discount_rate_raw:chararray
);

promotions_no_header =
    FILTER promotions_raw BY promotion_id != 'promotion_id';

promotions = FOREACH promotions_no_header GENERATE
    promotion_id,
    product_id,
    promotion_name,
    start_date,
    end_date,
    (double)discount_rate_raw AS discount_rate;


-- ==================================================
-- 5. JOIN EVENTS WITH STORES
-- ==================================================

event_store_join = JOIN
    events BY store_id LEFT OUTER,
    stores BY store_id;

events_with_store = FOREACH event_store_join GENERATE

    events::event_id AS event_id,
    events::transaction_id AS transaction_id,

    events::store_id AS store_id,
    events::store_city AS store_city,
    events::province AS province,
    events::store_region AS store_region,

    events::event_timestamp AS event_timestamp,

    events::product_id AS product_id,
    events::product_name AS product_name,
    events::category AS category,

    events::quantity AS quantity,
    events::unit_price AS unit_price,
    events::discount_amount AS discount_amount,
    events::final_price AS final_price,

    events::promotion_flag AS promotion_flag,
    events::promotion_id AS promotion_id,

    events::payment_type AS payment_type,
    events::loyalty_flag AS loyalty_flag,

    events::hour_of_day AS hour_of_day,
    events::day_of_week AS day_of_week,
    events::month AS month,
    events::weekend_indicator AS weekend_indicator,

    events::net_sales AS net_sales,
    events::discount_percentage AS discount_percentage,
    events::promotion_status AS promotion_status,

    stores::store_city AS reference_store_city,
    stores::province AS reference_province,
    stores::store_region AS reference_store_region;


-- ==================================================
-- 6. JOIN WITH PRODUCTS
-- ==================================================

event_product_join = JOIN
    events_with_store BY product_id LEFT OUTER,
    products BY product_id;

events_with_product = FOREACH event_product_join GENERATE

    events_with_store::event_id AS event_id,
    events_with_store::transaction_id AS transaction_id,

    events_with_store::store_id AS store_id,
    events_with_store::store_city AS store_city,
    events_with_store::province AS province,
    events_with_store::store_region AS store_region,

    events_with_store::event_timestamp AS event_timestamp,

    events_with_store::product_id AS product_id,
    events_with_store::product_name AS product_name,
    events_with_store::category AS category,

    events_with_store::quantity AS quantity,
    events_with_store::unit_price AS unit_price,
    events_with_store::discount_amount AS discount_amount,
    events_with_store::final_price AS final_price,

    events_with_store::promotion_flag AS promotion_flag,
    events_with_store::promotion_id AS promotion_id,

    events_with_store::payment_type AS payment_type,
    events_with_store::loyalty_flag AS loyalty_flag,

    events_with_store::hour_of_day AS hour_of_day,
    events_with_store::day_of_week AS day_of_week,
    events_with_store::month AS month,
    events_with_store::weekend_indicator AS weekend_indicator,

    events_with_store::net_sales AS net_sales,
    events_with_store::discount_percentage AS discount_percentage,
    events_with_store::promotion_status AS promotion_status,

    events_with_store::reference_store_city
        AS reference_store_city,

    events_with_store::reference_province
        AS reference_province,

    events_with_store::reference_store_region
        AS reference_store_region,

    products::product_name AS catalog_product_name,
    products::category AS catalog_category,
    products::base_unit_price AS base_unit_price;


-- ==================================================
-- 7. JOIN WITH PROMOTIONS
-- ==================================================

event_promotion_join = JOIN
    events_with_product BY promotion_id LEFT OUTER,
    promotions BY promotion_id;

joined_retail_dataset =
    FOREACH event_promotion_join GENERATE

    events_with_product::event_id AS event_id,
    events_with_product::transaction_id AS transaction_id,

    events_with_product::store_id AS store_id,
    events_with_product::store_city AS store_city,
    events_with_product::province AS province,
    events_with_product::store_region AS store_region,

    events_with_product::event_timestamp AS event_timestamp,

    events_with_product::product_id AS product_id,
    events_with_product::product_name AS product_name,
    events_with_product::category AS category,

    events_with_product::quantity AS quantity,
    events_with_product::unit_price AS unit_price,
    events_with_product::discount_amount AS discount_amount,
    events_with_product::final_price AS final_price,

    events_with_product::promotion_flag AS promotion_flag,
    events_with_product::promotion_id AS promotion_id,

    events_with_product::payment_type AS payment_type,
    events_with_product::loyalty_flag AS loyalty_flag,

    events_with_product::hour_of_day AS hour_of_day,
    events_with_product::day_of_week AS day_of_week,
    events_with_product::month AS month,
    events_with_product::weekend_indicator AS weekend_indicator,

    events_with_product::net_sales AS net_sales,
    events_with_product::discount_percentage
        AS discount_percentage,

    events_with_product::promotion_status
        AS promotion_status,

    events_with_product::reference_store_city
        AS reference_store_city,

    events_with_product::reference_province
        AS reference_province,

    events_with_product::reference_store_region
        AS reference_store_region,

    events_with_product::catalog_product_name
        AS catalog_product_name,

    events_with_product::catalog_category
        AS catalog_category,

    events_with_product::base_unit_price
        AS base_unit_price,

    promotions::promotion_name AS promotion_name,
    promotions::start_date AS promotion_start_date,
    promotions::end_date AS promotion_end_date,
    promotions::discount_rate AS promotion_discount_rate;


-- ==================================================
-- 8. DEMONSTRATE COGROUP
-- ==================================================

promotional_events =
    FILTER events BY
        promotion_id IS NOT NULL
        AND promotion_id != '';

promotion_cogroup = COGROUP
    promotional_events BY promotion_id,
    promotions BY promotion_id;

promotion_cogroup_summary =
    FOREACH promotion_cogroup GENERATE
        group AS promotion_id,
        COUNT(promotional_events) AS retail_event_count,
        COUNT(promotions) AS promotion_reference_count;


-- ==================================================
-- 9. STORE TASK 15 OUTPUTS
-- ==================================================

STORE joined_retail_dataset
INTO '/user/hanpin/loblaw-retail/processed/joined_retail_dataset'
USING PigStorage(',');

STORE promotion_cogroup_summary
INTO '/user/hanpin/loblaw-retail/analytics/promotion_cogroup_summary'
USING PigStorage(',');