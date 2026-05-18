-- 1651. Hopper Company Queries III
-- https://leetcode.ca/all/1651.html

-- Table: Drivers

-- +-------------+---------+
-- | Column Name | Type    |
-- +-------------+---------+
-- | driver_id   | int     |
-- | join_date   | date    |
-- +-------------+---------+
-- driver_id is the primary key for this table.
-- Each row of this table contains the driver's ID and the date they joined the Hopper company.
 

-- Table: Rides

-- +--------------+---------+
-- | Column Name  | Type    |
-- +--------------+---------+
-- | ride_id      | int     |
-- | user_id      | int     |
-- | requested_at | date    |
-- +--------------+---------+
-- ride_id is the primary key for this table.
-- Each row of this table contains the ID of a ride, the user's ID that requested it, and the day they requested it.
-- There may be some ride requests in this table that were not accepted.
 

-- Table: AcceptedRides

-- +---------------+---------+
-- | Column Name   | Type    |
-- +---------------+---------+
-- | ride_id       | int     |
-- | driver_id     | int     |
-- | ride_distance | int     |
-- | ride_duration | int     |
-- +---------------+---------+
-- ride_id is the primary key for this table.
-- Each row of this table contains some information about an accepted ride.
-- It is guaranteed that each accepted ride exists in the Rides table.
 

-- Write an SQL query to compute the average_ride_distance and average_ride_duration of every 3-month window starting from January - March 2020 to October - December 2020. Round average_ride_distance and average_ride_duration to the nearest two decimal places.

-- The average_ride_distance is calculated by summing up the total ride_distance values from the three months and dividing it by 3. The average_ride_duration is calculated in a similar way.Programming

-- Return the result table ordered by month in ascending order, where month is the starting month's number (January is 1, February is 2, etc.).

-- The query result format is in the following example.

 

-- Drivers table:
-- +-----------+------------+
-- | driver_id | join_date  |
-- +-----------+------------+
-- | 10        | 2019-12-10 |
-- | 8         | 2020-1-13  |
-- | 5         | 2020-2-16  |
-- | 7         | 2020-3-8   |
-- | 4         | 2020-5-17  |
-- | 1         | 2020-10-24 |
-- | 6         | 2021-1-5   |
-- +-----------+------------+

-- Rides table:
-- +---------+---------+--------------+
-- | ride_id | user_id | requested_at |
-- +---------+---------+--------------+
-- | 6       | 75      | 2019-12-9    |
-- | 1       | 54      | 2020-2-9     |
-- | 10      | 63      | 2020-3-4     |
-- | 19      | 39      | 2020-4-6     |
-- | 3       | 41      | 2020-6-3     |
-- | 13      | 52      | 2020-6-22    |
-- | 7       | 69      | 2020-7-16    |
-- | 17      | 70      | 2020-8-25    |
-- | 20      | 81      | 2020-11-2    |
-- | 5       | 57      | 2020-11-9    |
-- | 2       | 42      | 2020-12-9    |
-- | 11      | 68      | 2021-1-11    |
-- | 15      | 32      | 2021-1-17    |
-- | 12      | 11      | 2021-1-19    |
-- | 14      | 18      | 2021-1-27    |
-- +---------+---------+--------------+

-- AcceptedRides table:
-- +---------+-----------+---------------+---------------+
-- | ride_id | driver_id | ride_distance | ride_duration |
-- +---------+-----------+---------------+---------------+
-- | 10      | 10        | 63            | 38            |
-- | 13      | 10        | 73            | 96            |
-- | 7       | 8         | 100           | 28            |
-- | 17      | 7         | 119           | 68            |
-- | 20      | 1         | 121           | 92            |
-- | 5       | 7         | 42            | 101           |
-- | 2       | 4         | 6             | 38            |
-- | 11      | 8         | 37            | 43            |
-- | 15      | 8         | 108           | 82            |
-- | 12      | 8         | 38            | 34            |
-- | 14      | 1         | 90            | 74            |
-- +---------+-----------+---------------+---------------+

