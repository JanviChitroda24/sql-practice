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

WITH classified_users AS (
    SELECT spend_date, user_id,
        CASE 
            WHEN COUNT(DISTINCT platform) = 2 
            THEN 'both'
            ELSE MAX(platform)
        END AS platform_name,
        SUM(amount) AS total_amount
    FROM Spending
    GROUP BY spend_date, user_id
),
platforms AS (
    SELECT 'both' AS platform
    UNION SELECT 'mobile'
    UNION SELECT 'desktop'
),
distinct_dates AS (
    SELECT DISTINCT spend_date
    FROM Spending
),
scaffold AS (
    SELECT spend_date, platform
    FROM distinct_dates CROSS JOIN platforms
)
SELECT s.spend_date, s.platform, 
        COALESCE(SUM(u.total_amount),0) AS total_amount,  
        COUNT(u.user_id) AS total_users
FROM scaffold s LEFT JOIN classified_users u
    ON s.spend_date = u.spend_date AND s.platform = u.platform_name
GROUP BY s.spend_date, s.platform;