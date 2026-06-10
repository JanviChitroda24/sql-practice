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

WITH emp_salary_rank AS (
    SELECT Id, Company, Salary,
        ROW_NUMBER() OVER(PARTITION BY Company ORDER BY Salary) AS emp_rank,
        COUNT(Id) OVER(PARTITION BY Company) AS emp_count
    FROM Employee
)
SELECT Id, Company, Salary
FROM emp_salary_rank 
WHERE emp_rank BETWEEN FLOOR((emp_count+1)/2) AND CEIL((emp_count+1)/2);

-- Key formula to memorize: 
--     Median positions are FLOOR((n+1)/2) to CEIL((n+1)/2). 
--     Odd n gives one row, even n gives two. Works every time.

WITH emp_salary_rank AS (
    SELECT Id, Company, Salary,
        ROW_NUMBER() OVER(PARTITION BY Company ORDER BY Salary) AS emp_rank_asc,
        ROW_NUMBER() OVER(PARTITION BY Company ORDER BY Salary DESC) AS emp_rank_desc
    FROM Employee
)
SELECT Id, Company, Salary
FROM emp_salary_rank 
WHERE ABS(emp_rank_asc-emp_rank_desc) <= 1;

-- In MySQL, CAST(... AS SIGNED) gives you an integer. 
-- There's no INT type in MySQL's CAST — you use SIGNED or UNSIGNED.

-- PostgreSQL and SQL Server support CAST(... AS INT).