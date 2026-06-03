"""
512 - Game Play Analysis II
https://leetcode.ca/all/512.html

Write a SQL query that reports the device that is first logged in for each player.


+--------------+---------+
| Column Name  | Type    |
+--------------+---------+
| player_id    | int     |
| device_id    | int     |
| event_date   | date    |
| games_played | int     |
+--------------+---------+
(player_id, event_date) is the primary key of this table.
This table shows the activity of players of some game.
Each row is a record of a player who logged in and played a number of games (possibly 0) before logging out on some day using some device.

The query result format is in the following example:

Activity table:
+-----------+-----------+------------+--------------+
| player_id | device_id | event_date | games_played |
+-----------+-----------+------------+--------------+
| 1         | 2         | 2016-03-01 | 5            |
| 1         | 2         | 2016-05-02 | 6            |
| 2         | 3         | 2017-06-25 | 1            |
| 3         | 1         | 2016-03-02 | 0            |
| 3         | 4         | 2018-07-03 | 5            |
+-----------+-----------+------------+--------------+

Result table:
+-----------+-----------+
| player_id | device_id |
+-----------+-----------+
| 1         | 2         |
| 2         | 3         |
| 3         | 1         |
+-----------+-----------+
"""
WITH device_rank AS (
    SELECT player_id, device_id, 
        ROW_NUMBER() OVER(PARTITION BY player_id ORDER BY event_date) AS device_rn
    FROM Activity
)
SELECT player_id, device_id
FROM device_rank
WHERE device_rn = 1;

WITH min_date AS (
    SELECT player_id, MIN(event_date) AS min_event_date
    FROM Activity
    GROUP BY player_id
)
SELECT player_id, device_id
FROM Activity
WHERE (player_id, event_date) IN (min_date);

SELECT player_id, device_id
FROM Activity
WHERE (player_id, event_date) IN 
    (SELECT player_id, MIN(event_date) AS min_event_date
        FROM Activity
        GROUP BY player_id
    );

SELECT player_id, device_id
FROM Activity a
WHERE EXISTS 
    (SELECT 1
        FROM Activity b
        WHERE a.player_id = b.player_id
        HAVING a.event_date = MIN(event_date)
    );


WITH act_min_date AS (
    SELECT player_id, MIN(event_date) AS min_date
    FROM Activity
    GROUP BY player_id
)
SELECT a.player_id, a.device_id
FROM Activity a JOIN act_min_date b
    ON a.player_id = b.player_id AND a.event_date = b.min_date

-- ### Approach Comparison

-- | Approach | Pattern | Efficiency |
-- |----------|---------|------------|
-- | `ROW_NUMBER() WHERE rn = 1` | Window — Ranking | ⭐⭐⭐ Good — single pass, but window functions have overhead |
-- | `(player_id, event_date) IN (subquery)` | GROUP BY + Aggregate | ⭐⭐⭐⭐ Best — subquery runs once, tuple match is clean |
-- | `JOIN` on min date CTE | GROUP BY + Aggregate | ⭐⭐⭐⭐ Best — same as above, just expressed as JOIN |
-- | `WHERE EXISTS ... HAVING MIN()` | Correlated subquery | ⭐⭐ Worst — runs once per outer row, most expensive |

-- ---

-- ### Winner: **`IN` with tuple match or CTE + JOIN**
-- Both are equivalent in performance. The subquery for min date runs **once**, result is computed upfront, then matched against the main table. Clean and efficient.

-- ---

-- ### Rule of thumb to remember:
-- > Correlated subquery (`EXISTS`, `HAVING MIN()`) — elegant but **runs once per outer row**. 
    -- Always ask: *can I compute this once upfront instead?* If yes, use `GROUP BY` + `IN` or `JOIN`.

-- HAVING without GROUP BY — treats entire subquery result as one group. 
-- Useful inside correlated subqueries to filter on aggregates without needing GROUP BY.