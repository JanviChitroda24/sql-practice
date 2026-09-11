-- You have a table called sales:

-- sales
-- ├── sale_id        INT (PK)
-- ├── product_id     INT
-- ├── category       VARCHAR(50)
-- ├── quantity        INT
-- ├── unit_price     DECIMAL(10,2)
-- ├── sale_date      DATE

-- A product can appear in multiple rows (multiple sales over time). 
-- Write a query that returns the top 3 products by total revenue within each category. 
-- Revenue is quantity × unit_price. If two products have the same total revenue within a category, 
--     they should share the same rank and both appear. Return category, product_id, total_revenue, and the rank.

WITH products_grouped AS (
    SELECT category, product_id, SUM(quantity*unit_price) AS total_revenue
    FROM sales
    GROUP BY category, product_id
),
products_ranked AS (
    SELECT category, product_id, total_revenue,
    DENSE_RANK() OVER(PARTITION BY category ORDER BY total_revenue DESC) AS `rank`
    FROM products_grouped
)
SELECT category, product_id, total_revenue, `rank`
FROM products_ranked
WHERE `rank` < 4;