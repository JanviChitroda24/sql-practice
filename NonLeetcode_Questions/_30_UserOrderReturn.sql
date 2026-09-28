-- **Q30**

-- You have the following tables:

-- ```
-- users
-- ├── user_id         INT (PK)
-- ├── username        VARCHAR(100)
-- ├── country         VARCHAR(50)
-- ├── created_at      DATE

-- orders
-- ├── order_id        INT (PK)
-- ├── user_id         INT
-- ├── order_date      DATE
-- ├── amount          DECIMAL(10,2)
-- ├── status          VARCHAR(20)

-- returns
-- ├── return_id       INT (PK)
-- ├── order_id        INT
-- ├── return_date     DATE
-- ├── reason          VARCHAR(100)
-- ```

-- For each country, find the percentage of users who made at least one purchase but never returned anything, 
-- the percentage who made at least one return, and the percentage who never purchased at all. 
-- Also return the total user count per country. 
-- Only include countries with at least 50 users. 
-- Return country, total_users, pct_loyal (purchased, never returned), pct_returners, pct_inactive.

-- incorrect since the same user gets counted for multiple categories multiple times 
SELECT u.country, 
    COUNT(DISTINCT u.user_id) AS total_users,
    ROUND(
        (COUNT(
            CASE 
                WHEN o.order_id IS NOT NULL AND return_id IS NULL
                THEN 1
            END
    )*100.0)/COUNT(DISTINCT u.user_id) 
    ,2) AS pct_loyal,
    ROUND(
        (COUNT(
            CASE 
                WHEN return_id IS NOT NULL
                THEN 1
            END
    )*100.0)/COUNT(DISTINCT u.user_id) 
    ,2) AS pct_returners,
    ROUND(
        (COUNT(
            CASE 
                WHEN o.order_id IS NULL
                THEN 1
            END
    )*100.0)/COUNT(DISTINCT u.user_id) 
    ,2) AS pct_inactive
FROM users u
    LEFT JOIN orders o
        ON u.user_id = o.user_id
    LEFT JOIN returns r
        ON o.order_id = r.order_id
GROUP BY u.country
HAVING COUNT(DISTINCT u.user_id) >= 50;

-- This is the critical issue. With LEFT JOINs, a user with 5 orders and 2 returns gets multiple rows. 
-- Your COUNT(CASE...) counts rows, not distinct users. 
-- A user with 3 orders and 0 returns gets counted 3 times as "loyal."
-- It depends on which orders have returns. If 2 out of 5 orders were returned:
-- user_id | order_id | return_id
-- 1       | 101      | NULL
-- 1       | 102      | NULL
-- 1       | 103      | NULL
-- 1       | 104      | R1
-- 1       | 105      | R2

-- 5 rows. This user is a "returner" but your CASE would count them 3 times as loyal (rows where return_id IS NULL and order_id IS NOT NULL) AND 2 times as returner. Same user counted in both categories.
-- If one order had 2 returns, it gets even worse — that order produces 2 rows.

-- first we classify user and than count the total users in country
WITH classify_users AS (
    SELECT u.user_id, u.country,
        CASE 
            WHEN COUNT(o.order_id)!=0 AND COUNT(r.return_id)=0
            THEN 'loyal'
            WHEN COUNT(r.return_id)!=0
            THEN 'returner'
            WHEN COUNT(o.order_id)=0
            THEN 'inactive'
        END AS user_type
    FROM users u 
        LEFT JOIN orders o 
            ON u.user_id = o.user_id
        LEFT JOIN returns r
            ON o.order_id = r.order_id
    GROUP BY u.user_id, u.country
)
SELECT country,
    COUNT(user_id) AS total_users,
    ROUND(
        (COUNT(CASE 
                WHEN user_type = 'loyal' THEN 1
            END)
        *100.0)/ COUNT(user_id)
    ,2) AS pct_loyal,
    ROUND(
        (COUNT(CASE 
                WHEN user_type = 'returner' THEN 1
            END)
        *100.0)/ COUNT(user_id)
    ,2) AS pct_returners,
    ROUND(
        (COUNT(CASE 
                WHEN user_type = 'inactive' THEN 1
            END)
        *100.0)/ COUNT(user_id)
    ,2) AS pct_inactive
FROM classify_users
GROUP BY country
HAVING COUNT(user_id) >= 50;