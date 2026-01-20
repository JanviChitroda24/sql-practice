-- https://leetcode.com/problems/game-play-analysis-iv/description/

# Write your MySQL query statement below

-- first you need to group by player_id and event_date
-- ten apply lead function to it for next row and see if the difference between both days is 1
-- then get a count of players where days difference is 1
-- divide the above result by total number of players

-- WITH player_consective_login AS(
--     SELECT player_id, event_date, LEAD(event_date) OVER(PARTITION BY player_id ORDER BY event_date) AS next_day
--     FROM Activity
-- ),
-- player_consective_count AS(
--     SELECT COUNT(DISTINCT player_id)
--     FROM player_consective_login
--     WHERE DATEDIFF(next_day, event_date) = 1
-- )
-- SELECT ROUND( (SELECT * FROM player_consective_count)/COUNT(DISTINCT player_id) ,2) AS fraction
-- FROM Activity


-- NAIVE VERSION
-- WITH first_login_count AS (
--     SELECT COUNT(DISTINCT player_id)
--     FROM (
--         SELECT player_id, event_date, MIN(event_date) OVER(PARTITION BY player_id) AS first_login
--         FROM Activity
--     ) AS first_login_table
--     WHERE DATEDIFF(event_date, first_login) = 1
-- )
-- SELECT ROUND((SELECT * FROM first_login_count)/COUNT(DISTINCT player_id),2)  AS fraction
-- FROM Activity

-- OPTIMIZED VERSION
WITH player_first_login AS (
    SELECT player_id, MIN(event_date) AS first_login
    FROM Activity
    GROUP BY player_id
)
SELECT ROUND((COUNT(DISTINCT a.player_id)/COUNT(f.player_id)),2) AS fraction
FROM player_first_login f LEFT JOIN Activity a
ON a.player_id = f.player_id
AND a.event_date = DATE_ADD(f.first_login, INTERVAL 1 DAY);

