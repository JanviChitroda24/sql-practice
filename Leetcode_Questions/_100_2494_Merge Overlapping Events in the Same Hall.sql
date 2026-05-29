-- 2494 - Merge Overlapping Events in the Same Hall
-- https://leetcode.ca/2023-01-21-2494-Merge-Overlapping-Events-in-the-Same-Hall/

-- 2494. Merge Overlapping Events in the Same Hall
-- Description

-- Table: HallEvents

-- +-------------+------+
-- | Column Name | Type |
-- +-------------+------+
-- | hall_id     | int  |
-- | start_day   | date |
-- | end_day     | date |
-- +-------------+------+
-- There is no primary key in this table. It may contain duplicates.
-- Each row of this table indicates the start day and end day of an event and the hall in which the event is held.
 

-- Write an SQL query to merge all the overlapping events that are held in the same hall. Two events overlap if they have at least one day in common.Programming

-- Return the result table in any order.

-- The query result format is in the following example.

 

-- Example 1:

-- Input: 
-- HallEvents table:
-- +---------+------------+------------+
-- | hall_id | start_day  | end_day    |
-- +---------+------------+------------+
-- | 1       | 2023-01-13 | 2023-01-14 |
-- | 1       | 2023-01-14 | 2023-01-17 |
-- | 1       | 2023-01-18 | 2023-01-25 |
-- | 2       | 2022-12-09 | 2022-12-23 |
-- | 2       | 2022-12-13 | 2022-12-17 |
-- | 3       | 2022-12-01 | 2023-01-30 |
-- +---------+------------+------------+
-- Output: 
-- +---------+------------+------------+
-- | hall_id | start_day  | end_day    |
-- +---------+------------+------------+
-- | 1       | 2023-01-13 | 2023-01-17 |
-- | 1       | 2023-01-18 | 2023-01-25 |
-- | 2       | 2022-12-09 | 2022-12-23 |
-- | 3       | 2022-12-01 | 2023-01-30 |
-- +---------+------------+------------+
-- Explanation: There are three halls.
-- Hall 1:
-- - The two events ["2023-01-13", "2023-01-14"] and ["2023-01-14", "2023-01-17"] overlap. We merge them in one event ["2023-01-13", "2023-01-17"].
-- - The event ["2023-01-18", "2023-01-25"] does not overlap with any other event, so we leave it as it is.
-- Hall 2:
-- - The two events ["2022-12-09", "2022-12-23"] and ["2022-12-13", "2022-12-17"] overlap. We merge them in one event ["2022-12-09", "2022-12-23"].
-- Hall 3:
-- - The hall has only one event, so we return it. Note that we only consider the events of each hall separately.

WITH dedup_event AS (
    SELECT hall_id, start_day, end_day
    FROM HallEvents
    GROUP BY hall_id, start_day, end_day
),
event_max_end_day AS (
    SELECT hall_id, start_day, end_day, 
        MAX(end_day) OVER(PARTITION BY hall_id ORDER BY start_day ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING) AS max_end_day
    FROM dedup_event
),
flag_max_end_day AS (
    SELECT hall_id, start_day, end_day, max_end_day,
        CASE 
            WHEN start_day <= max_end_day THEN 0
            ELSE 1
        END AS flag_group
    FROM event_max_end_day
),
cum_sum_flag AS (
    SELECT hall_id, start_day, end_day, max_end_day,
        SUM(flag_group) OVER(PARTITION BY hall_id ORDER BY start_day) AS group_no
    FROM flag_max_end_day
)
SELECT hall_id, MIN(start_day) AS start_day, MAX(end_day) AS end_day
FROM cum_sum_flag
GROUP BY hall_id, group_no;


-- The pattern you used here is the same one you used in 1285. You just didn't recognize it because the surface looks different. 

-- Let me show you:
-- **Both problems are the same skeleton:**
-- 1. Order rows within a group
-- 2. Determine if the current row continues the previous group or starts a new one
-- 3. Assign group numbers
-- 4. Aggregate per group

-- **The only thing that changes is step 2 — the "does this row belong to the previous group?" condition:**
-- In 1285 (continuous ranges): `value - ROW_NUMBER()` — same difference means same group.
-- In 2494 (overlapping intervals): `start_day <= MAX(end_day) of all previous rows` — overlap means same group.

-- **So the mental model is just one question:** "What condition connects this row to the previous group?" 
    -- Once you answer that, the rest is mechanical — flag it, cumulative SUM, GROUP BY.
-- **When you see a new problem, ask yourself these questions in order:**

-- 1. Do I need to group consecutive/overlapping rows? → If yes, this is a gap-and-island problem.
-- 2. What defines "connected"? Same value? Consecutive number? Overlapping range? Within N days?
-- 3. Write that condition.
-- 4. Flag → cumulative SUM → GROUP BY. Every time.

-- The reason you needed help today wasn't that you didn't know the pieces — you knew window functions, CASE, SUM, GROUP BY. You just didn't have the **recipe** connecting them. Now you do: **flag new groups → cumulative SUM → aggregate.** That three-step sequence is the entire pattern.