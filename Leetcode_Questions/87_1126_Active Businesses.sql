-- 1126. Active Businesses
-- https://leetcode.ca/all/1126.html

-- Table: Events

-- +---------------+---------+
-- | Column Name   | Type    |
-- +---------------+---------+
-- | business_id   | int     |
-- | event_type    | varchar |
-- | occurences    | int     |
-- +---------------+---------+
-- (business_id, event_type) is the primary key of this table.
-- Each row in the table logs the info that an event of some type occured at some business for a number of times.
 


-- Write an SQL query to find all active businesses.

-- An active business is a business that has more than one event type with occurences greater than the average occurences of that event type among all businesses.

-- The query result format is in the following example:

-- Events table:
-- +-------------+------------+------------+
-- | business_id | event_type | occurences |
-- +-------------+------------+------------+
-- | 1           | reviews    | 7          |
-- | 3           | reviews    | 3          |
-- | 1           | ads        | 11         |
-- | 2           | ads        | 7          |
-- | 3           | ads        | 6          |
-- | 1           | page views | 3          |
-- | 2           | page views | 12         |
-- +-------------+------------+------------+

-- Result table:
-- +-------------+
-- | business_id |
-- +-------------+
-- | 1           |
-- +-------------+
-- Average for 'reviews', 'ads' and 'page views' are (7+3)/2=5, (11+7+6)/3=8, (3+12)/2=7.5 respectively.
-- Business with id 1 has 7 'reviews' events (more than 5) and 11 'ads' events (more than 8) so it is an active business.

WITH events_occurances AS (
    SELECT business_id, event_type, occurences,
        AVG(occurences) OVER(PARTITION BY event_type) AS avg_occurances
    FROM Events
),
active_business AS (
    SELECT business_id, event_type, occurences, avg_occurances, 
        CASE 
            WHEN occurences > avg_occurances
            THEN 1
        END AS active_events
    FROM events_occurances
)
SELECT business_id
FROM active_business
GROUP BY business_id
HAVING SUM(active_events) > 1;

-- simplications with just one cte (occrances check in the final select)

WITH events_occurances AS (
    SELECT business_id, event_type, occurences,
        AVG(occurences) OVER(PARTITION BY event_type) AS avg_occurances
    FROM Events
)
SELECT business_id
FROM events_occurances
WHERE occurences > avg_occurances 
GROUP BY business_id
HAVING COUNT(*) > 1;
