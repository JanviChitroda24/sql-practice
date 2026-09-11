-- You have a table called monthly_sales:

-- monthly_sales
-- ├── product_id     INT
-- ├── sale_month     DATE (first day of each month, e.g. '2025-01-01')
-- ├── revenue        DECIMAL(12,2)

-- Each product has one row per month. Some products may have gaps (missing months). 
-- Write a query that returns each product's revenue, its previous month's revenue, and the month-over-month growth percentage. 
-- Only include rows where the previous month's data actually exists (no NULLs in the output). 
-- Return product_id, sale_month, revenue, prev_month_revenue, and mom_growth_pct (rounded to 2 decimal places).


-- naive approach
-- WITH lag_monthly_sales AS (
--     SELECT product_id, sale_month, revenue,
--         LAG(sale_month) OVER(PARTITION BY product_id ORDER BY sale_month) AS actual_prev_month,
--         DATE_SUB(sale_month, INTERVAL 1 MONTH) AS ideal_prev_month
--     FROM monthly_sales
-- ),
-- monthly_sales_filtered AS (
--     SELECT product_id, sale_month, revenue, actual_prev_month AS prev_month
--     FROM lag_monthly_sales
--     WHERE actual_prev_month = ideal_prev_month
-- )
-- SELECT mon.product_id, mon.sale_month, mon.revenue, 
--     prev_mon.revenue AS prev_month_revenue, 
--     ROUND(((mon.revenue - prev_mon.revenue)/prev_mon.revenue),2) AS mom_growth_pct
-- FROM monthly_sales_filtered mon JOIN monthly_sales_filtered prev_mon 
--     ON mon.product_id = prev_mon.product_id AND mon.prev_month = prev_mon.sale_month;

--- 
WITH lag_monthly_sales AS (
    SELECT product_id, sale_month, revenue,
        LAG(revenue) OVER(PARTITION BY product_id ORDER BY sale_month) AS prev_month_revenue,
        LAG(sale_month) OVER(PARTITION BY product_id ORDER BY sale_month) AS prev_month_date,
        DATE_SUB(sale_month, INTERVAL 1 MONTH) AS ideal_prev_month
    FROM monthly_sales
)
SELECT product_id, sale_month, revenue, prev_month_revenue,
    ROUND( (revenue-prev_month_revenue)/prev_month_revenue ,2) AS mom_growth_pct
FROM lag_monthly_sales
WHERE prev_month_date = ideal_prev_month;
