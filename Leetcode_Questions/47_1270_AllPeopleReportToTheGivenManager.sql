-- 1270 — All People Report to the Given Manager
-- https://leetcode.ca/all/1270.html
-- SQL Schema 
-- Table: Employees

-- +---------------+---------+
-- | Column Name   | Type    |
-- +---------------+---------+
-- | employee_id   | int     |
-- | employee_name | varchar |
-- | manager_id    | int     |
-- +---------------+---------+
-- employee_id is the primary key for this table.
-- Each row of this table indicates that the employee with ID employee_id and name employee_name reports his work to his/her direct manager with manager_id
-- The head of the company is the employee with employee_id = 1.
 

-- Write an SQL query to find employee_id of all employees that directly or indirectly report their work to the head of the company.Programming

-- The indirect relation between managers will not exceed 3 managers as the company is small.

-- Return result table in any order without duplicates.

-- The query result format is in the following example:

-- Employees table:
-- +-------------+---------------+------------+
-- | employee_id | employee_name | manager_id |
-- +-------------+---------------+------------+
-- | 1           | Boss          | 1          |
-- | 3           | Alice         | 3          |
-- | 2           | Bob           | 1          |
-- | 4           | Daniel        | 2          |
-- | 7           | Luis          | 4          |
-- | 8           | Jhon          | 3          |
-- | 9           | Angela        | 8          |
-- | 77          | Robert        | 1          |
-- +-------------+---------------+------------+

-- Result table:
-- +-------------+
-- | employee_id |
-- +-------------+
-- | 2           |
-- | 77          |
-- | 4           |
-- | 7           |
-- +-------------+

-- The head of the company is the employee with employee_id 1.
-- The employees with employee_id 2 and 77 report their work directly to the head of the company.
-- The employee with employee_id 4 report his work indirectly to the head of the company 4 --> 2 --> 1.
-- The employee with employee_id 7 report his work indirectly to the head of the company 7 --> 4 --> 2 --> 1.
-- The employees with employee_id 3, 8 and 9 don't report their work to head of company directly or indirectly.

WITH RECURSIVE emp_man AS (
    SELECT employee_id, employee_name, manager_id
    FROM Employees
    WHERE employee_id!=1 AND manager_id=1

    UNION ALL 

    SELECT e.employee_id, e.employee_name, e.manager_id
    FROM emp_man em JOIN Employees e 
        ON em.employee_id = e.manager_id
)
SELECT employee_id
FROM emp_man;

-- Step 1: Identify the PatternAsk yourself:
--     Is this a parent-child relationship? (employee → manager, node → parent)
--     Do I need to traverse multiple levels?
--     Is the depth unknown?
--     If yes → Recursive CTE

-- Step 2: Find Your Anchor
--     Ask: Where do I start?
--     Problem SaysAnchor Condition"Reports to employee 1"WHERE manager_id = 1"Find all descendants of X"WHERE parent_id = X"Start from root"WHERE parent_id IS NULL

-- Step 3: Determine Direction
--     Ask: Am I going UP or DOWN the tree?
--     Direction Meaning: JOIN 
--         DOWN --> Find who reports to menew.manager_id = found.employee_id
--         UP --> Find my manager's managernew.employee_id = found.manager_id

-- Step 4: Write the Pattern
--     WITH RECURSIVE cte AS (
--         -- 1. Start here
--         SELECT columns FROM table WHERE <start>
        
--         UNION ALL
        
--         -- 2. Find next level
--         SELECT new.columns 
--         FROM table new
--         JOIN cte found ON <direction>
--     )
--     SELECT * FROM cte;

-- Step 5: Handle Edge Cases
-- Ask:
--     Exclude starting node? → Add AND id != X in anchor
--     Self-referencing rows? → Add WHERE new.id != new.parent_id
--     Limit depth? → Add level counter

-- For This Problem (1270)
--     StepAnswerPattern?Hierarchy — employee reports to manager
--     Start where?Direct reports to Boss (manager_id = 1)
--     Exclude anyone?Boss himself (employee_id != 1)
--     Direction?DOWN — find who reports to people I found
--     JOIN?e.manager_id = em.employee_id