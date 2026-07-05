-- 176. Second Highest Salary
-- https://leetcode.com/problems/second-highest-salary/description/

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

WITH sal_rank AS (
    SELECT id, salary, 
        DENSE_RANK() OVER(ORDER BY salary DESC) AS dense_rnk
    FROM Employee
)
SELECT MAX(CASE 
            WHEN dense_rnk=2
            THEN salary
        END) AS SecondHighestSalary
FROM sal_rank;

-- your DENSE_RANK() solution is more impressive to show first, 
-- because it demonstrates you understand window functions and the NULL-safety trick generally 
-- — that skill transfers to harder problems where offset tricks don't work as cleanly 
-- (e.g., ranking within groups, ties with additional tie-breaking columns). 
-- But if asked "is there a simpler way for just this problem," 
-- mentioning LIMIT/OFFSET shows you also know the lightweight idiom and aren't over-engineering 
--     when a simpler tool fits. 
-- Mentioning both, in that order, is the strongest answer.

SELECT (
    SELECT DISTINCT salary
    FROM Employee
    ORDER BY salary DESC
    LIMIT 1 OFFSET 1
) AS SecondHighestSalary;


-- ### Execution order of a SELECT query
-- SQL doesn't run top-to-bottom the way you read it. The actual order of operations is:

-- ```
-- FROM  →  WHERE  →  GROUP BY  →  HAVING  →  SELECT  →  DISTINCT  →  ORDER BY  →  LIMIT/OFFSET
-- ```

-- So for your subquery:
-- ```sql
-- SELECT DISTINCT salary
-- FROM Employee
-- ORDER BY salary DESC
-- LIMIT 1 OFFSET 1
-- ```

-- The engine actually does, in this order:
-- 1. **FROM Employee** — grab all rows
-- 2. **SELECT salary** — project just the salary column
-- 3. **DISTINCT** — collapse duplicate salary values into unique ones
-- 4. **ORDER BY salary DESC** — sort the *distinct* values, highest first
-- 5. **LIMIT 1 OFFSET 1** — skip the first row of that sorted list, then take exactly 1 row

-- `OFFSET` and `LIMIT` are the very last things applied — they operate on the final sorted, deduplicated list, not on the raw table.

-- ### Case: two employees tied for 1st highest

-- ```
-- Employee: 300, 300, 200, 100
-- ```

-- - After `DISTINCT`: `{300, 200, 100}` — the duplicate 300 collapses into one value
-- - After `ORDER BY DESC`: `300, 200, 100`
-- - `OFFSET 1` skips position 0 (the 300), lands on position 1
-- - `LIMIT 1` takes that one row → **200**

-- This is correct: even though two people *earn* 300, there's still only one distinct "highest salary" value, so the second-highest distinct salary is genuinely 200. The `DISTINCT` is doing the real work here — without it, you'd have `{300, 300, 200, 100}`, and `OFFSET 1` would skip only one of the two 300s, incorrectly returning 300 again as the "second highest."

-- ### Case: two employees tied for 2nd highest

-- ```
-- Employee: 300, 200, 200, 100
-- ```

-- - After `DISTINCT`: `{300, 200, 100}`
-- - After `ORDER BY DESC`: `300, 200, 100`
-- - `OFFSET 1` skips the 300, lands on 200
-- - `LIMIT 1` takes it → **200**

-- Also correct — it doesn't matter that two people happen to earn 200; the distinct value 200 is still the second-highest *value* in the set, and that's what the problem asks for.

-- ### Case: no second value exists at all (Example 2 from the problem)

-- ```
-- Employee: 100
-- ```

-- - After `DISTINCT`: `{100}`
-- - After `ORDER BY DESC`: `100`
-- - `OFFSET 1` tries to skip position 0, but there's nothing at position 1
-- - `LIMIT 1` returns **zero rows**

-- This is the key mechanic to understand: the *inner* subquery returns an empty result set — not a NULL, an actual empty set. But because you wrapped it as a **scalar subquery** in the outer `SELECT ( ... ) AS SecondHighestSalary`, MySQL guarantees that a scalar subquery always evaluates to exactly one value in the outer query — and if the inner subquery produced zero rows, that value is automatically `NULL`. That's why you get one row containing `NULL` in the final output, rather than the whole query returning nothing.

-- That's the mechanism that makes this approach NULL-safe "for free," compared to your `MAX(CASE...)` version where you had to build that guarantee yourself.

-- ALTERNATIVE
WITH sal_rank AS (
    SELECT id, salary, 
        DENSE_RANK() OVER(ORDER BY salary DESC) AS dense_rnk
    FROM Employee
)
SELECT (
    SELECT DISTINCT salary
    FROM sal_rank
    WHERE dense_rnk = 2
) AS SecondHighestSalary