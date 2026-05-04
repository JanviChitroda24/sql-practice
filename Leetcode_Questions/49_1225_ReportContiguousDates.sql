-- https://leetcode.ca/all/1225.html

-- 1225. Report Contiguous Dates
-- Table: Failed

-- +--------------+---------+
-- | Column Name  | Type    |
-- +--------------+---------+
-- | fail_date    | date    |
-- +--------------+---------+
-- Primary key for this table is fail_date.
-- Failed table contains the days of failed tasks.


-- Table: Succeeded

-- +--------------+---------+
-- | Column Name  | Type    |
-- +--------------+---------+
-- | success_date | date    |
-- +--------------+---------+
-- Primary key for this table is success_date.
-- Succeeded table contains the days of succeeded tasks.
 

-- A system is running one task every day. Every task is independent of the previous tasks. The tasks can fail or succeed.

-- Write an SQL query to generate a report of period_state for each continuous interval of days in the period from 2019-01-01 to 2019-12-31.

-- period_state is 'failed' if tasks in this interval failed or 'succeeded' if tasks in this interval succeeded. Interval of days are retrieved as start_date and end_date.

-- Order result by start_date.

-- The query result format is in the following example:

-- Failed table:
-- +-------------------+
-- | fail_date         |
-- +-------------------+
-- | 2018-12-28        |
-- | 2018-12-29        |
-- | 2019-01-04        |
-- | 2019-01-05        |
-- +-------------------+

-- Succeeded table:
-- +-------------------+
-- | success_date      |
-- +-------------------+
-- | 2018-12-30        |
-- | 2018-12-31        |
-- | 2019-01-01        |
-- | 2019-01-02        |
-- | 2019-01-03        |
-- | 2019-01-06        |
-- +-------------------+


-- Result table:
-- +--------------+--------------+--------------+
-- | period_state | start_date   | end_date     |
-- +--------------+--------------+--------------+
-- | succeeded    | 2019-01-01   | 2019-01-03   |
-- | failed       | 2019-01-04   | 2019-01-05   |
-- | succeeded    | 2019-01-06   | 2019-01-06   |
-- +--------------+--------------+--------------+

-- The report ignored the system state in 2018 as we care about the system in the period 2019-01-01 to 2019-12-31.
-- From 2019-01-01 to 2019-01-03 all tasks succeeded and the system state was "succeeded".
-- From 2019-01-04 to 2019-01-05 all tasks failed and system state was "failed".
-- From 2019-01-06 to 2019-01-06 all tasks succeeded and system state was "succeeded".

WITH required_date AS (
    SELECT fail_date AS req_date, "failed" AS period_state
    FROM Failed
    WHERE fail_date BETWEEN '2019-01-01' AND '2019-12-31'

    UNION 

    SELECT success_date AS req_date, "succeeded" AS period_state
    FROM Succeeded
    WHERE success_date BETWEEN '2019-01-01' AND '2019-12-31'
),
rn_date AS (
    SELECT req_date, period_state, 
            ROW_NUMBER() OVER(ORDER BY req_date) AS rn,  
            ROW_NUMBER() OVER(PARTITION BY period_state ORDER BY req_date) AS rn_state
    FROM required_date
),
group_date AS (
    SELECT req_date, period_state, 
            rn-rn_state AS group_clause
    FROM rn_date
    ORDER BY req_date
)
SELECT period_state, MIN(req_date) AS start_date, MAX(req_date) AS end_date
FROM group_date
GROUP BY period_state, group_clause