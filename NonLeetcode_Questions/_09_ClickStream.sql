-- You have a table called clickstream:

-- clickstream
-- ├── event_id       INT (PK)
-- ├── user_id        INT
-- ├── event_time     DATETIME
-- ├── page_url       VARCHAR(255)

-- Users browse a website and each click generates a row. 
-- A session ends when there's a gap of 30 minutes or more between consecutive events for the same user. 
-- Write a query that assigns a session_id to each event and returns user_id, event_id, event_time, page_url, and session_id. 
-- The session_id should be sequential per user (1, 2, 3...).


WITH prev_event_time AS (
    SELECT event_id, user_id, event_time, page_url,
        LAG(event_time) OVER( PARTITION BY user_id ORDER BY event_time) AS prev_time
    FROM clickstream
),
event_time_comparision AS (
    SELECT  event_id, user_id, event_time, page_url, 
        CASE 
            WHEN prev_time IS NULL THEN 1
            WHEN TIMESTAMPDIFF(MINUTE, prev_time, event_time) >= 30 THEN 1
            ELSE 0
        END AS new_session_check
    FROM prev_event_time
)
SELECT user_id, event_id, event_time, page_url, 
    SUM(new_session_check) OVER(PARTITION BY user_id ORDER BY event_time ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS session_id
FROM event_time_comparision;