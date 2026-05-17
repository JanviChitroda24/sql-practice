-- Table: Employee
-- +-------------+---------+
-- | Column Name | Type    |
-- +-------------+---------+
-- | id          | int     |
-- | name        | varchar |
-- | salary      | int     |
-- | managerId   | int     |
-- +-------------+---------+
-- id is the primary key (column with unique values) for this table.
-- Each row of this table indicates the ID of an employee, their name, salary, and the ID of their manager.
 

-- Write a solution to find the employees who earn more than their managers.
-- Return the result table in any order.
-- The result format is in the following example.

 

-- Example 1:
-- Input: 
-- Employee table:
-- +----+-------+--------+-----------+
-- | id | name  | salary | managerId |
-- +----+-------+--------+-----------+
-- | 1  | Joe   | 70000  | 3         |
-- | 2  | Henry | 80000  | 4         |
-- | 3  | Sam   | 60000  | Null      |
-- | 4  | Max   | 90000  | Null      |
-- +----+-------+--------+-----------+
-- Output: 
-- +----------+
-- | Employee |
-- +----------+
-- | Joe      |
-- +----------+
-- Explanation: Joe is the only employee who earns more than his manager.

SELECT e.name AS Employee
FROM Employee e JOIN Employee m
    ON e.managerId = m.id
WHERE e.salary > m.salary;

-- alternative approach (exist)
SELECT e.name AS Employee
FROM Employee e
WHERE EXISTS (
    SELECT 1
    FROM Employee m 
    WHERE e.managerId = m.id AND e.salary > m.salary
);

-- For this specific problem, performance is essentially the same 
--     — most modern optimizers generate identical execution plans for both. 
--     But here's when each has an edge:

-- **JOIN** is better when you need columns from both tables in your output. 
--     It's also more readable and the default interview choice.

-- **EXISTS** is better when you only care about whether a matching row exists, not what's in it. 
--     It can short-circuit — it stops scanning as soon as it finds the first match, 
--     whereas a JOIN might produce duplicate rows if there are multiple matches 
--         (not an issue here since `managerId` maps to one manager, but matters in other problems).

-- **The real difference shows up with duplicates.** 
--     If the subquery side has many matching rows per outer row, 
--     a JOIN produces multiple rows (requiring `DISTINCT` to fix), 
--     while EXISTS returns one row naturally. 
--     That's where EXISTS wins on performance.

-- **Rule of thumb:** 
--     Use JOIN when you need data from both tables. 
--     Use EXISTS when you just need a yes/no check. 
--     For this problem, either is fine — go with JOIN for clarity.