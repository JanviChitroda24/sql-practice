-- **Q31**

-- ```
-- events
-- ├── event_id        INT (PK)
-- ├── user_id         INT
-- ├── event_name      VARCHAR(50)
-- ├── event_timestamp DATETIME
-- ├── platform        VARCHAR(20)
-- ```

-- Your product team defines a conversion funnel: 
-- 'page_view' → 'add_to_cart' → 'checkout' → 'purchase'. 
-- Each step must happen in order for the same user within the same calendar day. 
-- Write a query that returns the number of unique users who reached each step of the funnel and the drop-off percentage from the previous step. 
-- Return step_name, users_reached, and pct_dropoff.


-- I'm assuming we check whether the earliest occurrence of each step follows the funnel order. 
-- Should I instead check if any occurrence of each step can be chained in order?

WITH earliest_user_action AS (
    SELECT event_timestamp, user_id, 
        MIN(
            CASE WHEN event_name = 'page_view' THEN event_timestamp END
        ) AS min_page_view,
        MIN(
            CASE WHEN event_name = 'add_to_cart' THEN event_timestamp END
        ) AS min_add_to_cart,
        MIN(
            CASE WHEN event_name = 'checkout' THEN event_timestamp END
        ) AS min_checkout,
        MIN(
            CASE WHEN event_name = 'purchase' THEN event_timestamp END
        ) AS min_purchase
    FROM events
    GROUP BY DATE(event_timestamp), user_id
),
user_action AS (
    SELECT user_id, 
        CASE 
            WHEN min_page_view IS NOT NULL THEN 1
        END AS page_view_cnt,
        CASE 
            WHEN min_add_to_cart > min_page_view THEN 1
        END AS add_to_cart_cnt,
        CASE 
            WHEN min_checkout > min_add_to_cart AND min_add_to_cart > min_page_view THEN 1
        END AS checkout_cnt,
        CASE 
            WHEN min_purchase > min_checkout AND min_checkout > min_add_to_cart AND min_add_to_cart > min_page_view THEN 1
        END AS purchase_cnt
    FROM earliest_user_action
)
SELECT 'page_view' AS step_name, 
    COUNT(page_view_cnt) AS users_reached,
    0.0 AS pct_dropoff
FROM user_action
UNION ALL
SELECT 'add_to_cart' AS step_name, 
    COUNT(add_to_cart_cnt) AS users_reached,
    ROUND(100.0 - (COUNT(add_to_cart_cnt)*100.0)/(COUNT(page_view_cnt)) , 2) AS pct_dropoff
FROM user_action
UNION ALL
SELECT 'checkout' AS step_name, 
    COUNT(checkout_cnt) AS users_reached,
    ROUND(100.0 - (COUNT(checkout_cnt)*100.0)/(COUNT(add_to_cart_cnt)) , 2) AS pct_dropoff
FROM user_action
UNION ALL
SELECT 'purchase' AS step_name, 
    COUNT(purchase_cnt) AS users_reached,
    ROUND(100.0 - (COUNT(purchase_cnt)*100.0)/(COUNT(checkout_cnt)) , 2) AS pct_dropoff
FROM user_action;