-- ============================================================
-- Master Task 8 - Core Hive Business Analytics
-- ============================================================

-- ------------------------------------------------------------
-- 1. Dataset validation
-- ------------------------------------------------------------

SELECT
    COUNT(*) AS total_events,
    COUNT(DISTINCT transaction_id) AS total_transactions,
    COUNT(DISTINCT store_id) AS total_stores,
    COUNT(DISTINCT product_id) AS total_products
FROM retail_events_hive;

-- ------------------------------------------------------------
-- 2. Revenue by store
-- ------------------------------------------------------------

SELECT
    store_id,
    store_city,
    store_region,
    COUNT(*) AS sales_events,
    SUM(CAST(quantity AS INT)) AS total_quantity,
    ROUND(SUM(CAST(final_price AS DOUBLE)), 2) AS total_revenue,
    ROUND(AVG(CAST(final_price AS DOUBLE)), 2) AS average_event_value
FROM retail_events_hive
GROUP BY
    store_id,
    store_city,
    store_region
ORDER BY total_revenue DESC;

-- ------------------------------------------------------------
-- 3. Sales by product category
-- ------------------------------------------------------------

SELECT
    category,
    COUNT(*) AS sales_events,
    SUM(CAST(quantity AS INT)) AS total_quantity,
    ROUND(SUM(CAST(final_price AS DOUBLE)), 2) AS total_revenue,
    ROUND(AVG(CAST(final_price AS DOUBLE)), 2) AS average_event_value
FROM retail_events_hive
GROUP BY category
ORDER BY total_revenue DESC;

-- ------------------------------------------------------------
-- 4. Payment type analysis
-- ------------------------------------------------------------

SELECT
    payment_type,
    COUNT(*) AS sales_events,
    COUNT(DISTINCT transaction_id) AS total_transactions,
    SUM(CAST(quantity AS INT)) AS total_quantity,
    ROUND(SUM(CAST(final_price AS DOUBLE)), 2) AS total_revenue,
    ROUND(AVG(CAST(final_price AS DOUBLE)), 2) AS average_event_value
FROM retail_events_hive
GROUP BY payment_type
ORDER BY total_revenue DESC;

-- ------------------------------------------------------------
-- 5. Loyalty customer comparison
-- ------------------------------------------------------------

SELECT
    loyalty_flag,
    COUNT(*) AS sales_events,
    COUNT(DISTINCT transaction_id) AS total_transactions,
    SUM(CAST(quantity AS INT)) AS total_quantity,
    ROUND(SUM(CAST(final_price AS DOUBLE)), 2) AS total_revenue,
    ROUND(AVG(CAST(final_price AS DOUBLE)), 2) AS average_event_value
FROM retail_events_hive
GROUP BY loyalty_flag
ORDER BY total_revenue DESC;

-- ------------------------------------------------------------
-- 6. Promotion impact analysis
-- ------------------------------------------------------------

SELECT
    promotion_flag,
    COUNT(*) AS sales_events,
    COUNT(DISTINCT transaction_id) AS total_transactions,
    SUM(CAST(quantity AS INT)) AS total_quantity,
    ROUND(SUM(CAST(discount_amount AS DOUBLE)), 2) AS total_discount,
    ROUND(SUM(CAST(final_price AS DOUBLE)), 2) AS total_revenue,
    ROUND(AVG(CAST(final_price AS DOUBLE)), 2) AS average_event_value
FROM retail_events_hive
GROUP BY promotion_flag
ORDER BY total_revenue DESC;

-- ------------------------------------------------------------
-- 7. Top-selling products by total revenue
-- ------------------------------------------------------------

SELECT
    product_id,
    product_name,
    category,
    COUNT(*) AS sales_events,
    SUM(CAST(quantity AS INT)) AS total_quantity,
    ROUND(SUM(CAST(final_price AS DOUBLE)), 2) AS total_revenue,
    ROUND(AVG(CAST(final_price AS DOUBLE)), 2) AS average_event_value
FROM retail_events_hive
GROUP BY
    product_id,
    product_name,
    category
ORDER BY total_revenue DESC
LIMIT 10;

-- ------------------------------------------------------------
-- 8. Top-selling products by quantity sold
-- ------------------------------------------------------------

SELECT
    product_id,
    product_name,
    category,
    COUNT(*) AS sales_events,
    SUM(CAST(quantity AS INT)) AS total_quantity,
    ROUND(SUM(CAST(final_price AS DOUBLE)), 2) AS total_revenue
