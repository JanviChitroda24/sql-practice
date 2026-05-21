-- 196. Delete Duplicate Emails
-- https://leetcode.com/problems/delete-duplicate-emails/

-- Table: Person

-- +-------------+---------+
-- | Column Name | Type    |
-- +-------------+---------+
-- | id          | int     |
-- | email       | varchar |
-- +-------------+---------+
-- id is the primary key (column with unique values) for this table.
-- Each row of this table contains an email. The emails will not contain uppercase letters.
 

-- Write a solution to delete all duplicate emails, keeping only one unique email with the smallest id.

-- For SQL users, please note that you are supposed to write a DELETE statement and not a SELECT one.

-- For Pandas users, please note that you are supposed to modify Person in place.

-- After running your script, the answer shown is the Person table. The driver will first compile and run your piece of code and then show the Person table. The final order of the Person table does not matter.

-- The result format is in the following example.

 

-- Example 1:

-- Input: 
-- Person table:
-- +----+------------------+
-- | id | email            |
-- +----+------------------+
-- | 1  | john@example.com |
-- | 2  | bob@example.com  |
-- | 3  | john@example.com |
-- +----+------------------+
-- Output: 
-- +----+------------------+
-- | id | email            |
-- +----+------------------+
-- | 1  | john@example.com |
-- | 2  | bob@example.com  |
-- +----+------------------+
-- Explanation: john@example.com is repeated two times. We keep the row with the smallest Id = 1.

DELETE FROM Person
WHERE ID NOT IN (
    SELECT id 
    FROM (
        SELECT MIN(id) AS id
        FROM Person
        GROUP BY email
    ) temp
);

-- incorrect solution
-- DELETE FROM Person
-- WHERE id IN (
--     SELECT p1.id 
--     FROM Person p1 
--     WHERE EXISTS (
--         SELECT 1
--         FROM Person p2
--         WHERE p1.email = p2.email AND p2.id = p1.id
--     )
-- )

-- Three things:

-- **1. MySQL can't SELECT from the same table you're deleting from** 
--     — you get "can't specify target table for update in FROM clause." 
--     The workaround is wrapping the subquery in a derived table with an alias (`AS temp`).

-- **2. "Delete duplicates" = keep MIN(id), delete the rest** — the pattern is: 
--     GROUP BY the duplicate column, take MIN(id) to identify what to keep, 
--     then DELETE WHERE id NOT IN those kept ids.

-- **3. GROUP BY must match the problem** — 
--     GROUP BY primary key (id) is always 1 row per group, so HAVING COUNT > 1 never triggers. 
--     GROUP BY the column you're checking for duplicates (email), not the unique key.