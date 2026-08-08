-- Task 16: Export Processed Data
-- Student: Han-Pin Hung
--
-- Required Pig Operators:
-- STORE
-- PigStorage()
--
-- This script exports the completed processed datasets
-- from /processed/ into /exports/ for downstream use.


-- ==================================================
-- 1. LOAD CLEANED DATASET
-- ==================================================

clean_data =
    LOAD '/user/hanpin/loblaw-retail/processed/clean_retail_events'
    USING PigStorage(',');


-- ==================================================
-- 2. LOAD TRANSFORMED DATASET
-- ==================================================

transformed_data =
    LOAD '/user/hanpin/loblaw-retail/processed/transformed_retail_events'
    USING PigStorage(',');


-- ==================================================
-- 3. LOAD STORE AGGREGATION
-- ==================================================

store_aggregation =
    LOAD '/user/hanpin/loblaw-retail/processed/aggregated_store_sales'
    USING PigStorage(',');


-- ==================================================
-- 4. LOAD PRODUCT AGGREGATION
-- ==================================================

product_aggregation =
    LOAD '/user/hanpin/loblaw-retail/processed/aggregated_product_sales'
    USING PigStorage(',');


-- ==================================================
-- 5. LOAD PROMOTION ANALYSIS
-- ==================================================

promotion_data =
    LOAD '/user/hanpin/loblaw-retail/processed/promotion_analysis'
    USING PigStorage(',');


-- ==================================================
-- 6. LOAD ENRICHED JOINED DATASET
-- ==================================================

joined_data =
    LOAD '/user/hanpin/loblaw-retail/processed/joined_retail_dataset'
    USING PigStorage(',');


-- ==================================================
-- 7. EXPORT CLEANED DATASET
-- ==================================================

STORE clean_data
INTO '/user/hanpin/loblaw-retail/exports/clean_retail_events'
USING PigStorage(',');


-- ==================================================
-- 8. EXPORT TRANSFORMED DATASET
-- ==================================================

STORE transformed_data
INTO '/user/hanpin/loblaw-retail/exports/transformed_retail_events'
USING PigStorage(',');


-- ==================================================
-- 9. EXPORT STORE AGGREGATION
-- ==================================================

STORE store_aggregation
INTO '/user/hanpin/loblaw-retail/exports/aggregated_store_sales'
USING PigStorage(',');


-- ==================================================
-- 10. EXPORT PRODUCT AGGREGATION
-- ==================================================

STORE product_aggregation
INTO '/user/hanpin/loblaw-retail/exports/aggregated_product_sales'
USING PigStorage(',');


-- ==================================================
-- 11. EXPORT PROMOTION ANALYSIS
-- ==================================================

STORE promotion_data
INTO '/user/hanpin/loblaw-retail/exports/promotion_analysis'
USING PigStorage(',');


-- ==================================================
-- 12. EXPORT ENRICHED JOINED DATASET
-- ==================================================

STORE joined_data
INTO '/user/hanpin/loblaw-retail/exports/joined_retail_dataset'
USING PigStorage(',');