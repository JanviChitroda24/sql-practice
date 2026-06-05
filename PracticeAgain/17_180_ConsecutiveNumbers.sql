"""
180 - Consecutive Numbers
https://leetcode.com/problems/consecutive-numbers/description/

Table: Logs

+-------------+---------+
| Column Name | Type    |
+-------------+---------+
| id          | int     |
| num         | varchar |
+-------------+---------+
In SQL, id is the primary key for this table.
id is an autoincrement column starting from 1.
 

Find all numbers that appear at least three times consecutively.

Return the result table in any order.

The result format is in the following example.

 

Example 1:

Input: 
Logs table:
+----+-----+
| id | num |
+----+-----+
| 1  | 1   |
| 2  | 1   |
| 3  | 1   |
| 4  | 2   |
| 5  | 1   |
| 6  | 2   |
| 7  | 2   |
+----+-----+
Output: 
+-----------------+
| ConsecutiveNums |
+-----------------+
| 1               |
+-----------------+
Explanation: 1 is the only number that appears consecutively for at least three times.
"""
WITH cons_nums AS (
    SELECT id, num, 
        LAG(num) OVER(ORDER BY id) AS prev_num,
       LAG(num,2) OVER(ORDER BY id) AS prev_2_num
    FROM Logs
)
SELECT DISTINCT num AS ConsecutiveNums
FROM cons_nums
WHERE num = prev_num AND num = prev_2_num;

-- another alternative approach (self join)
SELECT DISTINCT l1.num AS ConsecutiveNums
FROM Logs l1 JOIN Logs l2 ON l1.id = l2.id-1 AND l1.num = l2.num 
    JOIN Logs l3 ON l1.id = l3.id-2 AND l1.num = l3.num;


-- **Window Function (LAG) Approach**
-- The engine sorts the table once by `id`, then makes a single pass to compute both LAG values. 
    -- It scans the table once, so think O(n log n) for the sort plus O(n) for the pass. 
    -- Space-wise, it needs a temporary buffer for the window frame, but it's essentially O(n). 
    -- It works even if `id` has gaps (e.g., 1, 2, 5, 6, 7) because LAG operates on row order, not on id values. 
    -- This makes it more robust and portable.

-- **Self-Join Approach**

-- The engine joins the table to itself three times using equality on `id` arithmetic. 
    -- With indexes on `id` (which a primary key guarantees), each join is an index lookup 
    --     — so it's roughly O(n) per join, O(n) total in practice. 
    -- But without an index, each join could be O(n²) in the worst case. 
    -- Space-wise, the intermediate join results can blow up if there's lots of matching data 
    --     — potentially O(n²) materialized rows before the DISTINCT. 
    -- The critical weakness: it **breaks if ids have gaps**. 
    -- If your ids go 1, 2, 5, 6, 7, the `id - 1` and `id - 2` arithmetic misses valid consecutive rows.

-- **Which is better?**

-- For interviews, lead with the window function approach. 
-- It's safer (handles gaps), more readable, scans the table once, and shows the interviewer you know modern SQL. 
-- Pull out the self-join as your "alternative" if they ask for one — that shows breadth.

-- -- In production, same answer: window functions. You rarely want to rely on perfectly sequential IDs in real-world data.
-- -- **One-liner to remember:** LAG is safer and cleaner; self-join is a good trick to have in your back pocket.