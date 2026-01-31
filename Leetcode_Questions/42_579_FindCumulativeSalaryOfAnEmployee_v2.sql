-- 579. Find Cumulative Salary of an Employee
-- https://leetcode.com/problems/find-cumulative-salary-of-an-employee/

-- Problem Summary
-- For each employee, calculate the 3-month cumulative salary excluding the most recent month.

-- Cumulative = sum of current month + previous 2 months
-- Exclude the employee's most recent month from the output entirely
-- Order by id ASC, month DESC


-- Schema
-- Employee table:
-- +----+-------+--------+
-- | id | month | salary |
-- +----+-------+--------+
-- | 1  | 1     | 20     |
-- | 2  | 1     | 20     |
-- | 1  | 2     | 30     |
-- | 2  | 2     | 30     |
-- | 3  | 2     | 40     |
-- | 1  | 3     | 40     |
-- | 3  | 3     | 60     |
-- | 1  | 4     | 60     |
-- | 3  | 4     | 70     |
-- | 1  | 7     | 90     |
-- | 1  | 8     | 90     |
-- +----+-------+--------+
-- Expected Output
-- +----+-------+--------+
-- | id | month | Salary |
-- +----+-------+--------+
-- | 1  | 7     | 210    |
-- | 1  | 4     | 130    |
-- | 1  | 3     | 90     |
-- | 1  | 2     | 50     |
-- | 1  | 1     | 20     |
-- | 2  | 1     | 20     |
-- | 3  | 3     | 100    |
-- | 3  | 2     | 40     |
-- +----+-------+--------+

WITH cum_sal AS (
    SELECT id, 
            month,
            SUM(salary) OVER(PARTITION BY id ORDER BY month ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) AS cum_salary,
            MAX(month) OVER(PARTITION BY id) AS max_month
    FROM Employee
)
SELECT id, month, cum_salary AS Salary
FROM cum_sal
WHERE month != max_month
ORDER BY id, month DESC;