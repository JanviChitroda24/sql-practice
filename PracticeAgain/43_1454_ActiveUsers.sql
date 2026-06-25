-- LeetCode 1454 — Active Users
--  https://leetcode.com/problems/active-users/

-- SQL Schema 

-- Table Accounts:
-- +---------------+---------+
-- | Column Name   | Type    |
-- +---------------+---------+
-- | id            | int     |
-- | name          | varchar |
-- +---------------+---------+
-- the id is the primary key for this table.
-- This table contains the account id and the user name of each account.
 

-- Table Logins:
-- +---------------+---------+
-- | Column Name   | Type    |
-- +---------------+---------+
-- | id            | int     |
-- | login_date    | date    |
-- +---------------+---------+
-- There is no primary key for this table, it may contain duplicates.
-- This table contains the account id of the user who logged in and the login date. A user may log in multiple times in the day.
 

-- Write an SQL query to find the id and the name of active users.Programming

-- Active users are those who logged in to their accounts for 5 or more consecutive days.

-- Return the result table ordered by the id.

-- The query result format is in the following example:

-- Accounts table:
-- +----+----------+
-- | id | name     |
-- +----+----------+
-- | 1  | Winston  |
-- | 7  | Jonathan |
-- +----+----------+

-- Logins table:
-- +----+------------+
-- | id | login_date |
-- +----+------------+
-- | 7  | 2020-05-30 |
-- | 1  | 2020-05-30 |
-- | 7  | 2020-05-31 |
-- | 7  | 2020-06-01 |
-- | 7  | 2020-06-02 |
-- | 7  | 2020-06-02 |
-- | 7  | 2020-06-03 |
-- | 1  | 2020-06-07 |
-- | 7  | 2020-06-10 |
-- +----+------------+

-- Result table:
-- +----+----------+
-- | id | name     |
-- +----+----------+
-- | 7  | Jonathan |
-- +----+----------+
-- User Winston with id = 1 logged in 2 times only in 2 different days, so, Winston is not an active user.
-- User Jonathan with id = 7 logged in 7 times in 6 different days, five of them were consecutive days, so, Jonathan is an active user.

WITH logins_dedup AS (
    SELECT id, login_date
    FROM Logins
    GROUP BY id, login_date
), consecutive_5 AS (
    SELECT a.id, a.name, l.login_date, 
        LAG(l.login_date, 4) OVER(PARTITION BY l.id ORDER BY l.login_date) AS login_4d
    FROM Accounts a JOIN logins_dedup l
        ON a.id = l.id
)
SELECT DISTINCT id, name
FROM consecutive_5
WHERE DATEDIFF(login_date,login_4d) = 4;

-- alternative solution: gap in the island problem 
WITH logins_dedup AS (
    SELECT id, login_date
    FROM Logins
    GROUP BY id, login_date
), login_rn AS (
    SELECT id, login_date, 
        ROW_NUMBER() OVER(PARTITION BY id ORDER BY login_date) AS rn
    FROM logins_dedup
), login_groups AS (
    SELECT id,
        DATE_SUB(login_date, INTERVAL rn DAY) AS login_group
    FROM login_rn
)
SELECT l.id, a.name
FROM login_groups l JOIN Accounts a
    ON l.id = a.id 
GROUP BY l.id, a.name, l.login_group
HAVING COUNT(*) >= 5;