FROM retail_events_hive
GROUP BY
    product_id,
    product_name,
    category
ORDER BY total_quantity DESC
LIMIT 10;

-- ============================================================
-- Master Task 9 - Hive Analytical View
-- ============================================================

DROP VIEW IF EXISTS retail_events_analytics;

CREATE VIEW retail_events_analytics AS
SELECT
    row_key,
    transaction_id,
    CAST(event_timestamp AS TIMESTAMP) AS event_timestamp,
    payment_type,
    loyalty_flag,
    product_id,
    product_name,
    category,
    store_id,
    store_city,
    province,
    store_region,
    CAST(quantity AS INT) AS quantity,
    CAST(unit_price AS DECIMAL(10,2)) AS unit_price,
    CAST(discount_amount AS DECIMAL(10,2)) AS discount_amount,
    CAST(final_price AS DECIMAL(10,2)) AS final_price,
    promotion_flag
FROM retail_events_hive;

-- ============================================================
-- Master Task 9 - Advanced Hive Analytics
-- Part 2 - Transaction-Level Analytics
-- ============================================================

DROP VIEW IF EXISTS transaction_summary;

CREATE VIEW transaction_summary AS
SELECT
    transaction_id,
    store_id,
    store_city,
    province,
    store_region,
    payment_type,
    loyalty_flag,
    MIN(event_timestamp) AS transaction_timestamp,
    COUNT(*) AS product_lines,
    COUNT(DISTINCT product_id) AS distinct_products,
    SUM(quantity) AS total_quantity,
    ROUND(SUM(final_price), 2) AS transaction_value
FROM retail_events_analytics
GROUP BY
    transaction_id,
    store_id,
    store_city,
    province,
    store_region,
    payment_type,
    loyalty_flag;


-- Validate transaction count
SELECT COUNT(*) AS total_transactions
FROM transaction_summary;


-- Overall transaction metrics
SELECT
    COUNT(*) AS total_transactions,
    ROUND(SUM(transaction_value), 2) AS total_revenue,
    ROUND(AVG(transaction_value), 2) AS average_transaction_value,
    ROUND(MIN(transaction_value), 2) AS minimum_transaction_value,
    ROUND(MAX(transaction_value), 2) AS maximum_transaction_value,
    ROUND(AVG(total_quantity), 2) AS average_quantity_per_transaction,
    ROUND(AVG(distinct_products), 2) AS average_products_per_transaction
FROM transaction_summary;


-- Transaction performance by store
SELECT
    store_id,
    store_city,
    store_region,
    COUNT(*) AS total_transactions,
    ROUND(SUM(transaction_value), 2) AS total_revenue,
    ROUND(AVG(transaction_value), 2) AS average_transaction_value,
    ROUND(AVG(total_quantity), 2) AS average_quantity_per_transaction,
    ROUND(AVG(distinct_products), 2) AS average_products_per_transaction
FROM transaction_summary
GROUP BY
    store_id,
    store_city,
    store_region
ORDER BY average_transaction_value DESC;

-- ============================================================
-- Master Task 9 - Advanced Hive Analytics
-- Part 3 - Regional Performance Analysis
-- ============================================================

-- Regional performance
SELECT
    store_region,
    COUNT(DISTINCT store_id) AS total_stores,
    COUNT(*) AS total_transactions,
    SUM(total_quantity) AS total_quantity,
    ROUND(SUM(transaction_value), 2) AS total_revenue,
    ROUND(AVG(transaction_value), 2) AS average_transaction_value,
    ROUND(
        SUM(transaction_value) / COUNT(DISTINCT store_id),
        2
    ) AS average_revenue_per_store
FROM transaction_summary
GROUP BY store_region
ORDER BY total_revenue DESC;


-- Sales per store by region
WITH store_performance AS (
    SELECT
        store_region,
        store_id,
        COUNT(*) AS total_transactions,
        ROUND(SUM(transaction_value), 2) AS store_revenue,
        ROUND(AVG(transaction_value), 2) AS average_transaction_value
    FROM transaction_summary
    GROUP BY
        store_region,
        store_id
)

SELECT
    store_region,
    COUNT(*) AS total_stores,
    SUM(total_transactions) AS total_transactions,
    ROUND(SUM(store_revenue), 2) AS total_revenue,
    ROUND(AVG(store_revenue), 2) AS average_revenue_per_store,
    ROUND(AVG(average_transaction_value), 2)
        AS average_transaction_value
