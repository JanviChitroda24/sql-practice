-- 1285. Find the Start and End Number of Continuous Ranges
-- https://leetcode.ca/all/1285.html

-- Table: Logs
-- +---------------+---------+
-- | Column Name   | Type    |
-- +---------------+---------+
-- | log_id        | int     |
-- +---------------+---------+
-- id is the primary key for this table.
-- Each row of this table contains the ID in a log Table.

-- Since some IDs have been removed from Logs. Write an SQL query to find the start and end number of continuous ranges in table Logs.

-- Order the result table by start_id.

-- The query result format is in the following example:Programming

-- Logs table:
-- +------------+
-- | log_id     |
-- +------------+
-- | 1          |
-- | 2          |
-- | 3          |
-- | 7          |
-- | 8          |
-- | 10         |
-- +------------+

-- Result table:
-- +------------+--------------+
-- | start_id   | end_id       |
-- +------------+--------------+
-- | 1          | 3            |
-- | 7          | 8            |
-- | 10         | 10           |
-- +------------+--------------+
-- The result table should contain all ranges in table Logs.
-- From 1 to 3 is contained in the table.
-- From 4 to 6 is missing in the table
-- From 7 to 8 is contained in the table.
-- Number 9 is missing in the table.
-- Number 10 is contained in the table.

WITH logs_row_no AS (
    SELECT log_id, ROW_NUMBER() OVER(ORDER BY log_id) AS log_rn
    FROM Logs
),
log_difference AS (
    SELECT log_id, log_rn, 
        log_rn-log_id AS log_diff
    FROM logs_row_no
),
log_start_end AS (
    SELECT 
        MIN(log_id) OVER(PARTITION BY log_diff) AS start_id,
        MAX(log_id) OVER(PARTITION BY log_diff) AS end_id
    FROM log_difference
)
SELECT start_id, end_id
FROM log_start_end
GROUP BY start_id, end_id;

-- OPTIMIZATION: USING GROUP BY DIRECTLY WITHOUT PARTITION BY TO REDUCE CTE 
WITH logs_row_no AS (
    SELECT log_id, ROW_NUMBER() OVER(ORDER BY log_id) AS log_rn
    FROM Logs
),
log_difference AS (
    SELECT log_id, log_rn, 
        log_rn-log_id AS log_diff
    FROM logs_row_no
)
SELECT MIN(log_id) AS start_id, MAX(log_id) AS end_id
FROM log_difference
GROUP BY log_diff
ORDER BY start_id;