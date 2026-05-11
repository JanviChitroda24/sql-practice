-- 1097. Game Play Analysis V
-- https://leetcode.ca/all/1097.html

-- 1097. Game Play Analysis V
-- Table: Activity
-- +--------------+---------+
-- | Column Name  | Type    |
-- +--------------+---------+
-- | player_id    | int     |
-- | device_id    | int     |
-- | event_date   | date    |
-- | games_played | int     |
-- +--------------+---------+
-- (player_id, event_date) is the primary key of this table.
-- This table shows the activity of players of some game.
-- Each row is a record of a player who logged in and played a number of games (possibly 0) before logging out on some day using some device.
 

-- We define the install date of a player to be the first login day of that player.

-- We also define day 1 retention of some date X to be the number of players whose install date is X and they logged back in on the day right after X, divided by the number of players whose install date is X, rounded to 2 decimal places.

-- Write an SQL query that reports for each install date, the number of players that installed the  game on that day and the day 1 retention.

-- The query result format is in the following example:

-- Activity table:
-- +-----------+-----------+------------+--------------+
-- | player_id | device_id | event_date | games_played |
-- +-----------+-----------+------------+--------------+
-- | 1         | 2         | 2016-03-01 | 5            |
-- | 1         | 2         | 2016-03-02 | 6            |
-- | 2         | 3         | 2017-06-25 | 1            |
-- | 3         | 1         | 2016-03-01 | 0            |
-- | 3         | 4         | 2016-07-03 | 5            |
-- +-----------+-----------+------------+--------------+

-- Result table:
-- +------------+----------+----------------+
-- | install_dt | installs | Day1_retention |
-- +------------+----------+----------------+
-- | 2016-03-01 | 2        | 0.50           |
-- | 2017-06-25 | 1        | 0.00           |
-- +------------+----------+----------------+
-- Player 1 and 3 installed the game on 2016-03-01 but only player 1 logged back in on 2016-03-02 so the day 1 retention of 2016-03-01 is 1 / 2 = 0.50
-- Player 2 installed the game on 2017-06-25 but didn't log back in on 2017-06-26 so the day 1 retention of 2017-06-25 is 0 / 1 = 0.00


-- 1 --> 2 CTE + IN CLAUSE (Naive version)
WITH player_info AS (
    SELECT player_id, event_date, 
            MIN(event_date) OVER(PARTITION BY player_id ORDER BY event_date) AS install_dt
    FROM Activity
),
player_retention AS (
    SELECT player_id, install_dt, 
        CASE 
            WHEN 
                DATE_ADD(pi.install_dt, INTERVAL 1 DAY) IN  
                    (SELECT DISTINCT event_date 
                    FROM Activity a
                    WHERE a.player_id = pi.player_id) 
                THEN 1
            ELSE 0
        END AS retention_check
    FROM player_info pi
    GROUP BY player_id, install_dt
)
SELECT install_dt, COUNT(player_id) AS installs, ROUND(((SUM(retention_check)*1.0)/COUNT(player_id)),2) AS Day1_retention
FROM player_retention
GROUP BY install_dt;

-- 2 --> CTE + EXIST CLAUSE
WITH player_info AS (
    SELECT player_id, MIN(event_date) AS install_dt
    FROM Activity
    GROUP BY player_id
),
retention_info AS (
    SELECT pi.player_id
    FROM player_info pi
    WHERE EXISTS (
        SELECT 1 
        FROM Activity a
        WHERE a.player_id = pi.player_id 
            AND a.event_date = DATE_ADD(pi.install_dt, INTERVAL 1 DAY)
    )
)
SELECT pi.install_dt, 
        COUNT(pi.player_id) AS installs, 
         ROUND((COUNT(ri.player_id)*1.0)/COUNT(pi.player_id),2) AS Day1_retention
FROM player_info pi LEFT JOIN retention_info ri
    ON pi.player_id = ri.player_id
GROUP BY pi.install_dt

-- 3 --> optimized version: 1 CTE + LEFT JOIN
WITH player_info AS (
    SELECT player_id, 
            MIN(event_date) AS install_dt
    FROM Activity
    GROUP BY player_id
)
SELECT pi.install_dt, 
        COUNT(pi.player_id) AS installs, 
        ROUND((COUNT(a.player_id)*1.0)/COUNT(pi.player_id),2) AS Day1_retention
FROM player_info pi LEFT JOIN Activity a 
    ON pi.player_id = a.player_id
    AND a.event_date = DATE_ADD(pi.install_dt, INTERVAL 1 DAY)
GROUP BY install_dt;

-- | Factor | Approach 1 (CTE + IN) | Approach 2 (CTE + EXISTS) | Approach 3 (CTE + LEFT JOIN) |
-- |---|---|---|---|
-- | CTEs used | 2 | 2 | 1 |
-- | Correlated subquery | Yes (per player) | Yes (per player) | None |
-- | Table scans | Multiple | 2-3 | 2 |
-- | Short-circuits | No (IN builds full list) | Yes (stops at first match) | N/A (single join) |
-- | Memory | Higher (window + list) | Medium | Lowest |
-- | Readability | Most verbose | Medium | Cleanest |
-- | Small table | Fine | Fine | Fine |
-- | Large table | Slowest | Medium | Fastest |
-- | Interview value | Shows CASE + window thinking | Shows EXISTS pattern | Shows efficient JOIN design |

-- **Bottom line:** Approach 3 wins on every practical metric — fewest scans, no correlated subquery, least code. Lead with it in interviews. Mention Approach 2 if they ask for alternatives, and Approach 1 only if they specifically ask about a CASE-based solution.