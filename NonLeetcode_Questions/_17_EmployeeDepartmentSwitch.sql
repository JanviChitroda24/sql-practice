-- You have a table called employee_transfers:

-- employee_transfers
-- ├── transfer_id      INT (PK)
-- ├── employee_id      INT
-- ├── from_department  VARCHAR(50)
-- ├── to_department    VARCHAR(50)
-- ├── transfer_date    DATE

-- Each row represents an employee moving from one department to another. 
-- Write a query that finds departments with a net negative headcount change 
--     — meaning more people left than joined. 
-- Return department_name, employees_gained, employees_lost, and net_change. 
-- Include all departments that appear in either from_department or to_department.

WITH dept_count AS (
    SELECT to_department AS department_name, COUNT(*) AS employees_gained, 0 AS employees_lost
    FROM employee_transfers
    GROUP BY to_department
    UNION ALL
    SELECT from_department AS department_name, 0 AS employees_gained, COUNT(*) AS employees_lost
    FROM employee_transfers
    GROUP BY from_department
)
SELECT department_name, SUM(employees_gained) AS employees_gained, SUM(employees_lost) AS employees_lost,
    SUM(employees_gained)-SUM(employees_lost) AS net_change
FROM dept_count
GROUP BY department_name
HAVING SUM(employees_gained)-SUM(employees_lost) < 0;