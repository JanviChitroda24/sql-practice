-- You have a table called daily_sales:

-- daily_sales
-- ├── product_id     INT
-- ├── sale_date      DATE
-- ├── units_sold     INT
-- ├── revenue        DECIMAL(12,2)

-- One row per product per day. 
-- Find all products that had 3 or more consecutive months of declining revenue. 
-- A month's revenue is the total revenue for that product in that calendar month. 
-- Return product_id, decline_start_month, decline_end_month, and consecutive_decline_months.

WITH monthly_sales AS (
    SELECT product_id, DATE_FORMAT(sale_date, '%Y-%m-01') AS sale_month,
        SUM(revenue) AS total_revenue
    FROM daily_sales
    GROUP BY product_id, DATE_FORMAT(sale_date, '%Y-%m-01')
),
monthy_sales_prev AS (
    SELECT product_id, sale_month, total_revenue, 
        LAG(total_revenue) OVER(PARTITION BY product_id ORDER BY sale_month) AS prev_revenue,
        LAG(sale_month) OVER(PARTITION BY product_id ORDER BY sale_month) AS prev_month
    FROM monthly_sales
),
sales_check AS (
    SELECT product_id, sale_month, total_revenue, prev_revenue, 
        ROW_NUMBER() OVER(PARTITION BY product_id ORDER BY sale_month) AS sales_rnk
    FROM monthy_sales_prev
    WHERE prev_month=DATE_SUB(sale_month, INTERVAL 1 MONTH) 
        AND prev_revenue > total_revenue
),
sales_group AS (
    SELECT product_id, sale_month, total_revenue, prev_revenue, sales_rnk,
        DATE_SUB(sale_month, INTERVAL sales_rnk MONTH) AS sales_date_group
    FROM sales_check
)
SELECT product_id, 
    MIN(sale_month) AS decline_start_month,
    MAX(sale_month) AS decline_end_month,
    COUNT(*) AS consecutive_decline_months
FROM sales_group 
GROUP BY product_id, sales_date_group
HAVING COUNT(*)>=3;