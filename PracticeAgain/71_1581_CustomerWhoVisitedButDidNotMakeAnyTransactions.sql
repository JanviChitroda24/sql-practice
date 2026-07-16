-- 1581. Customer Who Visited but Did Not Make Any Transactions
-- https://leetcode.com/problems/customer-who-visited-but-did-not-make-any-transactions/description/

-- Table: Visits

-- +-------------+---------+
-- | Column Name | Type    |
-- +-------------+---------+
-- | visit_id    | int     |
-- | customer_id | int     |
-- +-------------+---------+
-- visit_id is the column with unique values for this table.
-- This table contains information about the customers who visited the mall.
 

-- Table: Transactions

-- +----------------+---------+
-- | Column Name    | Type    |
-- +----------------+---------+
-- | transaction_id | int     |
-- | visit_id       | int     |
-- | amount         | int     |
-- +----------------+---------+
-- transaction_id is column with unique values for this table.
-- This table contains information about the transactions made during the visit_id.
 

-- Write a solution to find the IDs of the users who visited without making any transactions 
-- and the number of times they made these types of visits.
-- Return the result table sorted in any order.

-- The result format is in the following example.

 

-- Example 1:

-- Input: 
-- Visits
-- +----------+-------------+
-- | visit_id | customer_id |
-- +----------+-------------+
-- | 1        | 23          |
-- | 2        | 9           |
-- | 4        | 30          |
-- | 5        | 54          |
-- | 6        | 96          |
-- | 7        | 54          |
-- | 8        | 54          |
-- +----------+-------------+
-- Transactions
-- +----------------+----------+--------+
-- | transaction_id | visit_id | amount |
-- +----------------+----------+--------+
-- | 2              | 5        | 310    |
-- | 3              | 5        | 300    |
-- | 9              | 5        | 200    |
-- | 12             | 1        | 910    |
-- | 13             | 2        | 970    |
-- +----------------+----------+--------+
-- Output: 
-- +-------------+----------------+
-- | customer_id | count_no_trans |
-- +-------------+----------------+
-- | 54          | 2              |
-- | 30          | 1              |
-- | 96          | 1              |
-- +-------------+----------------+
-- Explanation: 
-- Customer with id = 23 visited the mall once and made one transaction during the visit with id = 12.
-- Customer with id = 9 visited the mall once and made one transaction during the visit with id = 13.
-- Customer with id = 30 visited the mall once and did not make any transactions.
-- Customer with id = 54 visited the mall three times. During 2 visits they did not make any transactions, and during one visit they made 3 transactions.
-- Customer with id = 96 visited the mall once and did not make any transactions.
-- As we can see, users with IDs 30 and 96 visited the mall one time without making any transactions. Also, user 54 visited the mall twice and did not make any transactions.

SELECT v.customer_id, COUNT(*) AS count_no_trans
FROM Visits v LEFT JOIN Transactions t 
    ON v.visit_id = t.visit_id
WHERE t.transaction_id IS NULL
GROUP BY v.customer_id

-- alternate not exsits version
SELECT v.customer_id, COUNT(v.visit_id) AS count_no_trans
FROM Visits v
WHERE NOT EXISTS (
    SELECT 1
    FROM Transactions t 
    WHERE t.visit_id = v.visit_id
)
GROUP BY v.customer_id;


-- ## LEFT JOIN/IS NULL vs NOT EXISTS — anti-join comparison

-- LEFT JOIN + WHERE t.col IS NULL
--   → builds the full join first, then filters out the matched rows
--   → COUNT(*) is safe here specifically because rows have already
--     been filtered to "no match" before counting

-- NOT EXISTS (correlated subquery)
--   → per Visits row, asks "does a match exist?" — can stop at first match
--   → never touches Transactions structurally as a join;
--     it's a row-by-row existence check
--   → generally considered the more scalable default for anti-joins,
--     since it doesn't need to materialize a join result at all

-- Bottom line: both are correct and roughly comparable in cost for a table this size. 
-- NOT EXISTS is the version I'd lead with in an interview by default 
--     — same reasoning as your Employees-manager-left problem earlier: 
--         it's NULL-safe by construction, 
--         doesn't require reasoning about join fan-out, 
--         and short-circuits per row rather than building a full join result first. 
--     LEFT JOIN/IS NULL is equally valid and often what people reach 
--         for first/write faster under pressure 
--         — knowing both, and being able to state that trade-off out loud, 
--         is the strongest answer.

-- NOT EXISTS generally wins.
-- Why: 
--     LEFT JOIN has to build the full joined result set 
--         (every Visits row matched against every possible Transactions row) 
--         before it can filter down to the NULLs. 
--     NOT EXISTS skips that entirely 
--         — for each Visits row, it just checks "does any match exist?" 
--             and can stop the instant it finds one, without ever materializing a join. 
--             Less work per row, no full join to construct.
-- At the table sizes in this problem, the difference is negligible 
--     — but NOT EXISTS is the one that scales better 
--     and is generally the safer default to reach for.