-- You have a table called inventory_changes:

-- inventory_changes
-- ├── change_id        INT (PK)
-- ├── product_id       INT
-- ├── warehouse_id     INT
-- ├── change_date      DATE
-- ├── quantity_change  INT (positive = stock added, negative = stock removed)

-- Write a query that calculates the running inventory balance for each product in each warehouse, ordered by date. 
-- Then flag any row where the running balance goes negative (oversold). 
-- Return product_id, warehouse_id, change_date, quantity_change, running_balance, and a column called oversold_flag ('YES' or 'NO').

WITH running_changes AS (
    SELECT product_id, warehouse_id, change_date, quantity_change,
        SUM(quantity_change) OVER(PARTITION BY product_id, warehouse_id ORDER BY change_date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS running_balance 
    FROM inventory_changes 
)
SELECT product_id, warehouse_id, change_date, quantity_change, running_balance,
    CASE 
        WHEN running_balance < 0
        THEN 'YES'
        ELSE 'NO'
    END AS oversold_flag
FROM running_changes;