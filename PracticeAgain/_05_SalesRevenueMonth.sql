-- You have a table called monthly_sales:

-- monthly_sales
-- ├── product_id     INT
-- ├── sale_month     DATE (first day of each month, e.g. '2025-01-01')
-- ├── revenue        DECIMAL(12,2)

-- Each product has one row per month. Some products may have gaps (missing months). 
-- Write a query that returns each product's revenue, its previous month's revenue, and the month-over-month growth percentage. 
-- Only include rows where the previous month's data actually exists (no NULLs in the output). 
-- Return product_id, sale_month, revenue, prev_month_revenue, and mom_growth_pct (rounded to 2 decimal places).

WITH monthly_sales_prev AS (
    SELECT product_id, sale_month, revenue,
        LAG(revenue) OVER(PARTITION BY product_id ORDER BY sale_month) AS prev_month_revenue,
        LAG(sale_month) OVER(PARTITION BY product_id ORDER BY sale_month) AS prev_month
    FROM monthly_sales
)
SELECT product_id, sale_month, revenue, prev_month_revenue, 
    ROUND( ((revenue-prev_month_revenue)*100.0)/prev_month_revenue ,2) AS mom_growth_pct
FROM monthly_sales_prev
WHERE prev_month = DATE_SUB(sale_month, INTERVAL 1 MONTH);