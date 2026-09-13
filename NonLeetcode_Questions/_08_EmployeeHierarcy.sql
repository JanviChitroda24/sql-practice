-- You have a table called employees:

-- employees
-- ├── employee_id    INT (PK)
-- ├── employee_name  VARCHAR(100)
-- ├── manager_id     INT (nullable, references employee_id)
-- ├── department     VARCHAR(50)

-- The CEO has manager_id = NULL. 
-- Write a query that returns every employee along with their full management chain — their direct manager, 
--     their manager's manager, and so on up to the CEO. 
-- Return employee_id, employee_name, manager_name, and level (CEO = level 1, their direct reports = level 2, etc.).

WITH RECURSIVE base_hierarchy AS (
    SELECT employee_id,  employee_name, manager_id, department, 1 AS lvl
    FROM employees
    WHERE manager_id IS NULL

    UNION ALL 

    SELECT e.employee_id, e.employee_name, e.manager_id, e.department, lvl+1
    FROM base_hierarchy bh JOIN employees e 
        ON bh.employee_id = e.manager_id
)
SELECT bh.employee_id, bh.employee_name, e.employee_name AS manager_name, bh.lvl AS `level`
FROM base_hierarchy bh LEFT JOIN employees e  
    ON bh.manager_id = e.employee_id;