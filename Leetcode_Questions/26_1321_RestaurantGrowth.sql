-- https://leetcode.com/problems/restaurant-growth/description/

-- # Write your MySQL query statement below
-- Atleast one customer every day
-- range between visited on -6
-- also if the previous 6 rows doesnt exsit than it shouldnt be present in the results 

-- WITH sorted_vists AS (
--     SELECT customer_id, visited_on, amount
--     FROM Customer
--     ORDER BY visited_on
-- )
-- WITH sorted_day_avg AS (
--     SELECT visited_on, SUM(amount) AS amount
--     FROM Customer
--     GROUP BY visited_on
-- ),
-- rolling_7_day AS(
-- SELECT visited_on, 
--         SUM(amount) OVER(ORDER BY visited_on ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) AS amount, 
--         ROUND( AVG(amount) OVER(ORDER BY visited_on ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) ,2) AS average_amount
-- FROM sorted_day_avg
-- )
-- SELECT * 
-- FROM rolling_7_day
-- WHERE DATE_SUB(visited_on,  INTERVAL 6 DAY) IN (
--     SELECT visited_on 
--     FROM sorted_day_avg
-- );

WITH sorted_day_avg AS (
    SELECT visited_on, SUM(amount) AS amount
    FROM Customer
    GROUP BY visited_on
),
rolling_7_day AS(
SELECT visited_on, 
        SUM(amount) OVER(ORDER BY visited_on ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) AS amount, 
        ROUND( AVG(amount) OVER(ORDER BY visited_on ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) ,2) AS average_amount, 
        ROW_NUMBER() OVER(ORDER BY visited_on) AS row_num
FROM sorted_day_avg
)
SELECT visited_on, amount, average_amount
FROM rolling_7_day
WHERE row_num>6;


-- ### 8. RANGE with Date Columns — Just Use ROWS
-- ```sql
-- RANGE BETWEEN 7 PRECEDING AND CURRENT ROW                        -- ❌ Plain number invalid for date columns
-- RANGE BETWEEN DATE_SUB(visited_on, INTERVAL 7 DAY) PRECEDING ... -- ❌ Function calls not allowed as boundaries
-- ROWS BETWEEN 6 PRECEDING AND CURRENT ROW                         -- ✅ Preferred — predictable, no type issues
-- RANGE BETWEEN INTERVAL 7 DAY PRECEDING AND CURRENT ROW           -- ✅ counts all rows within a **7-day date range** (MySQL 8+)
-- ```
-- `RANGE` groups rows with identical `ORDER BY` values → unpredictable with duplicate dates. **Default to `ROWS`.**

-- ---

-- ### 9. Pre-Aggregate Before Window When Multiple Rows Per Date Exist
-- `ROWS BETWEEN 6 PRECEDING` counts **rows**, not days. If 3 customers visit Jan 1, that's 3 rows — your 7-day window silently shrinks.
-- ```sql
-- -- ✅ GROUP BY date first, then apply window
-- WITH daily AS (
--     SELECT visited_on, SUM(amount) AS day_amount
--     FROM Customer
--     GROUP BY visited_on
-- )
-- SELECT SUM(day_amount) OVER (ORDER BY visited_on ROWS BETWEEN 6 PRECEDING AND CURRENT ROW)
-- FROM daily
-- ```

-- ---

-- ### 10. N-Row Window ≠ N-Day Window
-- ```sql
-- ROWS BETWEEN 6 PRECEDING AND CURRENT ROW               -- 7 rows (6 + current row)
-- RANGE BETWEEN INTERVAL 7 DAY PRECEDING AND CURRENT ROW -- 7 days of date range
-- ```
-- Not the same when gaps exist or multiple rows per date. Know which one the problem asks for.

-- ---

-- ### 11. Filter Full Windows with ROW_NUMBER(), Not DATE_SUB...IN
-- ```sql
-- WHERE DATE_SUB(visited_on, INTERVAL 6 DAY) IN (SELECT visited_on FROM daily) -- ⚠️ Breaks with date gaps

-- -- ✅ Gap-safe — use ROW_NUMBER
-- ROW_NUMBER() OVER (ORDER BY visited_on) AS rn  ...  WHERE rn >= 7
-- ```

-- ---

-- ### 12. Omit PARTITION BY for a Single Continuous Timeline
-- `PARTITION BY` resets the window per group. If you `PARTITION BY visited_on`, each date becomes an isolated partition of 1 row — the sliding window can never look back.
-- Use `PARTITION BY` only when the window needs to **repeat per group** (e.g. per user, per region).

-- ---

-- ### 13. CTE vs Inline Subquery — Conscious Tradeoff
-- Any single-use CTE can be inlined into `FROM`. Prefer two CTEs for readability.
-- ```sql
-- -- Inline (fewer CTEs, more nested)
-- FROM (SELECT visited_on, SUM(amount) AS day_amount FROM Customer GROUP BY visited_on) daily

-- -- Two CTEs (preferred)
-- WITH daily AS (...), windowed AS (...)
-- ```
-- > *"I could inline this, but two CTEs separates concerns — one for aggregation, one for windowing. Easier to read and debug."*

-- ---