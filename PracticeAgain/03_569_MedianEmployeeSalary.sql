-- 569. Median Employee Salary
-- https://leetcode.ca/all/569.html

-- The Employee table holds all employees. The employee table has three columns: Employee Id, Company Name, and Salary.

-- +-----+------------+--------+
-- |Id   | Company    | Salary |
-- +-----+------------+--------+
-- |1    | A          | 2341   |
-- |2    | A          | 341    |
-- |3    | A          | 15     |
-- |4    | A          | 15314  |
-- |5    | A          | 451    |
-- |6    | A          | 513    |
-- |7    | B          | 15     |
-- |8    | B          | 13     |
-- |9    | B          | 1154   |
-- |10   | B          | 1345   |
-- |11   | B          | 1221   |
-- |12   | B          | 234    |
-- |13   | C          | 2345   |
-- |14   | C          | 2645   |
-- |15   | C          | 2645   |
-- |16   | C          | 2652   |
-- |17   | C          | 65     |
-- +-----+------------+--------+

-- Write a SQL query to find the median salary of each company. Bonus points if you can solve it without using any built-in SQL functions.

-- +-----+------------+--------+
-- |Id   | Company    | Salary |
-- +-----+------------+--------+
-- |5    | A          | 451    |
-- |6    | A          | 513    |
-- |12   | B          | 234    |
-- |9    | B          | 1154   |
-- |14   | C          | 2645   |
-- +-----+------------+--------+

-- USING COUNT(), ROW_NUMBER() AND % APPROACH
WITH emp_rank AS (
    SELECT Id, Company, Salary,
        COUNT(Id) OVER(PARTITION BY Company) AS emp_cnt,
        ROW_NUMBER() OVER(PARTITION BY Company ORDER BY Salary) AS salary_rnk
    FROM Employee
)
SELECT Id, Company, Salary
FROM emp_rank
WHERE (emp_cnt%2=0 AND (salary_rnk=emp_cnt/2 OR salary_rnk=emp_cnt/2+1))
    OR (emp_cnt%2!=0 AND salary_rnk=FLOOR(emp_cnt/2)+1);

-- WITHOUT % APPRAOCH
WITH emp_rank AS (
    SELECT Id, Company, Salary,
        COUNT(Id) OVER(PARTITION BY Company) AS emp_cnt,
        ROW_NUMBER() OVER(PARTITION BY Company ORDER BY Salary) AS salary_rnk
    FROM Employee
)
SELECT Id, Company, Salary
FROM emp_rank
WHERE salary_rnk IN (FLOOR((emp_cnt+1)/2), CEIL( (emp_cnt+1)/2 ));