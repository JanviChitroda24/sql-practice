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

-- Solution 1 --> NOT IN 
DELETE FROM Person
WHERE id NOT IN (
    SELECT *
    FROM (
        SELECT MIN(id)
        FROM Person
        GROUP BY email
    ) AS temp
    WHERE id IS NOT NULL
);

-- Solution 2 -- EXIST
DELETE FROM Person p1
WHERE EXISTS
    (
        SELECT * 
        FROM (
            SELECT 1 
            FROM Person p2
            WHERE p1.email = p2.email  AND p1.id > p2.id
        ) AS temp
    );

-- Solution 3 -- JOIN
DELETE p1 
FROM Person p1 JOIN Person p2
ON p1.email = p2.email AND p1.id > p2.id;

-- ## Comparison

-- | Criteria               | Solution 1 (NOT IN)       | Solution 2 (EXISTS)        | Solution 3 (JOIN)     |
-- |------------------------|---------------------------|----------------------------|-----------------------|
-- | ✅ Correct              | Yes                       | Yes                        | Yes                   |
-- | ⚠️ NULL Risk           | Yes — needs IS NOT NULL   | No — safe naturally        | No — safe naturally   |
-- | 🐬 MySQL Compatible    | Needs derived table hack  | Needs derived table hack   | ✅ Works directly      |
-- | 🚀 Performance         | Medium (builds full list) | Good (short-circuits)      | ✅ Best (index-friendly)|
-- | 🧠 Readability         | Easy                      | Medium                     | ✅ Very clean          |
-- | 📦 Memory              | Higher (temp list)        | Low                        | Low                   |
-- | 🎯 Interview Pick      | Good                      | Good to explain            | ✅ Best overall        |