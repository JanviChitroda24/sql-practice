-- Q4

-- You have a table called user_events:

-- user_events
-- ├── event_id       INT (PK)
-- ├── user_id        INT
-- ├── event_type     VARCHAR(50)
-- ├── event_date     DATE
-- ├── created_at     DATETIME

-- The table has duplicate rows — same user_id, event_type, and event_date appearing multiple times due to a logging bug. 
-- Write a query that returns a deduplicated result set, 
-- keeping only the most recent entry (by created_at) per user_id, event_type, and event_date combination. Return all five columns.

WITH user_dedup AS (
    SELECT event_id, user_id, event_type, event_date, created_at,
        ROW_NUMBER() OVER(PARTITION BY user_id, event_type, event_date ORDER BY created_at DESC) AS user_rank
    FROM user_events
)
SELECT event_id, user_id, event_type, event_date, created_at
FROM user_dedup
WHERE user_rank = 1
