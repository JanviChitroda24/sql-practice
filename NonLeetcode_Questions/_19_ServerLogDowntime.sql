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

WITH server_logs_prev_status AS (
    SELECT log_id, server_id, log_timestamp, status,
        LAG(status) OVER(PARTITION BY server_id ORDER BY log_timestamp) AS prev_log_status
    FROM server_logs 
),
server_logs_filter AS (
    SELECT log_id, server_id, log_timestamp, status,
        LEAD(log_timestamp, 1, '2026-09-18 00:00:00') OVER(PARTITION BY server_id ORDER BY log_timestamp) AS next_log
    FROM server_logs_prev_status 
    WHERE status != prev_log_status OR prev_log_status IS NULL
)
SELECT server_id, 
    SUM(
        CASE
                WHEN status = 'DOWN'
                THEN TIMESTAMPDIFF(MINUTE, log_timestamp, next_log)
            ELSE 0
        END
    ) AS total_downtime_minutes, 
    SUM(
        CASE 
            WHEN status = 'DOWN' 
            THEN 1
        END
    ) AS number_of_incidents
FROM server_logs_filter
GROUP BY server_id;


-- OPTIMIZED SOLUTION
WITH server_logs_prev_status AS (
    SELECT log_id, server_id, log_timestamp, status,
        LAG(status) OVER(PARTITION BY server_id ORDER BY log_timestamp) AS prev_log_status
    FROM server_logs 
),
server_logs_filter AS (
    SELECT log_id, server_id, log_timestamp, status,
        LEAD(log_timestamp, 1, '2026-09-18 00:00:00') OVER(PARTITION BY server_id ORDER BY log_timestamp) AS next_log
    FROM server_logs_prev_status 
    WHERE status != prev_log_status OR prev_log_status IS NULL
)
SELECT server_id,
    SUM(TIMESTAMPDIFF(MINUTE, log_timestamp, next_log)) AS total_downtime_minutes, 
    COUNT(*) AS number_of_incidents
FROM server_logs_filter
WHERE status = 'DOWN'
GROUP BY server_id;