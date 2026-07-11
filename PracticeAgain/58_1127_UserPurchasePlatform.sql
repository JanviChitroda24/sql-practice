-- 1127. User Purchase Platform
-- https://leetcode.ca/all/1127.html

-- 1127. User Purchase Platform
-- Table: Spending
-- +-------------+---------+
-- | Column Name | Type    |
-- +-------------+---------+
-- | user_id     | int     |
-- | spend_date  | date    |
-- | platform    | enum    |
-- | amount      | int     |
-- +-------------+---------+
-- The table logs the spendings history of users that make purchases from an online shopping website which has a desktop and a mobile application.
-- (user_id, spend_date, platform) is the primary key of this table.
-- The platform column is an ENUM type of ('desktop', 'mobile').
-- Write an SQL query to find the total number of users and the total amount spent using mobile only, desktop only and both mobile and desktop together for each date.Programming

-- The query result format is in the following example:

-- Spending table:
-- +---------+------------+----------+--------+
-- | user_id | spend_date | platform | amount |
-- +---------+------------+----------+--------+
-- | 1       | 2019-07-01 | mobile   | 100    |
-- | 1       | 2019-07-01 | desktop  | 100    |
-- | 2       | 2019-07-01 | mobile   | 100    |
-- | 2       | 2019-07-02 | mobile   | 100    |
-- | 3       | 2019-07-01 | desktop  | 100    |
-- | 3       | 2019-07-02 | desktop  | 100    |
-- +---------+------------+----------+--------+

-- Result table:
-- +------------+----------+--------------+-------------+
-- | spend_date | platform | total_amount | total_users |
-- +------------+----------+--------------+-------------+
-- | 2019-07-01 | desktop  | 100          | 1           |
-- | 2019-07-01 | mobile   | 100          | 1           |
-- | 2019-07-01 | both     | 200          | 1           |
-- | 2019-07-02 | desktop  | 100          | 1           |
-- | 2019-07-02 | mobile   | 100          | 1           |
-- | 2019-07-02 | both     | 0            | 0           |
-- +------------+----------+--------------+-------------+
-- On 2019-07-01, user 1 purchased using both desktop and mobile, user 2 purchased using mobile only and user 3 purchased using desktop only.
-- On 2019-07-02, user 2 purchased using mobile only, user 3 purchased using desktop only and no one purchased using both platforms.

-- WITH both_platform AS (
--     SELECT spend_date, 'both' AS 'platform', SUM(amount) AS total_amount, COUNT(DISTINCT user_id) AS total_users
--     FROM Spending
--     GROUP BY spend_date
--     HAVING COUNT(DISTINCT platform) = 2
--     UNION ALL
--     SELECT spend_date, 'both' AS 'platform', 0 AS total_amount, 0 AS total_users
--     FROM Spending
--     GROUP BY spend_date
--     HAVING COUNT(DISTINCT platform) = 1
--     UNION ALL
--     SELECT spend_date, 'both' AS 'platform', 0 AS total_amount, 0 AS total_users
--     FROM Spending
--     GROUP BY spend_date
-- )

WITH both_users AS (
    SELECT user_id, spend_date, 'both' AS platform, SUM(amount) as total_amount
    FROM Spending
    GROUP BY user_id, spend_date
    HAVING COUNT(platform) = 2
    UNION ALL
    SELECT user_id, spend_date, MAX(platform) AS platform, SUM(amount) as total_amount
    FROM Spending
    GROUP BY user_id, spend_date
    HAVING COUNT(platform) = 1
),
unique_platfrom AS (
    SELECT 'mobile' AS platform
    UNION 
    SELECT 'desktop' AS platform
    UNION 
    SELECT 'both' AS platform
),
date_platform AS (
    SELECT d.spend_date, p.platform
    FROM (
            (SELECT DISTINCT spend_date FROM Spending) d
            CROSS JOIN unique_platfrom p)
),
aggregated AS (
    SELECT spend_date, platform, 
        SUM(total_amount) AS total_amount, 
        COUNT(user_id) AS total_users
    FROM both_users
    GROUP BY spend_date, platform
)
SELECT dp.spend_date, dp.platform, 
    IFNULL(total_amount,0) AS total_amount, 
    IFNULL(total_users,0) AS total_users
FROM date_platform dp LEFT JOIN aggregated a
    ON dp.spend_date = a.spend_date AND dp.platform = a.platform;

-- organized 
WITH unique_platform AS (
    SELECT 'mobile' AS platform
    UNION 
    SELECT 'desktop' AS platform
    UNION 
    SELECT 'both' AS platform
),
unique_date AS (
    SELECT DISTINCT spend_date
    FROM Spending
),
unique_date_platform AS (
    SELECT spend_date, platform
    FROM unique_date 
        CROSS JOIN unique_platform
),
both_platfrom AS (
    SELECT user_id, spend_date, 'both' AS platform, SUM(amount) AS total_spend
    FROM Spending
    GROUP BY user_id, spend_date
    HAVING COUNT(platform) = 2
    UNION 
    SELECT user_id, spend_date, MIN(platform) AS platform, SUM(amount) AS total_spend
    FROM Spending
    GROUP BY user_id, spend_date
    HAVING COUNT(platform) = 1
),
date_aggregate AS (
    SELECT spend_date, platform, 
        SUM(total_spend) AS total_spend, COUNT(user_id) AS total_users
    FROM both_platfrom
    GROUP BY spend_date, platform
)
SELECT dp.spend_date, dp.platform, 
    COALESCE(da.total_spend,0) AS total_spend,
    COALESCE(da.total_users,0) AS total_users
FROM unique_date_platform dp 
    LEFT JOIN date_aggregate da
        ON dp.spend_date = da.spend_date AND  dp.platform = da.platform

-- OPTIMIZED SOLUTION
WITH unique_platform AS (
    SELECT 'mobile' AS platform
    UNION 
    SELECT 'desktop' AS platform
    UNION 
    SELECT 'both' AS platform
),
unique_date AS (
    SELECT DISTINCT spend_date
    FROM Spending
),
unique_date_platform AS (
    SELECT spend_date, platform
    FROM unique_date 
        CROSS JOIN unique_platform
),
both_platfrom AS (
    SELECT user_id, spend_date,
        CASE 
            WHEN COUNT(*) = 2 
                THEN 'both' 
            ELSE MAX(platform) 
        END AS platform,
        SUM(amount) AS total_amount
    FROM Spending
    GROUP BY user_id, spend_date
),
date_aggregate AS (
    SELECT spend_date, platform, 
        SUM(total_amount) AS total_amount, 
        COUNT(user_id) AS total_users
    FROM both_platfrom
    GROUP BY spend_date, platform
)
SELECT dp.spend_date, dp.platform, 
    COALESCE(da.total_amount,0) AS total_amount,
    COALESCE(da.total_users,0) AS total_users
FROM unique_date_platform dp 
    LEFT JOIN date_aggregate da
        ON dp.spend_date = da.spend_date AND  dp.platform = da.platform;