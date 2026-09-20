-- You have a table called user_actions:

-- user_actions
-- ├── action_id       INT (PK)
-- ├── user_id         INT
-- ├── action_type     VARCHAR(50)
-- ├── action_date     DATE

-- Generate a report that shows for each month, how many users performed each action_type, 
-- and also show the same count as a percentage of total actions that month. 
-- Pivot the result so each action_type becomes its own column. 
-- Assume there are exactly three action types: 'click', 'purchase', and 'signup'. 
-- Return action_month, click_count, purchase_count, signup_count, click_pct, purchase_pct, signup_pct.

WITH actions_month_count AS (
    SELECT MONTH(action_date) AS action_month,
        COUNT(action_id) AS total_actions,
        COUNT(CASE 
            WHEN action_type = 'click'
            THEN 1
        END) AS click_count,
        COUNT(CASE 
            WHEN action_type = 'purchase'
            THEN 1
        END) AS purchase_count,
        COUNT(CASE 
            WHEN action_type = 'signup'
            THEN 1
        END) AS signup_count
    FROM user_actions
    GROUP BY MONTH(action_date)
)
SELECT action_month, click_count, purchase_count, signup_count, 
    ROUND( (click_count*100.0)/total_actions ,2) AS click_pct,
    ROUND( (purchase_count*100.0)/total_actions ,2) AS purchase_pct,
    ROUND( (signup_count*100.0)/total_actions ,2) AS signup_pct
FROM actions_month_count;


----
---- now write the same soluction for all month
WITH RECURSIVE month_numbers AS (
    SELECT 1 AS mon_no
    UNION ALL
    SELECT mon_no+1 
    FROM month_numbers
    WHERE mon_no<12
),
actions_month_count AS (
    SELECT m.mon_no AS action_month, 
        COUNT(u.action_id) AS total_actions,
        COUNT(CASE 
            WHEN u.action_type = 'click'
            THEN 1
        END) AS click_count,
        COUNT(CASE 
            WHEN u.action_type = 'purchase'
            THEN 1
        END) AS purchase_count,
        COUNT(CASE 
            WHEN u.action_type = 'signup'
            THEN 1
        END) AS signup_count
    FROM month_numbers m LEFT JOIN user_actions u 
        ON m.mon_no = MONTH(u.action_date)
    GROUP BY m.mon_no
)
SELECT action_month, click_count, purchase_count, signup_count, 
    ROUND( COALESCE((click_count*100.0)/NULLIF(total_actions,0),0) ,2) AS click_pct,
    ROUND( COALESCE((purchase_count*100.0)/NULLIF(total_actions,0),0) ,2) AS purchase_pct,
    ROUND( COALESCE((signup_count*100.0)/NULLIF(total_actions,0),0) ,2) AS signup_pct
FROM actions_month_count;


---
--- if you want month number than
WITH month_names AS (
    SELECT 'January' AS month_name
    UNION ALL
    SELECT 'February' AS month_name
    UNION ALL
    SELECT 'March' AS month_name
    UNION ALL
    SELECT 'April' AS month_name
    UNION ALL
    SELECT 'May' AS month_name
    UNION ALL
    SELECT 'June' AS month_name
    UNION ALL
    SELECT 'July' AS month_name
    UNION ALL
    SELECT 'August' AS month_name
    UNION ALL
    SELECT 'September' AS month_name
    UNION ALL
    SELECT 'October' AS month_name
    UNION ALL
    SELECT 'November' AS month_name
    UNION ALL
    SELECT 'December' AS month_name
),
actions_month_count AS (
    SELECT m.month_name AS action_month, 
        COUNT(u.action_id) AS total_actions,
        COUNT(CASE 
            WHEN u.action_type = 'click'
            THEN 1
        END) AS click_count,
        COUNT(CASE 
            WHEN u.action_type = 'purchase'
            THEN 1
        END) AS purchase_count,
        COUNT(CASE 
            WHEN u.action_type = 'signup'
            THEN 1
        END) AS signup_count
    FROM month_names m LEFT JOIN user_actions u
        ON m.month_name = DATE_FORMAT(u.action_date,'%M')
    GROUP BY m.month_name
)
SELECT action_month, click_count, purchase_count, signup_count, 
    ROUND( COALESCE((click_count*100.0)/NULLIF(total_actions,0),0) ,2) AS click_pct,
    ROUND( COALESCE((purchase_count*100.0)/NULLIF(total_actions,0),0) ,2) AS purchase_pct,
    ROUND( COALESCE((signup_count*100.0)/NULLIF(total_actions,0),0) ,2) AS signup_pct
FROM actions_month_count;