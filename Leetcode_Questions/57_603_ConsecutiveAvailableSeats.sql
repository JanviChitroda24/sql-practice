-- 603. Consecutive Available Seats
-- https://leetcode.ca/all/603.html

-- 603. Consecutive Available Seats
-- Several friends at a cinema ticket office would like to reserve consecutive available seats.
-- Can you help to query all the consecutive available seats order by the seat_id using the following cinema table?
-- | seat_id | free |
-- |---------|------|
-- | 1       | 1    |
-- | 2       | 0    |
-- | 3       | 1    |
-- | 4       | 1    |
-- | 5       | 1    |
 

-- Your query should return the following result for the sample case above.

-- | seat_id |
-- |---------|
-- | 3       |
-- | 4       |
-- | 5       |
-- Note:
-- The seat_id is an auto increment int, and free is bool ('1' means free, and '0' means occupied.).
-- Consecutive available seats are more than 2(inclusive) seats consecutively available.
-- Difficulty:
-- Easy

WITH consecutive_seat AS (
    SELECT seat_id, free, 
        LAG(free, 1, 0) OVER(order by seat_id) AS prev_seat, 
        LEAD(free, 1, 0) OVER(order by seat_id) AS next_seat
    FROM cinema
)
SELECT seat_id
FROM consecutive_seat
WHERE free = 1 AND (prev_seat=1 OR next_seat=1);

-- self join approach
SELECT DISTINCT a.seat_id
FROM cinema a JOIN cinema b 
    ON ABS(a.seat_id - b.seat_id) = 1
WHERE a.free = 1 AND b.free = 1
ORDER BY a.seat_id;

-- The **window function approach is more optimized**. Here's why:

-- **Window Function:** Scans the table once, computes `LAG`/`LEAD` in that single pass, then filters. 
    -- No duplicates produced, so no `DISTINCT` needed. Time complexity is essentially **O(n)**.

-- **Self-Join:** Joins every row against every potential neighbor, producing a larger intermediate result set. 
    -- The `ABS()` in the join condition can prevent index usage, and `DISTINCT` adds a deduplication step on top. Time complexity is closer to **O(n²)** in the worst case.

-- | Factor | Window Function | Self-Join |
-- |---|---|---|
-- | Table scans | 1 | 2 |
-- | Intermediate rows | Same as original | Up to 2× original |
-- | Needs DISTINCT | No | Yes |
-- | Index-friendly | Yes | ABS() hurts indexing |

-- **Bottom line:** Window functions are the better choice here. The self-join is still worth knowing for interviews (especially if they ask for an alternative approach), but in practice the window solution is cleaner and faster.

-- DISTINCT hurts because after the join produces results, the database must do extra work to remove duplicates. 
-- It typically does this in one of two ways:
    -- Sorting: Sort all result rows then scan for duplicates — that's O(n log n).
    -- Hashing: Build a hash table of seen values to detect duplicates — that's O(n) in time but costs extra memory.