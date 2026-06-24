-- 1699. Number of Calls Between Two Persons
-- http://leetcode.ca/all/1699.html

-- SQL Schema 
-- Table: Calls

-- +-------------+---------+
-- | Column Name | Type    |
-- +-------------+---------+
-- | from_id     | int     |
-- | to_id       | int     |
-- | duration    | int     |
-- +-------------+---------+
-- This table does not have a primary key, it may contain duplicates.
-- This table contains the duration of a phone call between from_id and to_id.
-- from_id != to_id
 

-- Write an SQL query to report the number of calls and the total call duration between each pair of distinct persons (person1, person2) where person1 < person2.

-- Return the result table in any order.Internet & Telecom

-- The query result format is in the following example:

 

-- Calls table:
-- +---------+-------+----------+
-- | from_id | to_id | duration |
-- +---------+-------+----------+
-- | 1       | 2     | 59       |
-- | 2       | 1     | 11       |
-- | 1       | 3     | 20       |
-- | 3       | 4     | 100      |
-- | 3       | 4     | 200      |
-- | 3       | 4     | 200      |
-- | 4       | 3     | 499      |
-- +---------+-------+----------+

-- Result table:
-- +---------+---------+------------+----------------+
-- | person1 | person2 | call_count | total_duration |
-- +---------+---------+------------+----------------+
-- | 1       | 2       | 2          | 70             |
-- | 1       | 3       | 1          | 20             |
-- | 3       | 4       | 4          | 999            |
-- +---------+---------+------------+----------------+
-- Users 1 and 2 had 2 calls and the total duration is 70 (59 + 11).
-- Users 1 and 3 had 1 call and the total duration is 20.
-- Users 3 and 4 had 4 calls and the total duration is 999 (100 + 200 + 200 + 499).
-- Difficulty:
-- Medium


-- SELECT c1.from_id AS person1, c2.to_id AS person2, COUNT(*) call_count, SUM(duration) AS total_duration
-- FROM Calls c1 JOIN Calls c2
--     ON c1.from_id=c2.to_id AND c1.to_id=c2.from_id
-- WHERE c1.from_id > c1.to_id
-- GROUP BY c1.from_id,  C2.to_id;

SELECT LEAST(from_id, to_id) AS person1, 
    GREATEST(from_id, to_id) AS person2, 
    COUNT(*) AS call_count, SUM(duration) AS total_duration
FROM Calls
GROUP BY LEAST(from_id, to_id), GREATEST(from_id, to_id);

-- alternative approach using UNION 

WITH calls_joined AS (
    SELECT from_id AS person1, to_id AS person2, duration
    FROM Calls
    UNION ALL
    SELECT to_id AS person1, from_id AS person2, duration
    FROM Calls
) 
SELECT person1, person2, COUNT(*) AS call_count, SUM(duration) AS total_duration
FROM calls_joined
WHERE person1 < person2
GROUP BY person1, person2;