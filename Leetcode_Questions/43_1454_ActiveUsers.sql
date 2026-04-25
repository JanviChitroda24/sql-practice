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

WITH user_ordered AS (
    SELECT l.id, a.name, l.login_date
    FROM Logins l JOIN Accounts a
        ON l.id = a.id
    GROUP BY l.id, a.name, l.login_date
    ORDER BY l.id, l.login_date
),
consecutive_check AS (
    SELECT id, name, login_date, 
        (CASE 
        WHEN
            LAG(login_date, 4) OVER(PARTITION BY id ORDER BY login_date)
            = DATE_SUB(login_date, INTERVAL 4 DAY) 
        THEN 1
        ELSE 0
        END) AS login_check
    FROM user_ordered
)
SELECT id, name
FROM consecutive_check
GROUP BY id, name
HAVING SUM(login_check) >= 1;

---
--- more optimized with one CTE

WITH deduped AS (
    SELECT id, login_date
    FROM Logins
    GROUP BY id, login_date
),
consecutive_check AS (
    SELECT d.id, a.name, d.login_date,
        CASE 
            WHEN LAG(d.login_date, 4) OVER(PARTITION BY d.id ORDER BY d.login_date)
                 = DATE_SUB(d.login_date, INTERVAL 4 DAY)
            THEN 1
            ELSE 0
        END AS login_check
    FROM deduped d 
    JOIN Accounts a ON d.id = a.id
)
SELECT id, name
FROM consecutive_check
GROUP BY id, name
HAVING SUM(login_check) >= 1;

-- 1. Deduplicate Before Window Functions
-- Window functions like LAG, LEAD, ROW_NUMBER operate on rows, not distinct values.
-- sql-- ❌ Wrong: LAG counts duplicate rows
-- LAG(login_date, 4) OVER(...) -- sees 5 rows, but only 4 distinct dates

-- -- ✅ Right: Dedupe first
-- WITH deduped AS (
--     SELECT id, login_date
--     FROM Logins
--     GROUP BY id, login_date
-- -- )
-- Rule: Always ask — can this table have duplicates? If yes, dedupe before applying window functions.

-- 2. LAG for Consecutive Sequence Detection
-- To check if N rows are consecutive dates:
-- sqlLAG(date_col, N-1) OVER(PARTITION BY id ORDER BY date_col)
-- = DATE_SUB(date_col, INTERVAL (N-1) DAY)
-- Why this works:

-- If 5 dates are truly consecutive, the date 4 rows back equals current date minus 4 days.
-- If there's a gap, the difference won't match.

-- You don't need to check every row in between — date arithmetic handles gap detection.