-- 1369. Get the Second Most Recent Activity
-- https://leetcode.ca/all/1369.html

-- SQL Schema 
-- Table: UserActivity

-- +---------------+---------+
-- | Column Name   | Type    |
-- +---------------+---------+
-- | username      | varchar |
-- | activity      | varchar |
-- | startDate     | Date    |
-- | endDate       | Date    |
-- +---------------+---------+
-- This table does not contain primary key.
-- This table contain information about the activity performed of each user in a period of time.
-- A person with username performed a activity from startDate to endDate.

-- Write an SQL query to show the second most recent activity of each user.

-- If the user only has one activity, return that one. 

-- A user can't perform more than one activity at the same time. Return the result table in any order.

-- The query result format is in the following example:

-- UserActivity table:
-- +------------+--------------+-------------+-------------+
-- | username   | activity     | startDate   | endDate     |
-- +------------+--------------+-------------+-------------+
-- | Alice      | Travel       | 2020-02-12  | 2020-02-20  |
-- | Alice      | Dancing      | 2020-02-21  | 2020-02-23  |
-- | Alice      | Travel       | 2020-02-24  | 2020-02-28  |
-- | Bob        | Travel       | 2020-02-11  | 2020-02-18  |
-- +------------+--------------+-------------+-------------+

-- Result table:
-- +------------+--------------+-------------+-------------+
-- | username   | activity     | startDate   | endDate     |
-- +------------+--------------+-------------+-------------+
-- | Alice      | Dancing      | 2020-02-21  | 2020-02-23  |
-- | Bob        | Travel       | 2020-02-11  | 2020-02-18  |
-- +------------+--------------+-------------+-------------+

-- The most recent activity of Alice is Travel from 2020-02-24 to 2020-02-28, before that she was dancing from 2020-02-21 to 2020-02-23.
-- Bob only has one record, we just take that one.

WITH avtivity_rank AS (
    SELECT username, activity, startDate, endDate,
        DENSE_RANK() OVER(PARTITION BY username ORDER BY endDate DESC) AS act_rank,
        COUNT(username) OVER(PARTITION BY username) AS act_count
    FROM UserActivity
)
SELECT username, activity, startDate, endDate
FROM avtivity_rank
WHERE (act_count > 1 AND act_rank = 2) OR (act_count= 1 AND act_rank = 1);

-- approach 2: simplified where clasue
WITH avtivity_rank AS (
    SELECT username, activity, startDate, endDate,
        DENSE_RANK() OVER(PARTITION BY username ORDER BY endDate DESC) AS act_rank,
        COUNT(username) OVER(PARTITION BY username) AS act_count
    FROM UserActivity
)
SELECT username, activity, startDate, endDate
FROM avtivity_rank
WHERE act_rank=2 OR act_count=1;