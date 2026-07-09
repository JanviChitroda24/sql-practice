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
        LAG(free,1) OVER(ORDER BY seat_id) AS prev_1,
        LAG(free,2) OVER(ORDER BY seat_id) AS prev_2,
        LEAD(free,1) OVER(ORDER BY seat_id) AS next_1,
        LEAD(free,2) OVER(ORDER BY seat_id) AS next_2
    FROM cinema
)
SELECT seat_id
FROM consecutive_seat
WHERE (free+prev_1+prev_2 = 3) 
    OR (free+next_1+next_2 = 3) 
    OR (free+prev_1+next_1 = 3) ;


-- CORRECT SOLUTION - 2 CONSECUTIVE IS FINE
WITH consecutive_seat AS (
    SELECT seat_id, free, 
        LAG(free,1) OVER(ORDER BY seat_id) AS prev_1,
        LEAD(free,1) OVER(ORDER BY seat_id) AS next_1
    FROM cinema
)
SELECT seat_id
FROM consecutive_seat
WHERE (free+prev_1 = 2) 
    OR (free+next_1 =2)
ORDER BY seat_id;


-- Self join version
SELECT DISTINCT c1.seat_id
FROM cinema c1 JOIN cinema c2
    ON (c1.seat_id=c2.seat_id-1 AND c1.free = 1 AND c2.free=1)  
        OR (c1.seat_id=c2.seat_id+1 AND c1.free = 1 AND c2.free=1)
ORDER BY c1.seat_id;

--cleaner self join
SELECT DISTINCT c1.seat_id
FROM cinema c1 JOIN cinema c2
    ON c1.free = 1 AND c2.free=1
        AND (c1.seat_id=c2.seat_id+1 OR c1.seat_id=c2.seat_id-1)
ORDER BY c1.seat_id;

-- MOST CLEANEST SELF JOIN 
SELECT DISTINCT c1.seat_id
FROM cinema c1 JOIN cinema c2
    ON c1.free = 1 AND c2.free=1
        AND ABS(c1.seat_id - c2.seat_id) = 1
ORDER BY c1.seat_id;



-- Self-join version (any of your three):

-- A join needs to pair every c1 row with a matching c2 row. The efficiency of that pairing depends entirely on whether the join condition is sargable — meaning MySQL can use an index to jump directly to matching rows, instead of scanning.
-- ABS(c1.seat_id - c2.seat_id) = 1 wraps both columns in a function. MySQL generally cannot use an index through a function like that — it has to evaluate ABS(...) for every candidate pair. Same problem, slightly less obviously, with the OR (c1.seat_id = c2.seat_id+1 OR ...) version — an OR across two different equality conditions in a join clause often prevents a clean single index lookup too, depending on the optimizer's mood that day.
-- Worst case, this becomes a nested-loop comparison of every row against every other row — O(n²).


-- ### Direct comparison
-- | | Window function | Self-join |
-- |---|---|---|
-- | Passes over the table | 1 | up to n per row (n² worst case) |
-- | Uses primary key index efficiently | Yes (ordered scan) | Not with ABS/OR — not sargable |
-- | Scales to large tables | Good | Poor |
-- | Readability | Slightly more setup (CTE) | Very short, intuitive |
-- | Generalizes to "gap of size N" | Trivial — change offset | Awkward — need to adjust join math |

