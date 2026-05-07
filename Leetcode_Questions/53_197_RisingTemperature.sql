-- https://leetcode.com/problems/rising-temperature/description/

-- 197. Rising Temperature

-- Table: Weather

-- +---------------+---------+
-- | Column Name   | Type    |
-- +---------------+---------+
-- | id            | int     |
-- | recordDate    | date    |
-- | temperature   | int     |
-- +---------------+---------+
-- id is the column with unique values for this table.
-- There are no different rows with the same recordDate.
-- This table contains information about the temperature on a certain day.
 

-- Write a solution to find all dates' id with higher temperatures compared to its previous dates (yesterday).

-- Return the result table in any order.

-- The result format is in the following example.

 

-- Example 1:

-- Input: 
-- Weather table:
-- +----+------------+-------------+
-- | id | recordDate | temperature |
-- +----+------------+-------------+
-- | 1  | 2015-01-01 | 10          |
-- | 2  | 2015-01-02 | 25          |
-- | 3  | 2015-01-03 | 20          |
-- | 4  | 2015-01-04 | 30          |
-- +----+------------+-------------+
-- Output: 
-- +----+
-- | id |
-- +----+
-- | 2  |
-- | 4  |
-- +----+
-- Explanation: 
-- In 2015-01-02, the temperature was higher than the previous day (10 -> 25).
-- In 2015-01-04, the temperature was higher than the previous day (20 -> 30).


# Write your MySQL query statement below
WITH temp_comparison AS (
    SELECT id, recordDate, temperature, 
            LAG(temperature) OVER(ORDER BY recordDate) AS prev_day_temp,
            LAG(recordDate) OVER(ORDER BY recordDate) AS prev_day_date
    FROM Weather
)
SELECT id
FROM temp_comparison
WHERE temperature > prev_day_temp AND DATEDIFF(recordDate, prev_day_date) = 1;




-- If you have an index on recordDate:

-- JOIN can be very fast (index lookup)
-- Window function still requires sorting

-- 👉 If data is large and already sorted:

-- Your solution is excellent

-- 👉 If indexed lookup matters:

-- JOIN may be slightly more optimal

-- Right side defines the anchor day, left side shifts relative to it.
-- I am not assigning values — I am matching time relationships.

-- | SQL condition | Meaning             |
-- | ------------- | ------------------- |
-- | `A = B - 1`   | A is yesterday of B |
-- | `A = B + 1`   | A is tomorrow of B  |

SELECT cur_w.id
FROM Weather cur_w JOIN Weather prev_w
ON cur_w.recordDate = DATE_ADD(prev_w.recordDate, INTERVAL 1 DAY)
WHERE cur_w.temperature > prev_w.temperature;