FROM store_performance
GROUP BY store_region
ORDER BY average_revenue_per_store DESC;


-- Regional revenue ranking
WITH regional_performance AS (
    SELECT
        store_region,
        COUNT(DISTINCT store_id) AS total_stores,
        COUNT(*) AS total_transactions,
        ROUND(SUM(transaction_value), 2) AS total_revenue,
        ROUND(AVG(transaction_value), 2)
            AS average_transaction_value
    FROM transaction_summary
    GROUP BY store_region
)

SELECT
    store_region,
    total_stores,
    total_transactions,
    total_revenue,
    average_transaction_value,
    RANK() OVER (
        ORDER BY total_revenue DESC
    ) AS revenue_rank
FROM regional_performance
ORDER BY revenue_rank;

-- ============================================================
-- Master Task 9 - Advanced Hive Analytics
-- Part 4 - Time-Based Activity Analysis
-- ============================================================

-- ------------------------------------------------------------
-- 4A. Hourly transaction activity
-- ------------------------------------------------------------

SELECT
    HOUR(transaction_timestamp) AS transaction_hour,
    COUNT(*) AS total_transactions,
    SUM(total_quantity) AS total_quantity,
    ROUND(SUM(transaction_value), 2) AS total_revenue,
    ROUND(AVG(transaction_value), 2) AS average_transaction_value
FROM transaction_summary
WHERE transaction_timestamp IS NOT NULL
GROUP BY HOUR(transaction_timestamp)
ORDER BY transaction_hour;


-- Top five busiest hours
SELECT
    HOUR(transaction_timestamp) AS transaction_hour,
    COUNT(*) AS total_transactions,
    ROUND(SUM(transaction_value), 2) AS total_revenue,
    ROUND(AVG(transaction_value), 2) AS average_transaction_value
FROM transaction_summary
WHERE transaction_timestamp IS NOT NULL
GROUP BY HOUR(transaction_timestamp)
ORDER BY total_transactions DESC
LIMIT 5;


-- ------------------------------------------------------------
-- 4B. Day-of-week transaction activity
-- ------------------------------------------------------------

SELECT
    CASE DAYOFWEEK(transaction_timestamp)
        WHEN 1 THEN 'Sunday'
        WHEN 2 THEN 'Monday'
        WHEN 3 THEN 'Tuesday'
        WHEN 4 THEN 'Wednesday'
        WHEN 5 THEN 'Thursday'
        WHEN 6 THEN 'Friday'
        WHEN 7 THEN 'Saturday'
    END AS day_name,

    CASE DAYOFWEEK(transaction_timestamp)
        WHEN 1 THEN 7
        WHEN 2 THEN 1
        WHEN 3 THEN 2
        WHEN 4 THEN 3
        WHEN 5 THEN 4
        WHEN 6 THEN 5
        WHEN 7 THEN 6
    END AS day_order,

    COUNT(*) AS total_transactions,
    SUM(total_quantity) AS total_quantity,
    ROUND(SUM(transaction_value), 2) AS total_revenue,
    ROUND(AVG(transaction_value), 2) AS average_transaction_value

FROM transaction_summary
WHERE transaction_timestamp IS NOT NULL

GROUP BY
    CASE DAYOFWEEK(transaction_timestamp)
        WHEN 1 THEN 'Sunday'
        WHEN 2 THEN 'Monday'
        WHEN 3 THEN 'Tuesday'
        WHEN 4 THEN 'Wednesday'
        WHEN 5 THEN 'Thursday'
        WHEN 6 THEN 'Friday'
        WHEN 7 THEN 'Saturday'
    END,

    CASE DAYOFWEEK(transaction_timestamp)
        WHEN 1 THEN 7
        WHEN 2 THEN 1
        WHEN 3 THEN 2
        WHEN 4 THEN 3
        WHEN 5 THEN 4
        WHEN 6 THEN 5
        WHEN 7 THEN 6
    END

ORDER BY day_order;

-- ============================================================
-- Master Task 9 - Advanced Hive Analytics
-- Part 5 - Category Contribution Analysis
-- ============================================================

-- ------------------------------------------------------------
-- 5A. Category revenue contribution
-- ------------------------------------------------------------

WITH category_performance AS (
    SELECT
        category,
        COUNT(*) AS sales_events,
        SUM(quantity) AS total_quantity,
        ROUND(SUM(final_price), 2) AS total_revenue,
        ROUND(AVG(final_price), 2) AS average_event_value
    FROM retail_events_analytics
    GROUP BY category
)

