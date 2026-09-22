-- Q7

-- You have a table called user_logins:

-- user_logins
-- ├── user_id       INT
-- ├── login_date    DATE

-- A user can have multiple rows for the same date (multiple logins in one day). 
-- Write a query that finds all users who have logged in for 3 or more consecutive days. 
-- Return user_id, streak_start_date, streak_end_date, and streak_length.

WITH dedup_login AS (
    SELECT user_id, login_date
    FROM user_logins
    GROUP BY user_id, login_date
),
user_login_rank AS (
    SELECT user_id, login_date,
        ROW_NUMBER() OVER(PARTITION BY user_id ORDER BY login_date) AS user_rank
    FROM dedup_login
),
user_login_diff AS (
    SELECT user_id, login_date, DATE_SUB(login_date, INTERVAL user_rank DAY) AS user_group
    FROM user_login_rank
),
user_login_group AS (
    SELECT user_id,
        MIN(login_date) AS streak_start_date,
        MAX(login_date) AS streak_end_date,
        COUNT(*) AS streak_length
    FROM user_login_diff
    GROUP BY user_id, user_group
)
SELECT user_id, streak_start_date, streak_end_date, streak_length
FROM user_login_group
WHERE streak_length>=3;
