-- 1194. Tournament Winners
-- https://leetcode.ca/all/1194.html

-- Table: Players

-- +-------------+-------+
-- | Column Name | Type  |
-- +-------------+-------+
-- | player_id   | int   |
-- | group_id    | int   |
-- +-------------+-------+
-- player_id is the primary key of this table.
-- Each row of this table indicates the group of each player.
-- Table: Matches

-- +---------------+---------+
-- | Column Name   | Type    |
-- +---------------+---------+
-- | match_id      | int     |
-- | first_player  | int     |
-- | second_player | int     |
-- | first_score   | int     |
-- | second_score  | int     |
-- +---------------+---------+
-- match_id is the primary key of this table.
-- Each row is a record of a match, first_player and second_player contain the player_id of each match.
-- first_score and second_score contain the number of points of the first_player and second_player respectively.
-- You may assume that, in each match, players belongs to the same group.
 


-- The winner in each group is the player who scored the maximum total points within the group. In the case of a tie, the lowest player_id wins.

-- Write an SQL query to find the winner in each group.Programming

-- The query result format is in the following example:

-- Players table:
-- +-----------+------------+
-- | player_id | group_id   |
-- +-----------+------------+
-- | 15        | 1          |
-- | 25        | 1          |
-- | 30        | 1          |
-- | 45        | 1          |
-- | 10        | 2          |
-- | 35        | 2          |
-- | 50        | 2          |
-- | 20        | 3          |
-- | 40        | 3          |
-- +-----------+------------+

-- Matches table:
-- +------------+--------------+---------------+-------------+--------------+
-- | match_id   | first_player | second_player | first_score | second_score |
-- +------------+--------------+---------------+-------------+--------------+
-- | 1          | 15           | 45            | 3           | 0            |
-- | 2          | 30           | 25            | 1           | 2            |
-- | 3          | 30           | 15            | 2           | 0            |
-- | 4          | 40           | 20            | 5           | 2            |
-- | 5          | 35           | 50            | 1           | 1            |
-- +------------+--------------+---------------+-------------+--------------+

-- Result table:
-- +-----------+------------+
-- | group_id  | player_id  |
-- +-----------+------------+
-- | 1         | 15         |
-- | 2         | 35         |
-- | 3         | 40         |
-- +-----------+------------+


WITH player_unpivot AS (
    SELECT first_player AS player_id, first_score AS player_score
    FROM Matches
    UNION ALL 
    SELECT second_player AS player_id, second_score AS player_score
    FROM Matches
),
player_score AS (
    SELECT player_id, SUM(player_score) AS player_score
    FROM player_unpivot
    GROUP BY player_id
),
player_score_join AS (
    SELECT p.player_id, p.group_id, COALESCE(ps.player_score, 0), 
        ROW_NUMBER() OVER(PARTITION BY p.group_id ORDER BY COALESCE(ps.player_score, 0) DESC, p.player_id) AS player_rank
    FROM Players p LEFT JOIN player_score ps 
        ON p.player_id = ps.player_id
)
SELECT group_id, player_id
FROM player_score_join
WHERE player_rank = 1
ORDER BY group_id;

-- WITH winner_stat AS (
--     SELECT 
--             CASE 
--                 WHEN first_score > second_score THEN first_player
--                 WHEN second_score > first_score THEN second_player
--                 ELSE (
--                     CASE 
--                     WHEN first_player < second_player THEN first_player
--                     ELSE second_player
--                 )
--             END AS winner_player, 
--             CASE 
--                 WHEN first_score > second_score THEN first_score
--                 WHEN second_score > first_score THEN second_score
--                 ELSE first_score
--             END AS winner_score
--     FROM Matches
-- )
-- SELECT p.group_id, MIN(p.player_id)
-- FROM Players p LEFT JOIN winner_stat w
--     ON p.player_id = w.winner_player
-- GROUP BY p.group_id
-- HAVING MAX(w.winner_score)
-- ORDER BY p.group_id;