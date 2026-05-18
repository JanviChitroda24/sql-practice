-- 185. Department Top Three Salaries
-- https://leetcode.com/problems/department-top-three-salaries/description/

-- Table: Employee

-- +--------------+---------+
-- | Column Name  | Type    |
-- +--------------+---------+
-- | id           | int     |
-- | name         | varchar |
-- | salary       | int     |
-- | departmentId | int     |
-- +--------------+---------+
-- id is the primary key (column with unique values) for this table.
-- departmentId is a foreign key (reference column) of the ID from the Department table.
-- Each row of this table indicates the ID, name, and salary of an employee. It also contains the ID of their department.
 

-- Table: Department

-- +-------------+---------+
-- | Column Name | Type    |
-- +-------------+---------+
-- | id          | int     |
-- | name        | varchar |
-- +-------------+---------+
-- id is the primary key (column with unique values) for this table.
-- Each row of this table indicates the ID of a department and its name.
 

-- A company's executives are interested in seeing who earns the most money in each of the company's departments. A high earner in a department is an employee who has a salary in the top three unique salaries for that department.

-- Write a solution to find the employees who are high earners in each of the departments.

-- Return the result table in any order.

-- The result format is in the following example.

 

-- Example 1:

-- Input: 
-- Employee table:
-- +----+-------+--------+--------------+
-- | id | name  | salary | departmentId |
-- +----+-------+--------+--------------+
-- | 1  | Joe   | 85000  | 1            |
-- | 2  | Henry | 80000  | 2            |
-- | 3  | Sam   | 60000  | 2            |
-- | 4  | Max   | 90000  | 1            |
-- | 5  | Janet | 69000  | 1            |
-- | 6  | Randy | 85000  | 1            |
-- | 7  | Will  | 70000  | 1            |
-- +----+-------+--------+--------------+
-- Department table:
-- +----+-------+
-- | id | name  |
-- +----+-------+
-- | 1  | IT    |
-- | 2  | Sales |
-- +----+-------+
-- Output: 
-- +------------+----------+--------+
-- | Department | Employee | Salary |
-- +------------+----------+--------+
-- | IT         | Max      | 90000  |
-- | IT         | Joe      | 85000  |
-- | IT         | Randy    | 85000  |
-- | IT         | Will     | 70000  |
-- | Sales      | Henry    | 80000  |
-- | Sales      | Sam      | 60000  |
-- +------------+----------+--------+
-- Explanation: 
-- In the IT department:
-- - Max earns the highest unique salary
-- - Both Randy and Joe earn the second-highest unique salary
-- - Will earns the third-highest unique salary

-- In the Sales department:
-- - Henry earns the highest salary
-- - Sam earns the second-highest salary
-- - There is no third-highest salary as there are only two employees
 

-- Constraints:

-- There are no employees with the exact same name, salary and department.

WITH emp_dept_rank AS(
    SELECT d.name AS 'Department', 
        e.name AS 'Employee',
        e.salary AS 'Salary',
        DENSE_RANK() OVER (PARTITION BY e.departmentId ORDER BY e.salary DESC) AS rnk
    FROM Department d JOIN Employee e
        ON d.id = e.departmentId
)
SELECT Department, Employee, Salary
FROM emp_dept_rank
WHERE rnk<=3; 




-- **DENSE_RANK ranks based on the ENTIRE ORDER BY expression.
    -- ** Adding a unique column (like `id`) to the ORDER BY makes every row distinct, 
    -- so DENSE_RANK behaves like ROW_NUMBER — no ties possible. 
    -- Only include columns that define what "same rank" means.

-- **When multi-column ORDER BY in ranking is useful:**
-- - When you **want** to break ties 
    -- — e.g., "top 3 employees by salary, if tied pick the one hired earliest" 
    -- → `ROW_NUMBER() OVER (ORDER BY salary DESC, hire_date ASC)`
-- - When you need a **deterministic single winner** per group 
    -- — e.g., "one most recent order per customer" 
    -- → `ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY order_date DESC, id DESC)`

-- **When to avoid it:**
-- - When the problem says "top N values/salaries" and ties should all be included 
    -- → use `DENSE_RANK()` with only the value column in ORDER BY


-- The key insight: ranking logic and display ordering are separate concerns.
-- Use DENSE_RANK with only the salary for filtering, then control the final presentation with ORDER BY on the outer query.
WITH emp_dept_rank AS (
    SELECT d.name AS Department, 
        e.name AS Employee,
        e.salary AS Salary,
        e.id AS emp_id,
        DENSE_RANK() OVER (PARTITION BY e.departmentId ORDER BY e.salary DESC) AS rnk
    FROM Department d JOIN Employee e
        ON d.id = e.departmentId
)
SELECT Department, Employee, Salary
FROM emp_dept_rank
WHERE rnk <= 3
ORDER BY Salary DESC, emp_id DESC;