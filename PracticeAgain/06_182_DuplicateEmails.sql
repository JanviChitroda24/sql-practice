-- 182. Duplicate Emails
-- https://leetcode.com/problems/duplicate-emails/

-- Table: Person

-- +-------------+---------+
-- | Column Name | Type    |
-- +-------------+---------+
-- | id          | int     |
-- | email       | varchar |
-- +-------------+---------+
-- id is the primary key (column with unique values) for this table.
-- Each row of this table contains an email. The emails will not contain uppercase letters.
 

-- Write a solution to report all the duplicate emails. Note that it's guaranteed that the email field is not NULL.

-- Return the result table in any order.

-- The result format is in the following example.

 

-- Example 1:

-- Input: 
-- Person table:
-- +----+---------+
-- | id | email   |
-- +----+---------+
-- | 1  | a@b.com |
-- | 2  | c@d.com |
-- | 3  | a@b.com |
-- +----+---------+
-- Output: 
-- +---------+
-- | Email   |
-- +---------+
-- | a@b.com |
-- +---------+
-- Explanation: a@b.com is repeated two times.


SELECT DISTINCT p1.email
FROM Person p1 JOIN Person p2
    ON p1.email = p2.email AND p1.id != p2.id;

-- OPTIMIZED USING GROUP BY INSTEAD OF JOIN ------ BEST BEST BEST BEST ------
SELECT email
FROM Person
GROUP BY email
HAVING COUNT(*) > 1;

-- ALTERNATIVE NOT EXIST
SELECT DISTINCT p1.email
FROM Person p1
WHERE EXISTS (
    SELECT 1
    FROM Person p2
    WHERE p1.email = p2.email AND p1.id != p2.id
);

-- **GROUP BY + HAVING** 
    -- — Best. Single table scan, no join overhead, no DISTINCT needed. O(n).

-- **EXISTS** 
    -- — Middle. For each row, scans for a matching row but short-circuits on first match. 
    -- Still requires DISTINCT. Better than self-join but worse than GROUP BY.

-- **Self-JOIN** 
    -- — Worst. Produces n×n rows 
    -- for duplicates (if an email appears 3 times, the join produces 6 rows), 
    -- then DISTINCT has to collapse them back. Most memory and computation.

-- **Rule of thumb:** 
    -- For "find duplicates" problems, always reach for GROUP BY + HAVING first. 
    -- It's the simplest, fastest, and most readable approach.
