-- https://leetcode.com/problems/human-traffic-of-stadium/description/

-- # Write your MySQL query statement below
WITH value_lag AS (
    SELECT id, visit_date, people, 
        LEAD(people, 1) OVER(ORDER BY id) AS next_people, 
        LEAD(people, 2) OVER(ORDER BY id) AS next_2_people,
        LAG(people, 1) OVER(ORDER BY id) AS prev_people,
        LAG(people, 2) OVER(ORDER BY id) AS prev_2_people, 
        LEAD(id, 1) OVER(ORDER BY id) AS next_id, 
        LEAD(id, 2) OVER(ORDER BY id) AS next_2_id,
        LAG(id, 1) OVER(ORDER BY id) AS prev_id,
        LAG(id, 2) OVER(ORDER BY id) AS prev_2_id
    FROM Stadium
)
SELECT id, visit_date, people
FROM value_lag
WHERE   ((people>=100 AND next_people>=100 AND next_2_people>=100) AND (id - next_id = -1 AND id - next_2_id = -2)) OR
        ((people>=100 AND prev_people>=100 AND prev_2_people>=100) AND (id - prev_id = 1 AND id - prev_2_id = 2)) OR 
        ((people>=100 AND next_people>=100 AND prev_people>=100) AND (id - prev_id = 1 AND id - next_id = -1))  
ORDER BY id;



-- ### 14. ORDER BY Inside a CTE is Meaningless
-- `ORDER BY` inside a CTE has no guaranteed effect on row order for the next CTE.
-- Sorting only matters in the **final SELECT** or inside `OVER()` clauses.
-- ```sql
-- WITH sorted AS (
--     SELECT * FROM Stadium ORDER BY id  -- ❌ Meaningless
-- )
-- ```

-- ---

-- ### 15. LEAD/LAG are Positional — Not ID-Aware
-- `LEAD/LAG` looks at **physically adjacent rows** in the result set.
-- It has no idea whether IDs are numerically consecutive or not.
-- ```sql
-- -- If id gaps exist: 1, 2, 4, 5
-- LEAD(people, 1) OVER(ORDER BY id)  -- returns row with id=4 as "next" of id=2 ❌
-- ```
-- **Fix:** Use ID arithmetic to explicitly verify consecutiveness.
-- ```sql
-- id - next_id = -1   -- truly consecutive forward
-- id - prev_id = 1    -- truly consecutive backward
-- ```

-- ---

-- ### 16. ORDER BY in OVER() Must Match What Defines the Sequence
-- Align your `ORDER BY` with the column that **defines the sequence** in the problem.
-- ```sql
-- -- Problem asks for consecutive IDs → ORDER BY id ✅
-- -- Problem asks for consecutive days → ORDER BY visit_date ✅
-- -- Don't just pick any sorted column
-- ```

-- ---

-- ### 17. Redundant ORDER BY Columns
-- If a column already uniquely orders rows, additional columns in `ORDER BY` add nothing.
-- ```sql
-- ORDER BY id, visit_date  -- ❌ redundant if id is unique
-- ORDER BY id              -- ✅
-- ```

-- ---

-- ### 18. Self Join vs LEAD/LAG for Consecutive ID Patterns
-- Self join on `id - 1` and `id - 2` can replace LEAD/LAG for consecutive ID detection.
-- But for **3 positions (start, middle, end)** it requires 3 UNION blocks → longer code.
-- ```sql
-- -- Self join: cleaner per position, but needs UNION for all 3 cases
-- JOIN Stadium b ON b.id = a.id - 1
-- JOIN Stadium c ON c.id = a.id - 2

-- -- LEAD/LAG: more compact, handles all positions in one CTE
-- ```
-- > *Neither is strictly better. Self join trades window overhead for multiple scans. Choose based on readability and whether gaps exist.*

-- ---

-- ### 19. DISTINCT in Self Join for Consecutive Patterns
-- When using self join to detect consecutive rows, a single row can qualify as
-- **start, middle, or end** of multiple valid triplets — causing duplicates.
-- Use `SELECT DISTINCT` to eliminate them in one shot.

-- ---

-- ### 20. Push Back on Interviewer Observations
-- If you're confident in your logic, defend it with a **concrete example**.
-- Accepting wrong corrections silently is a red flag. Pushing back with clear reasoning is a green flag.