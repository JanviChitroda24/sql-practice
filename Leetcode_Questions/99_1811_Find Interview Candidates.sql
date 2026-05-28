-- 1811. Find Interview Candidates
-- https://leetcode.ca/all/1811.html

-- Table: Contests
-- +--------------+------+
-- | Column Name  | Type |
-- +--------------+------+
-- | contest_id   | int  |
-- | gold_medal   | int  |
-- | silver_medal | int  |
-- | bronze_medal | int  |
-- +--------------+------+
-- contest_id is the primary key for this table.
-- This table contains the LeetCode contest ID and the user IDs of the gold, silver, and bronze medalists.
-- It is guaranteed that any consecutive contests have consecutive IDs and that no ID is skipped.
 

-- Table: Users
-- +-------------+---------+
-- | Column Name | Type    |
-- +-------------+---------+
-- | user_id     | int     |
-- | mail        | varchar |
-- | name        | varchar |
-- +-------------+---------+
-- user_id is the primary key for this table.
-- This table contains information about the users.
 

-- Write an SQL query to report the name and the mail of all interview candidates. 
-- A user is an interview candidate if at least one of these two conditions is true:Programming
-- The user won any medal in three or more consecutive contests.
-- The user won the gold medal in three or more different contests (not necessarily consecutive).
-- Return the result table in any order.

-- The query result format is in the following example:

 

-- Contests table:
-- +------------+------------+--------------+--------------+
-- | contest_id | gold_medal | silver_medal | bronze_medal |
-- +------------+------------+--------------+--------------+
-- | 190        | 1          | 5            | 2            |
-- | 191        | 2          | 3            | 5            |
-- | 192        | 5          | 2            | 3            |
-- | 193        | 1          | 3            | 5            |
-- | 194        | 4          | 5            | 2            |
-- | 195        | 4          | 2            | 1            |
-- | 196        | 1          | 5            | 2            |
-- +------------+------------+--------------+--------------+

-- Users table:
-- +---------+--------------------+-------+
-- | user_id | mail               | name  |
-- +---------+--------------------+-------+
-- | 1       | sarah@leetcode.com | Sarah |
-- | 2       | bob@leetcode.com   | Bob   |
-- | 3       | alice@leetcode.com | Alice |
-- | 4       | hercy@leetcode.com | Hercy |
-- | 5       | quarz@leetcode.com | Quarz |
-- +---------+--------------------+-------+

-- Result table:
-- +-------+--------------------+
-- | name  | mail               |
-- +-------+--------------------+
-- | Sarah | sarah@leetcode.com |
-- | Bob   | bob@leetcode.com   |
-- | Alice | alice@leetcode.com |
-- | Quarz | quarz@leetcode.com |
-- +-------+--------------------+

-- Sarah won 3 gold medals (190, 193, and 196), so we include her in the result table.
-- Bob won a medal in 3 consecutive contests (190, 191, and 192), so we include him in the result table.
--     - Note that he also won a medal in 3 other consecutive contests (194, 195, and 196).
-- Alice won a medal in 3 consecutive contests (191, 192, and 193), so we include her in the result table.
-- Quarz won a medal in 5 consecutive contests (190, 191, 192, 193, and 194), so we include them in the result table.

WITH contest_unpivot AS (
    SELECT contest_id, gold_medal AS user_id FROM Contests
    UNION ALL
    SELECT contest_id, silver_medal AS user_id FROM Contests
    UNION ALL
    SELECT contest_id, bronze_medal AS user_id FROM Contests
),
contest_comp AS (
    SELECT user_id, contest_id,
        LAG(contest_id) OVER (PARTITION BY user_id ORDER BY contest_id) AS contest_1,
        LAG(contest_id,2) OVER (PARTITION BY user_id ORDER BY contest_id) AS contest_2
    FROM contest_unpivot
),
cond_one AS (
    SELECT user_id, contest_id
    FROM contest_comp
    WHERE contest_id - contest_1 = 1 AND contest_1 - contest_2 = 1
    GROUP BY user_id, contest_id
),
gold_medal_cnt AS (
    SELECT gold_medal AS user_id,  COUNT(contest_id) AS contest_cnt
    FROM Contests
    GROUP BY gold_medal
),
cond_two AS (
    SELECT user_id
    FROM gold_medal_cnt
    WHERE contest_cnt >= 3
),
union_cond_one_two AS (
    SELECT DISTINCT user_id AS user_id
    FROM cond_one
    UNION 
    SELECT user_id
    FROM cond_two
)
SELECT u.name, u.mail
FROM union_cond_one_two uc JOIN Users u
    ON uc.user_id = u.user_id;


-- NOTE: SQL Chained Equality
-- SQL does NOT support math-style chained equality: a = b = c
-- SQL evaluates left to right: (a = b) = c → compares boolean (0/1) to c
--
-- Wrong:  WHERE contest_id = contest_1 + 1 = contest_2 + 1
-- Right:  WHERE contest_id - contest_1 = 1 AND contest_1 - contest_2 = 1
-- Right:  WHERE contest_id = contest_1 + 1 AND contest_id = contest_2 + 2
--
-- Rule: One comparison per operator, combine with AND/OR