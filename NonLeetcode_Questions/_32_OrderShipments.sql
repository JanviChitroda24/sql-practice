-- Q32

-- shipments
-- ├── shipment_id     INT (PK)
-- ├── order_id        INT
-- ├── warehouse_id    INT
-- ├── ship_date       DATE
-- ├── delivery_date   DATE (nullable — NULL means not yet delivered)
-- ├── carrier         VARCHAR(50)

-- Write a query that calculates for each carrier and each month: 
--     the total shipments, the average delivery time in days, 
--     the percentage of shipments delivered within 3 days, 
--     and the percentage still undelivered. 

-- Rank carriers within each month by their on-time percentage (delivered within 3 days) descending. 
-- Return month, carrier, total_shipments, avg_delivery_days, pct_on_time, pct_undelivered, and carrier_rank.

WITH monthly_shipments AS (
    SELECT DATE_FORMAT(ship_date, '%Y-%m') AS month, carrier, 
        COUNT(shipment_id) AS total_shipments,
        ROUND(AVG(DATEDIFF(delivery_date, ship_date)),2) AS avg_delivery_days, --average ignores nulls, so the average of only deleivered items
        COUNT(CASE 
                WHEN DATEDIFF(delivery_date, ship_date) <= 3
                THEN 1
            END) AS cnt_on_time, 
        COUNT(CASE 
                WHEN delivery_date IS NULL
                THEN 1
            END) AS cnt_undelivered
    FROM shipments
    GROUP BY DATE_FORMAT(ship_date, '%Y-%m'), carrier
),
shipments_pct AS (
    SELECT month, carrier, total_shipments, avg_delivery_days,
        ROUND((cnt_on_time*100.0)/total_shipments ,2) AS pct_on_time,
        ROUND((cnt_undelivered*100.0)/total_shipments ,2) AS pct_undelivered
    FROM monthly_shipments
)
SELECT month, carrier, total_shipments, avg_delivery_days, pct_on_time, pct_undelivered, 
    DENSE_RANK() OVER(PARTITION BY month ORDER BY pct_on_time DESC) AS carrier_rank
FROM shipments_pct
ORDER BY carrier_rank;