SELECT
    category,
    sales_events,
    total_quantity,
    total_revenue,
    average_event_value,
    ROUND(
        total_revenue * 100.0 / SUM(total_revenue) OVER (),
        2
    ) AS revenue_contribution_percent
FROM category_performance
ORDER BY total_revenue DESC;


-- ------------------------------------------------------------
-- 5B. Category revenue ranking
-- ------------------------------------------------------------

WITH category_performance AS (
    SELECT
        category,
        COUNT(*) AS sales_events,
        SUM(quantity) AS total_quantity,
        ROUND(SUM(final_price), 2) AS total_revenue,
        ROUND(AVG(final_price), 2) AS average_event_value
    FROM retail_events_analytics
    GROUP BY category
)

SELECT
    category,
    sales_events,
    total_quantity,
    total_revenue,
    average_event_value,
    ROUND(
        total_revenue * 100.0 / SUM(total_revenue) OVER (),
        2
    ) AS revenue_contribution_percent,
    RANK() OVER (
        ORDER BY total_revenue DESC
    ) AS revenue_rank
FROM category_performance
ORDER BY revenue_rank;


-- Validate total contribution percentage
WITH category_performance AS (
    SELECT
        category,
        SUM(final_price) AS total_revenue
    FROM retail_events_analytics
    GROUP BY category
),

category_contribution AS (
    SELECT
        category,
        total_revenue,
        total_revenue * 100.0 /
            SUM(total_revenue) OVER ()
            AS contribution_percent
    FROM category_performance
)

SELECT
    ROUND(SUM(contribution_percent), 2)
        AS total_contribution_percent
FROM category_contribution;

-- ============================================================
-- Master Task 9 - Advanced Hive Analytics
-- Part 6 - Promotion Performance by Category
-- ============================================================

-- ------------------------------------------------------------
-- 6A. Promotion performance by category
-- ------------------------------------------------------------

SELECT
    category,
    promotion_flag,
    COUNT(*) AS sales_events,
    SUM(quantity) AS total_quantity,
    ROUND(SUM(discount_amount), 2) AS total_discount,
    ROUND(SUM(final_price), 2) AS total_revenue,
    ROUND(AVG(final_price), 2) AS average_event_value
FROM retail_events_analytics
GROUP BY
    category,
    promotion_flag
ORDER BY
    category,
    promotion_flag;


-- ------------------------------------------------------------
-- 6B. Promotion contribution within each category
-- ------------------------------------------------------------

WITH category_promotion AS (
    SELECT
        category,
        promotion_flag,
        COUNT(*) AS sales_events,
        SUM(quantity) AS total_quantity,
        ROUND(SUM(discount_amount), 2) AS total_discount,
        ROUND(SUM(final_price), 2) AS total_revenue
    FROM retail_events_analytics
    GROUP BY
        category,
        promotion_flag
)

SELECT
    category,
    promotion_flag,
    sales_events,
    total_quantity,
    total_discount,
    total_revenue,
    ROUND(
        total_revenue * 100.0 /
        SUM(total_revenue) OVER (
            PARTITION BY category
        ),
        2
    ) AS category_revenue_percent
FROM category_promotion
ORDER BY
    category,
    promotion_flag;


-- ------------------------------------------------------------
-- 6C. Promotional category ranking
-- ------------------------------------------------------------

WITH promoted_category_performance AS (
    SELECT
        category,
        COUNT(*) AS promotional_sales_events,
        SUM(quantity) AS promotional_quantity,
        ROUND(SUM(discount_amount), 2) AS total_discount,
        ROUND(SUM(final_price), 2) AS promotional_revenue,
        ROUND(AVG(final_price), 2) AS average_promotional_event_value
    FROM retail_events_analytics
    WHERE promotion_flag = 'Y'
    GROUP BY category
)

SELECT
    category,
    promotional_sales_events,
    promotional_quantity,
    total_discount,
    promotional_revenue,
    average_promotional_event_value,
    RANK() OVER (
        ORDER BY promotional_revenue DESC
    ) AS promotional_revenue_rank
FROM promoted_category_performance
ORDER BY promotional_revenue_rank;


-- ------------------------------------------------------------
-- 6D. Promotional and non-promotional value comparison
-- ------------------------------------------------------------

