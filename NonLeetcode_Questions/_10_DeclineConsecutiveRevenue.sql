You have a table called daily_sales:

daily_sales
├── product_id     INT
├── sale_date      DATE
├── units_sold     INT
├── revenue        DECIMAL(12,2)

One row per product per day. 
Find all products that had 3 or more consecutive months of declining revenue. 
A month's revenue is the total revenue for that product in that calendar month. 
Return product_id, decline_start_month, decline_end_month, and consecutive_decline_months.

WITH sale_date_group AS (
    SELECT product_id, revenue,
        DATE_FORMAT(sale_date, '%Y-%m-01') AS sale_month
    FROM daily_sales
),
sale_rev_by_month AS (
    SELECT product_id, sale_month, SUM(revenue) AS revenue
    FROM sale_date_group
    GROUP BY product_id, sale_month
),
sale_prev_revenue AS (
    SELECT product_id, sale_month, revenue, 
        LAG(revenue) OVER(PARTITION BY product_id ORDER BY sale_month) AS prev_revenue
    FROM sale_rev_by_month
),
sale_decline_flag AS (
    SELECT product_id, sale_month, revenue, prev_revenue, 
        CASE 
            WHEN revenue - prev_revenue < 0 THEN 1
            ELSE 0
        END AS declince_flag,
        ROW_NUMBER() OVER(PARTITION BY product_id ORDER BY sale_month) AS overall_rn
    FROM sale_prev_revenue
),
decline_month_filter AS (
    SELECT product_id, sale_month, revenue, overall_rn,
        ROW_NUMBER() OVER(PARTITION BY product_id ORDER BY sale_month) AS decline_rn
    FROM sale_decline_flag
    WHERE declince_flag=1
),
rn_month_dff AS (
    SELECT product_id, sale_month, revenue, overall_rn, decline_rn, overall_rn-decline_rn AS mon_diff
    FROM decline_month_filter
)
SELECT product_id, 
    MIN(sale_month) AS decline_start_month, 
    MAX(sale_month) AS decline_end_month, 
    COUNT(*) AS consecutive_decline_months
FROM rn_month_dff
GROUP BY product_id, mon_diff
HAVING COUNT(*) >= 3;



