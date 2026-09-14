-- Q11

-- You have a table called department_salaries:

-- department_salaries
-- ├── employee_id     INT (PK)
-- ├── employee_name   VARCHAR(100)
-- ├── department      VARCHAR(50)
-- ├── salary          DECIMAL(10,2)
-- ├── hire_date       DATE

-- Write a query that returns the second-highest salary in each department. 
-- If a department has only one employee, exclude that department from the results. 
-- If multiple employees share the highest salary, 
--     the second-highest is the next distinct salary below that. 
-- Return department, second_highest_salary, 
--     and the number of employees earning that salary.


WITH emp_dep_ranking AS (
    SELECT department, salary, 
        DENSE_RANK() OVER(PARTITION BY department ORDER BY salary DESC) AS sal_rank
    FROM department_salaries
)
SELECT department, salary AS second_highest_salary, COUNT(sal_rank)
FROM emp_dep_ranking
WHERE sal_rank=2
GROUP BY department, salary;