-- Result table:
-- +-------+-----------------------+-----------------------+
-- | month | average_ride_distance | average_ride_duration |
-- +-------+-----------------------+-----------------------+
-- | 1     | 21.00                 | 12.67                 |
-- | 2     | 21.00                 | 12.67                 |
-- | 3     | 21.00                 | 12.67                 |
-- | 4     | 24.33                 | 32.00                 |
-- | 5     | 57.67                 | 41.33                 |
-- | 6     | 97.33                 | 64.00                 |
-- | 7     | 73.00                 | 32.00                 |
-- | 8     | 39.67                 | 22.67                 |
-- | 9     | 54.33                 | 64.33                 |
-- | 10    | 56.33                 | 77.00                 |
-- +-------+-----------------------+-----------------------+

-- By the end of January --> average_ride_distance = (0+0+63)/3=21, average_ride_duration = (0+0+38)/3=12.67
-- By the end of February --> average_ride_distance = (0+63+0)/3=21, average_ride_duration = (0+38+0)/3=12.67
-- By the end of March --> average_ride_distance = (63+0+0)/3=21, average_ride_duration = (38+0+0)/3=12.67
-- By the end of April --> average_ride_distance = (0+0+73)/3=24.33, average_ride_duration = (0+0+96)/3=32.00
-- By the end of May --> average_ride_distance = (0+73+100)/3=57.67, average_ride_duration = (0+96+28)/3=41.33
-- By the end of June --> average_ride_distance = (73+100+119)/3=97.33, average_ride_duration = (96+28+68)/3=64.00
-- By the end of July --> average_ride_distance = (100+119+0)/3=73.00, average_ride_duration = (28+68+0)/3=32.00
-- By the end of August --> average_ride_distance = (119+0+0)/3=39.67, average_ride_duration = (68+0+0)/3=22.67
-- By the end of Septemeber --> average_ride_distance = (0+0+163)/3=54.33, average_ride_duration = (0+0+193)/3=64.33
-- By the end of October --> average_ride_distance = (0+163+6)/3=56.33, average_ride_duration = (0+193+38)/3=77.00



-- ------------ ---------------- -------------- --------------- ----------------- ------------ ------------ -------------- -------------- ------------ 
-- ------------ ---------------- -------------- --------------- ----------------- ------------ ------------ -------------- -------------- ------------ 
-- ------------ ---------------- -------------- --------------- ----------------- ------------ ------------ -------------- -------------- ------------ 
-- ------------ ---------------- -------------- --------------- ----------------- ------------ ------------ -------------- -------------- ------------ 

-- SELECT MONTH(r.requested_at), 
--     ROUND((SUM(CASE
--         WHEN MONTH(r.requested_at) OR MONTH(r.requested_at)+1 OR MONTH(r.requested_at)+2
--         THEN r.ride_distance
--         END)/3),2) AS average_ride_distance, 
--     ROUND((SUM(CASE
--         WHEN MONTH(r.requested_at) OR MONTH(r.requested_at)+1 OR MONTH(r.requested_at)+2
--         THEN r.ride_duration
--         END)/3),2) AS average_ride_duration
-- FROM Rides r JOIN AcceptedRides ar 
--     ON r.ride_id = ar.ride_id
-- WHERE YEAR(r.requested_at) = 2020 AND MONTH(r.requested_at) BETWEEN 1 AND 10
-- GROUP BY MONTH(r.requested_at);

--> forgot to taken into account month that have no rides it will simply skip that month we need to find a way that we look into each month 
--> also CASE LOGIGC ==> WHEN MONTH(r.requested_at) EVALUATES THIS AS A BOOLEAN IT DOESNT DO ANYTHING WE NEED TO HAVE COMPARISON
--> Rolling window can't be done within a single GROUP BY
--> Also ride_distance, ride_duration are in accepted rides and not rides table

-- ------------ ---------------- -------------- --------------- ----------------- ------------ ------------ -------------- -------------- ------------ 
-- ------------ ---------------- -------------- --------------- ----------------- ------------ ------------ -------------- -------------- ------------ 
-- ------------ ---------------- -------------- --------------- ----------------- ------------ ------------ -------------- -------------- ------------ 
-- ------------ ---------------- -------------- --------------- ----------------- ------------ ------------ -------------- -------------- ------------ 

