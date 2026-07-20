-- 1965. Employees With Missing Information
-- https://leetcode.com/problems/employees-with-missing-information/description/

-- Table: Employees
-- +-------------+---------+
-- | Column Name | Type    |
-- +-------------+---------+
-- | employee_id | int     |
-- | name        | varchar |
-- +-------------+---------+
-- employee_id is the column with unique values for this table.
-- Each row of this table indicates the name of the employee whose ID is employee_id.
 

-- Table: Salaries
-- +-------------+---------+
-- | Column Name | Type    |
-- +-------------+---------+
-- | employee_id | int     |
-- | salary      | int     |
-- +-------------+---------+
-- employee_id is the column with unique values for this table.
-- Each row of this table indicates the salary of the employee whose ID is employee_id.
 

-- Write a solution to report the IDs of all the employees with missing information. The information of an employee is missing if:

-- The employee's name is missing, or
-- The employee's salary is missing.
-- Return the result table ordered by employee_id in ascending order.

-- The result format is in the following example.

 

-- Example 1:

-- Input: 
-- Employees table:
-- +-------------+----------+
-- | employee_id | name     |
-- +-------------+----------+
-- | 2           | Crew     |
-- | 4           | Haven    |
-- | 5           | Kristian |
-- +-------------+----------+
-- Salaries table:
-- +-------------+--------+
-- | employee_id | salary |
-- +-------------+--------+
-- | 5           | 76071  |
-- | 1           | 22517  |
-- | 4           | 63539  |
-- +-------------+--------+
-- Output: 
-- +-------------+
-- | employee_id |
-- +-------------+
-- | 1           |
-- | 2           |
-- +-------------+
-- Explanation: 
-- Employees 1, 2, 4, and 5 are working at this company.
-- The name of employee 1 is missing.
-- The salary of employee 2 is missing.

WITH all_missing_emp AS (
    SELECT e.employee_id
    FROM Employees e LEFT JOIN Salaries s
        ON e.employee_id = s.employee_id
    WHERE e.employee_id IS NULL OR s.salary IS NULL
    UNION 
    SELECT s.employee_id
    FROM Salaries s LEFT JOIN Employees e
        ON e.employee_id = s.employee_id
    WHERE e.name IS NULL OR s.salary IS NULL
)
SELECT *
FROM all_missing_emp
ORDER BY employee_id;

-- alternate
WITH all_missing_emp AS (
    SELECT e.employee_id
    FROM Employees e LEFT JOIN Salaries s
        ON e.employee_id = s.employee_id
    WHERE s.employee_id IS NULL      -- fixed: check the OTHER table's key
    UNION 
    SELECT s.employee_id
    FROM Salaries s LEFT JOIN Employees e
        ON e.employee_id = s.employee_id
    WHERE e.employee_id IS NULL      -- this one was already correct
)
SELECT * FROM all_missing_emp 
ORDER BY employee_id;