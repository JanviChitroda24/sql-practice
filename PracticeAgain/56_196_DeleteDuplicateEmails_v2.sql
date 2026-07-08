-- 196. Delete Duplicate Emails
-- https://leetcode.com/problems/delete-duplicate-emails/description/

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

DELETE 
FROM Person
WHERE id NOT IN (
    SELECT id FROM 
        (SELECT MIN(id) AS id
            FROM Person
            GROUP BY email
        ) AS person_temp);


-- alternate self join version 
DELETE p1 
FROM person p1 JOIN person p2 
    ON p1.email = p2.email 
    AND p1.id > p2.id;

--
-- MySQL blocks: 
--     DELETE FROM Person WHERE id NOT IN (SELECT MIN(id) FROM Person GROUP BY email)
--     → Error 1093, can't read + delete same table directly

--     Why: 
--         DELETE and the subquery would both act on Person in the same
--         statement — MySQL can't guarantee the subquery sees a consistent,
--         unmodified view of the table while rows are being deleted from it.
--         So it blocks any direct self-reference outright, rather than risk it.