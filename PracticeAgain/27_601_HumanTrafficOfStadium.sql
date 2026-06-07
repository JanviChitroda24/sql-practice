-- 601. Human Traffic of Stadium
-- https://leetcode.com/problems/human-traffic-of-stadium/description/

-- # Write your MySQL query statement below

-- Table: Stadium

-- +---------------+---------+
-- | Column Name   | Type    |
-- +---------------+---------+
-- | id            | int     |
-- | visit_date    | date    |
-- | people        | int     |
-- +---------------+---------+
-- visit_date is the column with unique values for this table.
-- Each row of this table contains the visit date and visit id to the stadium with the number of people during the visit.
-- As the id increases, the date increases as well.
 

-- Write a solution to display the records with three or more rows with consecutive id's, and the number of people is greater than or equal to 100 for each.

-- Return the result table ordered by visit_date in ascending order.

-- The result format is in the following example.

 

-- Example 1:

-- Input: 
-- Stadium table:
-- +------+------------+-----------+
-- | id   | visit_date | people    |
-- +------+------------+-----------+
-- | 1    | 2017-01-01 | 10        |
-- | 2    | 2017-01-02 | 109       |
-- | 3    | 2017-01-03 | 150       |
-- | 4    | 2017-01-04 | 99        |
-- | 5    | 2017-01-05 | 145       |
-- | 6    | 2017-01-06 | 1455      |
-- | 7    | 2017-01-07 | 199       |
-- | 8    | 2017-01-09 | 188       |
-- +------+------------+-----------+
-- Output: 
-- +------+------------+-----------+
-- | id   | visit_date | people    |
-- +------+------------+-----------+
-- | 5    | 2017-01-05 | 145       |
-- | 6    | 2017-01-06 | 1455      |
-- | 7    | 2017-01-07 | 199       |
-- | 8    | 2017-01-09 | 188       |
-- +------+------------+-----------+
-- Explanation: 
-- The four rows with ids 5, 6, 7, and 8 have consecutive ids and each of them has >= 100 people attended. Note that row 8 was included even though the visit_date was not the next day after row 7.
-- The rows with ids 2 and 3 are not included because we need at least three consecutive ids.

-- -- LAG SOLUTION
-- WITH prev_info AS (
--     SELECT id, visit_date, people, 
--         LAG(id,1) OVER(ORDER BY id) AS prev_id,
--         LAG(id,2) OVER(ORDER BY id) AS prev_2_id,
--         LAG(people,1) OVER(ORDER BY id) AS prev_people,
--         LAG(people,2) OVER(ORDER BY id) AS prev_2_people
--     FROM Stadium
-- )
-- SELECT DISTINCT id, visit_date, people
-- FROM prev_info 
-- WHERE id = prev_id+1 AND id = prev_2_id+2 AND
--     people >= 100 AND prev_people >= 100 AND prev_2_people >= 100;

-- -- JOIN SOLUTION
-- SELECT DISTINCT 
-- FROM Stadium s1 JOIN Stadium s2
--         ON s1.id = s2.id-1
--     JOIN Stadium s3 
        -- ON s1.id = s3.id-1

-- This is a gap in the island problem:
-- Pattern: if we: 
--     **find consecutive rows that satisfy a condition and return ALL rows in those groups**
-- Then its a gap in the island problem since we need all the rows in that group!!

WITH required_rows AS (
    SELECT id, visit_date, people
    FROM Stadium
    WHERE people >= 100
),
required_rows_rn AS (
    SELECT id, visit_date, people,
        ROW_NUMBER() OVER(ORDER BY id) AS rn
    FROM required_rows
),
rn_id_diff AS (
    SELECT id, visit_date, people, rn, 
        id-rn AS diff
    FROM required_rows_rn
),
diff_count AS (
    SELECT id, visit_date, people,
        COUNT(diff) OVER(PARTITION BY diff) AS record_count
    FROM rn_id_diff
)
SELECT id, visit_date, people
FROM diff_count
WHERE record_count >= 3;


-- optimized -- reduce cte 
WITH required_rows AS (
    SELECT id, visit_date, people
    FROM Stadium
    WHERE people >= 100
),
required_rows_rn AS (
    SELECT id, visit_date, people,
        ROW_NUMBER() OVER(ORDER BY id) AS rn
    FROM required_rows
),
diff_count AS (
    SELECT id, visit_date, people,
        COUNT(*) OVER(PARTITION BY id-rn) AS record_count
    FROM required_rows_rn
)
SELECT id, visit_date, people
FROM diff_count
WHERE record_count >= 3;

-- optimized -- most less cte (nested window function)
WITH required_rows AS (
    SELECT id, visit_date, people
    FROM Stadium
    WHERE people >= 100
),
diff_count AS (
    SELECT id, visit_date, people,
        COUNT(*) OVER(PARTITION BY id - ROW_NUMBER() OVER(ORDER BY id)) AS record_count
    FROM required_rows
)
SELECT id, visit_date, people
FROM diff_count
WHERE record_count >= 3;

-- nested window function inside the PARTITION BY is valid

-- The Steps (every gap-and-island problem):
-- Filter — keep only rows meeting your condition
-- Number — assign ROW_NUMBER ordered by the sequential column (id, date, etc.)
-- Subtract — sequential column minus ROW_NUMBER gives you a group label
-- Use the group — COUNT, filter by group size, aggregate, whatever the problem needs