-- 1978. Employees Whose Manager Left the Company

-- Table: Employees

-- +-------------+----------+
-- | Column Name | Type     |
-- +-------------+----------+
-- | employee_id | int      |
-- | name        | varchar  |
-- | manager_id  | int      |
-- | salary      | int      |
-- +-------------+----------+
-- In SQL, employee_id is the primary key for this table.
-- This table contains information about the employees, their salary, and the ID of their manager. Some employees do not have a manager (manager_id is null). 
 

-- Find the IDs of the employees whose salary is strictly less than $30000 and whose manager left the company. 
-- When a manager leaves the company, their information is deleted from the Employees table, but the reports still have their manager_id set to the manager that left.
-- Return the result table ordered by employee_id.

-- The result format is in the following example.

 

-- Example 1:

-- Input:  
-- Employees table:
-- +-------------+-----------+------------+--------+
-- | employee_id | name      | manager_id | salary |
-- +-------------+-----------+------------+--------+
-- | 3           | Mila      | 9          | 60301  |
-- | 12          | Antonella | null       | 31000  |
-- | 13          | Emery     | null       | 67084  |
-- | 1           | Kalel     | 11         | 21241  |
-- | 9           | Mikaela   | null       | 50937  |
-- | 11          | Joziah    | 6          | 28485  |
-- +-------------+-----------+------------+--------+
-- Output: 
-- +-------------+
-- | employee_id |
-- +-------------+
-- | 11          |
-- +-------------+

-- Explanation: 
-- The employees with a salary less than $30000 are 1 (Kalel) and 11 (Joziah).
-- Kalel's manager is employee 11, who is still in the company (Joziah).
-- Joziah's manager is employee 6, who left the company because there is no row for employee 6 as it was deleted.

SELECT employee_id
FROM Employees
WHERE salary < 30000 
    AND manager_id IS NOT NULL 
    AND manager_id NOT IN (
        SELECT employee_id
        FROM Employees
    )
ORDER BY employee_id;

-- ALTERNATE self join 
SELECT e.employee_id
FROM Employees e LEFT JOIN Employees m
    ON e.manager_id = m.employee_id
WHERE e.salary < 30000 
    AND e.manager_id IS NOT NULL 
    AND m.employee_id IS NULL
ORDER BY employee_id;

-- ALTERNATE exists
SELECT e.employee_id
FROM Employees e
WHERE e.salary < 30000 
    AND e.manager_id IS NOT NULL 
    AND NOT EXISTS (
        SELECT 1 FROM Employees m WHERE m.employee_id = e.manager_id
    )
ORDER BY employee_id;


-- ## Anti-join: 3 ways to find "no matching row exists" — comparison

-- 1. NOT IN (subquery)
--    → shortest to write, but UNSAFE if subquery column can ever be NULL
--      (silently returns 0 rows for the whole query — no error)
--    → safe here only because employee_id is a PK (guaranteed NOT NULL)

-- 2. LEFT JOIN ... WHERE m.col IS NULL
--    → NULL-safe, no landmine regardless of column nullability
--    → computes the full join first, then filters — slightly more work
--      than NOT EXISTS in principle, though optimizer often equalizes it

-- 3. NOT EXISTS (correlated subquery)
--    → NULL-safe, same as LEFT JOIN
--    → can short-circuit: stops at first match found, doesn't need
--      to materialize a full join
--    → generally the safest DEFAULT choice for anti-joins

-- Rule: reach for NOT EXISTS or LEFT JOIN/IS NULL by default.
-- Only use NOT IN once you've confirmed the subquery column can't be NULL.