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

-- ORIGINAL SOLUTION (Works but not optimal)
-- Issues:
-- 1. Using LEAD with ORDER BY id DESC is confusing - it works but counterintuitive
--    LEAD with DESC means looking at "previous" rows in ascending order
-- 2. Typo in CTE name: "consective_nos" should be "consecutive_nos"
-- 3. Missing space after OVER (style issue)
-- 4. Logic works but readability is poor - harder to understand and maintain
-- Performance: O(n) - single table scan, but the DESC ordering adds slight overhead
WITH consective_nos AS (
    SELECT id, num, 
    LEAD(num, 1) OVER(ORDER BY id DESC) AS next_num, 
    LEAD(num, 2) OVER(ORDER BY id DESC) AS next_2_num
    FROM Logs
)
SELECT DISTINCT num AS ConsecutiveNums
FROM consective_nos
WHERE num = next_num AND num = next_2_num;

-- ============================================================================
-- OPTIMIZED SOLUTION 1: Using LAG with ASC (Most Intuitive)
-- Why better:
-- 1. More intuitive - LAG looks back at previous rows naturally
-- 2. ORDER BY id ASC is the natural order
-- 3. Clearer logic: "current num equals previous num and num before that"
-- 4. Better readability and maintainability
-- Performance: O(n) - same complexity but clearer execution plan
-- ============================================================================
WITH consecutive_nos AS (
    SELECT id, num,
           LAG(num, 1) OVER (ORDER BY id) AS prev_num,
           LAG(num, 2) OVER (ORDER BY id) AS prev_2_num
    FROM Logs
)
SELECT DISTINCT num AS ConsecutiveNums
FROM consecutive_nos
WHERE num = prev_num AND num = prev_2_num;

-- ============================================================================
-- OPTIMIZED SOLUTION 2: Using LEAD with ASC (Alternative approach)
-- Why better:
-- 1. More intuitive than LEAD with DESC
-- 2. Looks forward naturally: "current num equals next num and num after that"
-- 3. ORDER BY id ASC is natural order
-- Performance: O(n) - same complexity, slightly different logic
-- ============================================================================
WITH consecutive_nos AS (
    SELECT id, num,
           LEAD(num, 1) OVER (ORDER BY id) AS next_num,
           LEAD(num, 2) OVER (ORDER BY id) AS next_2_num
    FROM Logs
)
SELECT DISTINCT num AS ConsecutiveNums
FROM consecutive_nos
WHERE num = next_num AND num = next_2_num;


-- ============================================================================
-- SELF-JOIN SOLUTION (Works but NOT optimal for large datasets)
-- Analysis:
-- Pros:
--   1. Logic is clear and intuitive - easy to understand
--   2. Works correctly - finds consecutive rows with same num
--   3. GROUP BY ensures distinct results
-- 
-- Cons (Performance Issues):
--   1. Multiple table scans - 3 self-joins means potentially 3 table scans
--   2. Join operations are expensive - O(n²) or O(n³) complexity in worst case
--   3. Window functions are O(n) - single table scan, much faster
--   4. Performance degrades significantly as table size grows
--   5. Missing DISTINCT keyword (GROUP BY works but DISTINCT is clearer)
-- 
-- Performance Comparison:
--   - Window functions: O(n) - single pass through table
--   - Self-joins: O(n²) or worse - multiple scans and join operations
-- 
-- Recommendation: Use window function solution (Solution 1 or 2 above) for better performance
-- ============================================================================
SELECT l1.num AS ConsecutiveNums
FROM Logs l1
JOIN Logs l2 ON l2.id = l1.id + 1 AND l2.num = l1.num
JOIN Logs l3 ON l3.id = l1.id + 2 AND l3.num = l1.num
GROUP BY l1.num;

-- ============================================================================
-- OPTIMIZED SELF-JOIN VERSION (If you must use self-joins)
-- Improvements:
--   1. Added DISTINCT for clarity (though GROUP BY already handles it)
--   2. More explicit join conditions
--   3. Still O(n²) complexity but slightly cleaner
-- Note: Still slower than window functions for large datasets
-- ============================================================================
-- SELECT DISTINCT l1.num AS ConsecutiveNums
-- FROM Logs l1
-- INNER JOIN Logs l2 ON l2.id = l1.id + 1 AND l2.num = l1.num
-- INNER JOIN Logs l3 ON l3.id = l1.id + 2 AND l3.num = l1.num;
