-- Q34

-- warehouse_inventory
-- ├── record_id       INT (PK)
-- ├── product_id      INT
-- ├── warehouse_id    INT
-- ├── record_date     DATE
-- ├── quantity_on_hand INT
-- ├── reorder_level   INT

-- One row per product per warehouse per day. 
-- Write a query that finds products that have been continuously 
--     below their reorder level for 7 or more consecutive days in any warehouse. 

-- Return product_id, warehouse_id, below_reorder_start_date, below_reorder_end_date, and consecutive_days_below.

WITH inventory_below AS (
    SELECT record_id, product_id, warehouse_id, record_date, quantity_on_hand, reorder_level, 
        CASE 
            WHEN quantity_on_hand < reorder_level
            THEN 1
            ELSE 0
        END AS below_level
    FROM warehouse_inventory
),
inventory_below_filter AS (
    SELECT product_id, warehouse_id, record_date
    FROM inventory_below
    WHERE below_level = 1
),
inventory_rn AS (
    SELECT product_id, warehouse_id, record_date,
        ROW_NUMBER() OVER(PARTITION BY product_id, warehouse_id ORDER BY record_date ) AS inv_rn
    FROM inventory_below_filter
),
inventory_date_groups AS (
    SELECT product_id, warehouse_id, record_date,
        DATE_SUB(record_date, INTERVAL inv_rn DAY) AS inv_date_grp
    FROM inventory_rn
)
SELECT product_id, warehouse_id, 
    MIN(record_date) AS below_reorder_start_date, 
    MAX(record_date) AS below_reorder_end_date,
    COUNT(*) AS consecutive_days_below
FROM inventory_date_groups
GROUP BY product_id, warehouse_id, inv_date_grp
HAVING COUNT(*) >= 7;