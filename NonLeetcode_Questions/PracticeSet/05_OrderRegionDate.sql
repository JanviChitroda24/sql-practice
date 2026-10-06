-- The client's finance team wants a monthly revenue report. We have:

-- orders(order_id, customer_id, region, order_date, amount, status)

-- For each region and month, return:

-- total revenue from completed orders
-- the previous month's revenue
-- month-over-month growth as a percentage
-- year-to-date cumulative revenue

WITH orders_grp_region AS (
    SELECT region, DATE_FORMAT(order_date, '%Y-%m-01') AS order_month,
        SUM(CASE 
                WHEN status = 'Completed'
                THEN amount
                ELSE 0
        END) AS total_revenue
    FROM orders
    GROUP BY region, DATE_FORMAT(order_date, '%Y-%m-01')
),
orders_prev_month AS (
    SELECT region, order_month, total_revenue,
        LAG(total_revenue) OVER(PARTITION BY region ORDER BY order_month) AS prev_month_revenue,
    SUM(total_revenue) OVER( 
                        PARTITION BY region, YEAR(order_month) 
                        ORDER BY order_month 
                        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS year_to_date_revenue
    FROM orders_grp_region
)
SELECT region, order_month, total_revenue, prev_month_revenue, 
    ROUND( ( (total_revenue-prev_month_revenue) *100.0)/NULLIF(prev_month_revenue, 0) ,2) AS mom_growth_pct,
    year_to_date_revenue
FROM orders_prev_month;