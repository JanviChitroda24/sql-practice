-- 615. Average Salary: Departments VS Company
-- https://leetcode.ca/all/615.html


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
 
WITH company_avg_salary AS (
    SELECT id, employee_id, amount, pay_date,
        AVG(amount) OVER(PARTITION BY pay_date) AS comp_avg_sal
    FROM salary
 ),
 department_avg_salary AS (
    SELECT c.pay_date, c.comp_avg_sal, e.department_id, AVG(amount) AS dept_avg_sal
    FROM company_avg_salary c JOIN employee e
        ON c.employee_id = e.employee_id
    GROUP BY c.pay_date, c.comp_avg_sal, e.department_id
 )
SELECT DATE_FORMAT(pay_date, '%Y-%m') AS pay_month, department_id, 
    CASE 
        WHEN dept_avg_sal=comp_avg_sal THEN 'same'
        WHEN  dept_avg_sal>comp_avg_sal THEN 'higher'
        ELSE 'lower'
    END AS comparison
FROM department_avg_salary;