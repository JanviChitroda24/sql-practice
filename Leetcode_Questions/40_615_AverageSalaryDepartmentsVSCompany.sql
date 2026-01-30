-- 615. Average Salary: Departments VS Company
-- https://leetcode.ca/all/615.html
-- 615. Average Salary: Departments VS Company
-- Given two tables as below, write a query to display the comparison result (higher/lower/same) of the average salary of employees in a department to the company's average salary.
 

-- Table: salary
-- | id | employee_id | amount | pay_date   |
-- |----|-------------|--------|------------|
-- | 1  | 1           | 9000   | 2017-03-31 |
-- | 2  | 2           | 6000   | 2017-03-31 |
-- | 3  | 3           | 10000  | 2017-03-31 |
-- | 4  | 1           | 7000   | 2017-02-28 |
-- | 5  | 2           | 6000   | 2017-02-28 |
-- | 6  | 3           | 8000   | 2017-02-28 |
 

-- The employee_id column refers to the employee_id in the following table employee.

-- Table: employee
-- | employee_id | department_id |
-- |-------------|---------------|
-- | 1           | 1             |
-- | 2           | 2             |
-- | 3           | 2             |
 

-- So for the sample data above, the result is:
 
-- OUTPUT TABLE:
-- | pay_month | department_id | comparison  |
-- |-----------|---------------|-------------|
-- | 2017-03   | 1             | higher      |
-- | 2017-03   | 2             | lower       |
-- | 2017-02   | 1             | same        |
-- | 2017-02   | 2             | same        |
 

WITH emp_sal AS (
    SELECT  DATE_FORMAT(s.pay_date, '%Y-%m') AS pay_month, 
            e.department_id,
            s.amount,
            AVG(s.amount) OVER(PARTITION BY pay_month, e.department_id) AS dept_avg,
            AVG(s.amount) OVER(PARTITION BY pay_month) AS company_avg
    FROM salary s JOIN employee e 
    ON s.employee_id = e.employee_id
)
SELECT DISTINCT pay_month, department_id, 
    CASE 
        WHEN dept_avg=company_avg THEN 'same'
        WHEN dept_avg>company_avg THEN 'higher'
        ELSE 'lower'
    END AS comparison
FROM emp_sal
ORDER BY pay_month DESC, department_id;

-- DISTINCT typically:
--     Performs sorting or hashing
--     Adds extra pass over data

-- So:
--     Adds O(n log n) (sorting) or O(n) (hash-based)

-- Optimal solution

-- ROW_NUMBER assigns a sequence within each partition, so I can select exactly one row per group using rn = 1. 
-- This avoids using DISTINCT, which would require an additional deduplication step.

WITH emp_sal AS (
    SELECT
        DATE_FORMAT(s.pay_date, '%Y-%m') AS pay_month,
        e.department_id,
        AVG(s.amount) OVER(PARTITION BY DATE_FORMAT(s.pay_date, '%Y-%m')) AS comp_avg,
        AVG(s.amount) OVER(PARTITION BY DATE_FORMAT(s.pay_date, '%Y-%m'), e.department_id) AS dept_avg,
        ROW_NUMBER() OVER(PARTITION BY DATE_FORMAT(s.pay_date, '%Y-%m'), e.department_id) AS rn
    FROM salary s JOIN employee e
    ON s.employee_id = e.employee_id
)
SELECT pay_month, 
    e.department_id,
    CASE 
        WHEN dept_avg = comp_avg THEN 'same'
        WHEN dept_avg > comp_avg THEN 'higher'
        ELSE 'lower'
    END AS comparison
FROM emp_sal
WHERE rn=1
ORDER BY pay_month DESC, department_id;

-- “Column aliases defined in SELECT cannot be reused within the same SELECT 
--     because SQL evaluates expressions simultaneously. 
--     To reuse them, I use a CTE or subquery.”