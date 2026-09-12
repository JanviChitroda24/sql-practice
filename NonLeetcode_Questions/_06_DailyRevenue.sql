-- You have a table called daily_revenue:

-- daily_revenue
-- ├── revenue_date   DATE (PK)
-- ├── revenue        DECIMAL(12,2)

-- One row per day, no gaps. 
-- Write a query that returns each day's revenue along with the rolling 7-day average revenue 
-- (current day + 6 preceding days). 
-- Then flag any day where the revenue is more than 3 times the rolling average OR less than one-third of the rolling average. 
-- Return revenue_date, revenue, rolling_7d_avg (rounded to 2 decimals), and a column called anomaly_flag that shows 'HIGH', 'LOW', or 'NORMAL'.

WITH rolling_revenue AS(
    SELECT revenue_date, revenue, 
        AVG(revenue) OVER(ORDER BY revenue_date ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) AS rolling_7d_avg
    FROM daily_revenue
)
SELECT revenue_date, revenue, rolling_7d_avg, 
    CASE 
        WHEN revenue >  3*rolling_7d_avg
        THEN 'HIGH'
        WHEN revenue < 1.0/3 * rolling_7d_avg
        THEN 'LOW'
        ELSE 'NORMAL'
    END AS anomaly_flag
FROM rolling_revenue;