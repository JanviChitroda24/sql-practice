-- **Q3**

-- You have two tables:

-- ```
-- employees
-- ├── employee_id    INT (PK)
-- ├── employee_name  VARCHAR(100)
-- ├── salary         DECIMAL(10,2)
-- ├── manager_id     INT (nullable, references employee_id)
-- ```

-- Some employees have no manager (manager_id is NULL — these are top-level execs). 
-- Write a query that returns employees who earn more than their manager. 
-- Return the employee's name, their salary, their ≈'s name, and their manager's salary.

SELECT e.employee_name AS employee_name, e.salary AS employee_salary, m.employee_name AS manager_name, m.salary AS manager_salary
FROM employees e JOIN employees m 
    ON e.manager_id = m.employee_id
WHERE e.salary > m.salary;