WITH RECURSIVE req_months AS (
    SELECT 1 AS month
    UNION ALL 
    SELECT month+1 
    FROM req_months
    WHERE month<12
),
month_ride_acceptedride AS (
    SELECT rm.month, COALESCE(SUM(ar.ride_distance),0) AS month_distance, COALESCE(SUM(ar.ride_duration),0) AS month_duration
    FROM req_months rm LEFT JOIN Rides r 
            ON rm.month = MONTH(r.requested_at) AND YEAR(r.requested_at)=2020
        LEFT JOIN AcceptedRides ar
            ON r.ride_id = ar.ride_id
    GROUP BY rm.month
)
SELECT month, 
    ROUND((
            (month_distance + LEAD(month_distance,1) OVER(ORDER BY month) + LEAD(month_distance,2) OVER(ORDER BY month))/3
        ),2) AS average_ride_distance,
    ROUND((
            (month_duration + LEAD(month_duration,1) OVER(ORDER BY month) + LEAD(month_duration,2) OVER(ORDER BY month))/3
        ),2) AS average_ride_duration
FROM month_ride_acceptedride
WHERE month <= 10;

-- ALTERNATIVE SOLUTION USING SLIDING WINDOW
WITH RECURSIVE req_months AS (
    SELECT 1 AS month
    UNION ALL 
    SELECT month+1 
    FROM req_months
    WHERE month<12
),
month_ride_acceptedride AS (
    SELECT rm.month, COALESCE(SUM(ar.ride_distance),0) AS month_distance, COALESCE(SUM(ar.ride_duration),0) AS month_duration
    FROM req_months rm LEFT JOIN Rides r 
            ON rm.month = MONTH(r.requested_at) AND YEAR(r.requested_at)=2020
        LEFT JOIN AcceptedRides ar
            ON r.ride_id = ar.ride_id
    GROUP BY rm.month
)
SELECT month, 
    ROUND((
            (SUM(month_distance) OVER(ORDER BY month ROWS BETWEEN CURRENT ROW AND 2 FOLLOWING) )/3
        ),2) AS average_ride_distance,
    ROUND((
            (
                SUM(month_duration) OVER(ORDER BY month ROWS BETWEEN CURRENT ROW AND 2 FOLLOWING)
            )/3
        ),2) AS average_ride_duration
FROM month_ride_acceptedride
WHERE month <= 10;


-- Here are the key takeaways:

-- **1. Rolling/Sliding Window = Two-Step Thinking**
-- Whenever you see "average of every N-month/day/week window," think: first get per-period totals, then use window functions to combine neighboring rows. You can't do both in one GROUP BY.

-- **2. Generate Missing Periods First**
-- If the output needs every month/day even when there's no data, your first instinct should be: "I need a calendar/sequence." Recursive CTE to generate months 1-12 (or a date range), then LEFT JOIN your data onto it. This pattern appears constantly.

-- **3. LEFT JOIN + WHERE Trap**
-- Whenever you write a LEFT JOIN, ask yourself: "Does my WHERE clause reference the right table?" If yes, it kills the LEFT JOIN. Move that condition into the ON clause. This came up twice in your practice today — it's one of the most common SQL bugs.

-- **4. COALESCE After LEFT JOIN**
-- LEFT JOIN produces NULLs for non-matching rows. NULL poisons arithmetic (NULL + 5 = NULL). Always wrap aggregates in COALESCE when LEFT JOINs are involved.

-- **5. Window Frame for Rolling Averages**
-- `SUM(...) OVER (ORDER BY month ROWS BETWEEN CURRENT ROW AND 2 FOLLOWING)` is cleaner than multiple LEADs. Know both approaches, but prefer the window frame — it scales better if the window size changes.

-- **6. Generate More Than You Output**
-- You needed output for months 1-10 but generated months 1-12 because month 10's window needs months 11 and 12. Always think: "Does my window function need rows beyond my output range?" If yes, generate extra rows and filter at the end.

-- **Mental checklist for rolling window problems:**
-- 1. Do I need to generate a sequence? → Recursive CTE
-- 2. Get per-period totals → GROUP BY with LEFT JOIN + COALESCE
-- 3. Combine neighboring rows → Window frame or LEAD/LAG
-- 4. Filter to required output range → WHERE in final SELECT