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

-- ============================================================================
-- CORRECTNESS: YES, your solution is correct.
-- ============================================================================
-- Why it works:
--  1. first_login = MIN(event_date) OVER (PARTITION BY player_id) gives each
--     player's earliest login date on every row.
--  2. WHERE event_date = first_login keeps only rows that are each player's
--     first login.
--  3. SELECT DISTINCT player_id, device_id returns one row per (player, device)
--     that was used on that first login. For the usual test data (one device per
--     first login per player), this yields exactly one row per player and
--     matches the expected result.
-- Edge case: If a player first logged in on the same date from two different
-- devices, this query returns both (player_id, device_id) pairs. The problem
-- asks for "the device" (singular); if a judge expects strictly one row per
-- player when there are ties, you’d need a tie-breaker (e.g. MIN(device_id)).
-- For standard LeetCode 512 test data, your solution is correct.
-- ============================================================================

WITH player_loggedd_info AS (
    SELECT player_id, device_id, event_date, min(event_date) over (partition by player_id) as first_login
    FROM Activity
)
SELECT DISTINCT player_id, device_id
FROM player_loggedd_info
WHERE event_date=first_login;

-- ============================================================================
-- CAN THIS BE MORE OPTIMIZED?
-- Your solution is already O(n) and efficient. One small improvement:
-- Use ROW_NUMBER() so you get exactly one row per player without DISTINCT,
-- and the optimizer can stop per partition after the first row (in some engines).
-- Slightly cleaner and guarantees one device per player (tie-break by device_id).
-- ============================================================================
--
-- OUTPUT OF JUST THE INNER SELECT (how rn changes with player_id, device_id):
-- Using sample Activity data from the problem:
--
--   SELECT player_id, device_id,
--          ROW_NUMBER() OVER (PARTITION BY player_id ORDER BY event_date, device_id) AS rn
--   FROM Activity
--
--   player_id | device_id | rn
--   ----------+-----------+----
--   1         | 2         | 1   <- player 1's first login (2016-03-01)
--   1         | 2         | 2   <- player 1's second login (2016-05-02)
--   2         | 3         | 1   <- player 2's only login
--   3         | 1         | 1   <- player 3's first login (2016-03-02)
--   3         | 4         | 2   <- player 3's second login (2018-07-03)
--
-- So: rn resets to 1 for each player_id (PARTITION BY player_id), and within
-- each player it increases 1, 2, 3... by event_date then device_id (ORDER BY).
-- WHERE rn = 1 keeps only the first row per player = first login device.
--
-- ============================================================================
WITH first_login_device AS (
    SELECT player_id, device_id,
           ROW_NUMBER() OVER (PARTITION BY player_id ORDER BY event_date, device_id) AS rn
    FROM Activity
)
SELECT player_id, device_id
FROM first_login_device
WHERE rn = 1;
