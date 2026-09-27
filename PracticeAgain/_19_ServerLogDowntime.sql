-- You have a table called server_logs:

-- server_logs
-- ├── log_id          INT (PK)
-- ├── server_id       INT
-- ├── log_timestamp   DATETIME
-- ├── status          VARCHAR(20)  ('UP' or 'DOWN')

-- Each row records a server's status at a point in time. 
-- Write a query that calculates the total downtime in minutes for each server. 
-- Downtime starts when status changes to 'DOWN' and ends when the next status is 'UP'. 
-- If a server's most recent status is 'DOWN', treat it as still down — use '2026-09-18 00:00:00' as the end time. 
-- Return server_id, total_downtime_minutes, and number_of_incidents (how many separate DOWN periods occurred).

WITH logs_prev_status AS (
    SELECT log_id, server_id, log_timestamp, status,
        LAG(status) OVER(PARTITION BY server_id ORDER BY log_timestamp) AS prev_status
    FROM server_logs
),
filter_prev_logs AS (
    SELECT log_id, server_id, log_timestamp, status, 
        LEAD(status) OVER(PARTITION BY server_id ORDER BY log_timestamp) AS next_status,
        LEAD(log_timestamp,1,'2026-09-18 00:00:00') OVER(PARTITION BY server_id ORDER BY log_timestamp) AS next_timestamp
    FROM logs_prev_status
    -- WHERE (status = 'DOWN' AND prev_status != 'DOWN') OR (status = 'UP' AND prev_status = 'DOWN')
    WHERE status != prev_status OR prev_status IS NULL
)
SELECT server_id, 
    SUM(TIMESTAMPDIFF(MINUTE,log_timestamp, next_timestamp)) AS total_downtime_minutes,
    COUNT(*) AS number_of_incidents
FROM filter_prev_logs
WHERE status='DOWN'
GROUP BY server_id;