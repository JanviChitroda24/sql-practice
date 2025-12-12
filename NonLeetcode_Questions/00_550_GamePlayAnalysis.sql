-- Table: Activity
-- +--------------+---------+
-- | Column Name  | Type    |
-- +--------------+---------+
-- | player_id    | int     |
-- | device_id    | int     |
-- | event_date   | date    |
-- | games_played | int     |
-- +--------------+---------+
-- (player_id, event_date) is the primary key (combination of columns with unique values) of this table.
-- This table shows the activity of players of some games.
-- Each row is a record of a player who logged in and played a number of games (possibly 0) before logging out on someday using some device.

-- Write a solution to report the fraction of players that logged in again on the day after the day they first logged in, rounded to 2 decimal places. In other words, you need to determine the number of players who logged in on the day immediately following their initial login, and divide it by the number of total players.
-- The result format is in the following example.

-- Example 1:
-- Input: 
-- Activity table:
-- +-----------+-----------+------------+--------------+
-- | player_id | device_id | event_date | games_played |
-- +-----------+-----------+------------+--------------+
-- | 1         | 2         | 2016-03-01 | 5            |
-- | 1         | 2         | 2016-03-02 | 6            |
-- | 2         | 3         | 2017-06-25 | 1            |
-- | 3         | 1         | 2016-03-02 | 0            |
-- | 3         | 4         | 2018-07-03 | 5            |
-- +-----------+-----------+------------+--------------+
-- Output: 
-- +-----------+
-- | fraction  |
-- +-----------+
-- | 0.33      |
-- +-----------+
-- Explanation: 
-- Only the player with id 1 logged back in after the first day he had logged in so the answer is 1/3 = 0.33

-- https://leetcode.com/problems/game-play-analysis-iv/submissions/1848732991/

SELECT ROUND(COUNT(DISTINCT a.player_id)/(SELECT count(DISTINCT player_id) FROM Activity),2) AS fraction
FROM Activity a
WHERE (a.player_id, DATE_ADD(a.event_date, - 1)) IN
(SELECT player_id, min(event_date)
FROM Activity
GROUP BY  player_id)

SELECT ROUND(COUNT( DISTINCT a2.player_id)/(COUNT( DISTINCT a1.player_id)),2)
FROM (
    (SELECT player_id, min(event_date) AS first_login
    FROM Activity 
    GROUP BY player_id) a1
    LEFT JOIN Activity a2 
    ON a1.player_id = a2.player_id AND a1.first_login = DATE_SUB(a2.event_date, INTERVAL 1 DAY)
)

WITH player_func AS (
    SELECT player_id, event_date,
            MIN(event_date) OVER(PARTITION BY player_id) AS min_event_date
    FROM Activity
)
SELECT ROUND(COUNT(DISTINCT player_id)/(SELECT COUNT(DISTINCT player_id) FROM Activity),2) AS fraction
FROM player_func
WHERE DATEDIFF(event_date, min_event_date) = 1


WITH first_login AS (
    SELECT player_id, MIN(event_date) AS first_date
    FROM Activity
    GROUP BY player_id
)
SELECT ROUND(
    COUNT(DISTINCT a.player_id) / (SELECT COUNT(*) FROM first_login)
, 2) AS fraction
FROM first_login f
JOIN Activity a 
    ON f.player_id = a.player_id 
    AND a.event_date = DATE_ADD(f.first_date, INTERVAL 1 DAY)