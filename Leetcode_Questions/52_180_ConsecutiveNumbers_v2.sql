-- 180. Consecutive Numbers
-- https://leetcode.com/problems/consecutive-numbers/description/

-- Medium
-- Topics
-- premium lock icon
-- Companies
-- SQL Schema
-- Pandas Schema
-- Table: Logs

-- +-------------+---------+
-- | Column Name | Type    |
-- +-------------+---------+
-- | id          | int     |
-- | num         | varchar |
-- +-------------+---------+
-- In SQL, id is the primary key for this table.
-- id is an autoincrement column starting from 1.
 

-- Find all numbers that appear at least three times consecutively.

-- Return the result table in any order.

-- The result format is in the following example.

 

-- Example 1:

-- Input: 
-- Logs table:
-- +----+-----+
-- | id | num |
-- +----+-----+
-- | 1  | 1   |
-- | 2  | 1   |
-- | 3  | 1   |
-- | 4  | 2   |
-- | 5  | 1   |
-- | 6  | 2   |
-- | 7  | 2   |
-- +----+-----+
-- Output: 
-- +-----------------+
-- | ConsecutiveNums |
-- +-----------------+
-- | 1               |
-- +-----------------+
-- Explanation: 1 is the only number that appears consecutively for at least three times.

-- # Write your MySQL query statement below
WITH next_comparison AS (
    SELECT id, num, 
        LEAD(num) OVER(ORDER BY ID) AS num_2, 
        LEAD(num,2) OVER(ORDER BY ID) AS num_3
    FROM Logs
)
SELECT DISTINCT num AS ConsecutiveNums
FROM next_comparison
WHERE num = num_2  AND num = num_3;