WITH promotion_comparison AS (
    SELECT
        category,

        ROUND(
            AVG(
                CASE
                    WHEN promotion_flag = 'Y'
                    THEN final_price
                END
            ),
            2
        ) AS promotional_average_value,

        ROUND(
            AVG(
                CASE
                    WHEN promotion_flag = 'N'
                    THEN final_price
                END
            ),
            2
        ) AS non_promotional_average_value,

        SUM(
            CASE
                WHEN promotion_flag = 'Y'
                THEN quantity
                ELSE 0
            END
        ) AS promotional_quantity,

        SUM(
            CASE
                WHEN promotion_flag = 'N'
                THEN quantity
                ELSE 0
            END
        ) AS non_promotional_quantity

    FROM retail_events_analytics
    GROUP BY category
)

SELECT
    category,
    promotional_average_value,
    non_promotional_average_value,
    promotional_quantity,
    non_promotional_quantity,
    ROUND(
        promotional_average_value -
        non_promotional_average_value,
        2
    ) AS average_value_difference
FROM promotion_comparison
ORDER BY average_value_difference DESC;

-- ============================================================
-- Master Task 9 - Advanced Hive Analytics
-- Part 7 - Store Ranking and Performance Deviation
-- ============================================================

-- ------------------------------------------------------------
-- 7A. Store revenue ranking
-- ------------------------------------------------------------

WITH store_performance AS (
    SELECT
        store_id,
        store_city,
        province,
        store_region,
        COUNT(*) AS total_transactions,
        SUM(total_quantity) AS total_quantity,
        ROUND(SUM(transaction_value), 2) AS total_revenue,
        ROUND(AVG(transaction_value), 2) AS average_transaction_value
    FROM transaction_summary
    GROUP BY
        store_id,
        store_city,
        province,
        store_region
)

SELECT
    store_id,
    store_city,
    province,
    store_region,
    total_transactions,
    total_quantity,
    total_revenue,
    average_transaction_value,
    RANK() OVER (
        ORDER BY total_revenue DESC
    ) AS revenue_rank
FROM store_performance
ORDER BY revenue_rank;


-- ------------------------------------------------------------
-- 7B. Store revenue deviation from overall average
-- ------------------------------------------------------------

WITH store_performance AS (
    SELECT
        store_id,
        store_city,
        province,
        store_region,
        COUNT(*) AS total_transactions,
        ROUND(SUM(transaction_value), 2) AS total_revenue,
        ROUND(AVG(transaction_value), 2) AS average_transaction_value
    FROM transaction_summary
    GROUP BY
        store_id,
        store_city,
        province,
        store_region
),

store_comparison AS (
    SELECT
        store_id,
        store_city,
        province,
        store_region,
        total_transactions,
        total_revenue,
        average_transaction_value,
        ROUND(
            AVG(total_revenue) OVER (),
            2
        ) AS overall_average_store_revenue
    FROM store_performance
)

SELECT
    store_id,
    store_city,
    province,
    store_region,
    total_transactions,
    total_revenue,
    overall_average_store_revenue,

    ROUND(
        total_revenue - overall_average_store_revenue,
        2
    ) AS revenue_deviation,

    ROUND(
        (
            total_revenue - overall_average_store_revenue
        ) * 100.0 / overall_average_store_revenue,
        2
    ) AS deviation_percent,

    CASE
        WHEN total_revenue > overall_average_store_revenue
            THEN 'Above Average'
        WHEN total_revenue < overall_average_store_revenue
            THEN 'Below Average'
        ELSE 'Average'
    END AS performance_status

FROM store_comparison
ORDER BY revenue_deviation DESC;


-- ------------------------------------------------------------
-- 7C. Store ranking within each region
-- ------------------------------------------------------------

WITH store_performance AS (
    SELECT
        store_id,
        store_city,
        province,
        store_region,
        COUNT(*) AS total_transactions,
        ROUND(SUM(transaction_value), 2) AS total_revenue,
        ROUND(AVG(transaction_value), 2) AS average_transaction_value
    FROM transaction_summary
    GROUP BY
        store_id,
        store_city,
        province,
        store_region
)

SELECT
    store_region,
    store_id,
    store_city,
    total_transactions,
    total_revenue,
    average_transaction_value,

    RANK() OVER (
        PARTITION BY store_region
        ORDER BY total_revenue DESC
    ) AS regional_revenue_rank

FROM store_performance
ORDER BY
    store_region,
    regional_revenue_rank;