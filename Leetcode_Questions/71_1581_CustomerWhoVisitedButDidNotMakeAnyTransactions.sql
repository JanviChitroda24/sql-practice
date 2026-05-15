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
 

-- Write a solution to find the IDs of the users who visited without making any transactions and the number of times they made these types of visits.

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

-- using left join
SELECT v.customer_id, COUNT(v.visit_id) AS count_no_trans
FROM Visits v LEFT JOIN Transactions t
ON v.visit_id = t.visit_id
WHERE t.transaction_id IS NULL
GROUP BY v.customer_id;

-- using not exist
SELECT v.customer_id, COUNT(v.visit_id) AS count_no_trans
FROM Visits v
WHERE NOT EXISTS (
    SELECT 1 
    FROM Transactions t
    WHERE v.visit_id = t.visit_id
)
GROUP BY v.customer_id;


-- **First, the performance comparison:**

-- | Aspect | LEFT JOIN + IS NULL | NOT EXISTS |
-- |---|---|---|
-- | **How it works** | Joins every Visits row to Transactions, builds full result set, then filters where NULL | For each Visits row, peeks into Transactions — stops the moment it finds one match |
-- | **Memory** | Builds the entire joined table in memory before filtering | No intermediate result set needed |
-- | **Short-circuit** | No — must complete the full join first | Yes — stops scanning after first match found |
-- | **Index usage** | Uses index for join, but still materializes all matched rows | Uses index for lookup, returns TRUE/FALSE immediately |
-- | **Best case** | When most visits HAVE transactions (few NULLs to keep) | When most visits HAVE transactions (skips them fast) |
-- | **Worst case** | When Transactions is huge — lots of joined rows just to throw them away | Minimal difference from best case |

-- **Now your real question — "isn't NOT EXISTS basically a join? And isn't correlated = slow?"**

-- The correlated subquery reputation comes from this pattern:

-- ```sql
-- -- SLOW correlated subquery (runs full aggregation per row)
-- SELECT *
-- FROM Visits v
-- WHERE (SELECT COUNT(*) FROM Transactions t WHERE t.visit_id = v.visit_id) = 0;
-- ```

-- This is slow because for each visit, it scans Transactions, counts ALL matching rows, returns the count, then compares to 0. If a visit has 500 transactions, it reads all 500 just to tell you "not zero."

-- NOT EXISTS does something fundamentally different:

-- ```sql
-- -- FAST — existence check, not aggregation
-- WHERE NOT EXISTS (
--     SELECT 1 FROM Transactions t WHERE t.visit_id = v.visit_id
-- )
-- ```

-- Yes, it's technically correlated — it runs once per outer row. But the engine doesn't treat it like a regular subquery. It's an **existence check**, which means the engine asks "is there at least one?" and the moment it finds a single matching row, it stops and returns TRUE. It never counts, never reads further, never builds a result set.

-- Think of it this way — you're looking for empty mailboxes on a street:

-- - **LEFT JOIN + IS NULL**: Open every mailbox, take out ALL the mail, lay it on the ground, then walk back and check which piles are empty
-- - **Correlated COUNT**: Open each mailbox, count every single letter inside, write down the number, check if it's zero
-- - **NOT EXISTS**: Peek into each mailbox — see even one letter? Move on. Empty? Mark it.

-- The peek is what makes NOT EXISTS fast despite being correlated. With an index on `Transactions(visit_id)`, that peek is an O(log n) index lookup that either finds something or doesn't — no scanning, no counting, no materializing.

-- **Bottom line**: "correlated = slow" is an oversimplification. Correlated **aggregation** is slow. Correlated **existence checks** are optimized by the engine into efficient semi-anti-joins, often matching or beating explicit JOINs.


