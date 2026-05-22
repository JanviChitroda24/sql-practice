
-- 176. Second Highest Salary
-- https://leetcode.com/problems/second-highest-salary/

-- Table: Employee

-- +-------------+------+
-- | Column Name | Type |
-- +-------------+------+
-- | id          | int  |
-- | salary      | int  |
-- +-------------+------+
-- id is the primary key (column with unique values) for this table.
-- Each row of this table contains information about the salary of an employee.
 

-- Write a solution to find the second highest distinct salary from the Employee table. If there is no second highest salary, return null (return None in Pandas).

-- The result format is in the following example.

 

-- Example 1:

-- Input: 
-- Employee table:
-- +----+--------+
-- | id | salary |
-- +----+--------+
-- | 1  | 100    |
-- | 2  | 200    |
-- | 3  | 300    |
-- +----+--------+
-- Output: 
-- +---------------------+
-- | SecondHighestSalary |
-- +---------------------+
-- | 200                 |
-- +---------------------+
-- Example 2:

-- Input: 
-- Employee table:
-- +----+--------+
-- | id | salary |
-- +----+--------+
-- | 1  | 100    |
-- +----+--------+
-- Output: 
-- +---------------------+
-- | SecondHighestSalary |
-- +---------------------+
-- | null                |
-- +---------------------+

SELECT (
    SELECT salary
    FROM Employee
    GROUP BY salary
    ORDER BY salary DESC
    LIMIT 1 OFFSET 1
) AS SecondHighestSalary;

--SOLUTION WITHOUT LIMIT AND OFFSET 
-- USING SUBQUERY
SELECT (
    SELECT MAX(salary)
    FROM Employee
    WHERE salary != (SELECT MAX(salary) FROM Employee)
) AS SecondHighestSalary;

-- USING WINDOW FUNCTION
SELECT (
    SELECT salary
    FROM (
        SELECT salary, DENSE_RANK() OVER(ORDER BY salary DESC) AS sal_rank
        FROM Employee
        GROUP BY salary
    ) TEMP
    WHERE sal_rank=2
) AS SecondHighestSalary;

-- **Approach 1 — 
--     LIMIT OFFSET:** Best. 
--     Single table scan, GROUP BY for distinct, then skip one row. 
--     Simplest execution plan.

-- **Approach 2 — 
--     Nested MAX:** Middle. 
--     Two scans of the table 
--         — one for the inner MAX, one for the outer MAX with filter. 
--     Simple but redundant work.

-- **Approach 3 — 
--     DENSE_RANK:** Worst. 
--     Computes rank for ALL rows, then wraps in two nested subqueries just to extract one value. 
--     Most overhead for the simplest task.

-- **Rule of thumb:** 
--     For "Nth highest" problems, 
--     LIMIT with OFFSET is the cleanest and most efficient in MySQL. 
--     Use DENSE_RANK when you need the Nth highest **per group** (like per department). 
--     For a single global Nth value, LIMIT OFFSET wins.


---- 
----
----
---- LEARNING 
----
----
----

-- **Returning NULL Instead of Empty Result**

-- **The problem:** When a query returns no rows (e.g., LIMIT OFFSET skips past all rows), 
--     you get an empty result set — not a row with NULL.

-- **The fix:** Wrap your query as a **scalar subquery** inside SELECT:

-- ```sql
-- SELECT (
--     -- your query here that might return no rows
-- ) AS column_name;
-- ```

-- **Why it works:** 
--     A scalar subquery that returns no rows automatically evaluates to NULL. 
--     The outer SELECT always produces exactly one row.

-- **What doesn't work:**
--     - `COALESCE(column, NULL)` — useless because there's no row to apply it to
--     - Wrapping in `FROM (subquery) AS temp` — derived table with no rows still gives empty result
--     - Only a scalar subquery in the SELECT clause converts "no rows" → NULL

-- **When to use this:** 
--     Anytime you need a guaranteed single-row result that returns NULL when no data exists 
--     — second highest salary, Nth value, single lookups that might miss.