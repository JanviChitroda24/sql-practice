-- 1555. Bank Account Summary
-- https://leetcode.ca/all/1555.html

-- SQL Schema 
-- Table: Users

-- +--------------+---------+
-- | Column Name  | Type    |
-- +--------------+---------+
-- | user_id      | int     |
-- | user_name    | varchar |
-- | credit       | int     |
-- +--------------+---------+
-- user_id is the primary key for this table.
-- Each row of this table contains the current credit information for each user.
 

-- Table: Transaction

-- +---------------+---------+
-- | Column Name   | Type    |
-- +---------------+---------+
-- | trans_id      | int     |
-- | paid_by       | int     |
-- | paid_to       | int     |
-- | amount        | int     |
-- | transacted_on | date    |
-- +---------------+---------+
-- trans_id is the primary key for this table.
-- Each row of this table contains the information about the transaction in the bank.
-- User with id (paid_by) transfer money to user with id (paid_to).
 

-- Leetcode Bank (LCB) helps its coders in making virtual payments. 
-- Our bank records all transactions in the table Transaction, 
--     we want to find out the 
--         current balance of all users and 
--         check wheter they have breached their credit limit 
--     (If their current credit is less than 0).

-- Write an SQL query to report.

-- user_id
-- user_name
-- credit, current balance after performing transactions.  
-- credit_limit_breached, check credit_limit ("Yes" or "No")
-- Return the result table in any order.

-- The query result format is in the following example.

 

-- Users table:
-- +------------+--------------+-------------+
-- | user_id    | user_name    | credit      |
-- +------------+--------------+-------------+
-- | 1          | Moustafa     | 100         |
-- | 2          | Jonathan     | 200         |
-- | 3          | Winston      | 10000       |
-- | 4          | Luis         | 800         |
-- +------------+--------------+-------------+

-- Transaction table:
-- +------------+------------+------------+----------+---------------+
-- | trans_id   | paid_by    | paid_to    | amount   | transacted_on |
-- +------------+------------+------------+----------+---------------+
-- | 1          | 1          | 3          | 400      | 2020-08-01    |
-- | 2          | 3          | 2          | 500      | 2020-08-02    |
-- | 3          | 2          | 1          | 200      | 2020-08-03    |
-- +------------+------------+------------+----------+---------------+

-- Result table:
-- +------------+------------+------------+-----------------------+
-- | user_id    | user_name  | credit     | credit_limit_breached |
-- +------------+------------+------------+-----------------------+
-- | 1          | Moustafa   | -100       | Yes                   |
-- | 2          | Jonathan   | 500        | No                    |
-- | 3          | Winston    | 9990       | No                    |
-- | 4          | Luis       | 800        | No                    |
-- +------------+------------+------------+-----------------------+
-- Moustafa paid $400 on "2020-08-01" and received $200 on "2020-08-03", credit (100 -400 +200) = -$100
-- Jonathan received $500 on "2020-08-02" and paid $200 on "2020-08-08", credit (200 +500 -200) = $500
-- Winston received $400 on "2020-08-01" and paid $500 on "2020-08-03", credit (10000 +400 -500) = $9900
-- Luis didn't received any transfer, credit = $800

-- SELECT u.user_id, u.user_name, 
--         SUM(u.credit, -1*COALESCE(pby.amount,0), COALESCE(pto.amount,0)) AS credit,
--         CASE 
--             WHEN SUM(u.credit, -1*COALESCE(pby.amount,0), COALESCE(pto.amount,0)) < 0
--             THEN 'Yes'
--             ELSE 'No'
--         END AS credit_limit_breached
-- FROM Users u LEFT JOIN Transaction pby 
--         ON u.user_id = pby.paid_by
--     JOIN Transaction pto 
--         ON u.user_id = pto.paid_to
-- GROUP BY u.user_id, u.user_name;

WITH u_paid_by AS (
    SELECT paid_by, SUM(amount) AS paid_by_amt
    FROM Transaction
    GROUP BY paid_by
),
u_paid_to AS (
    SELECT paid_to, SUM(amount) AS paid_to_amt
    FROM Transaction
    GROUP BY paid_to
)
SELECT u.user_id, u.user_name, 
    credit-COALESCE(paid_by_amt,0)+COALESCE(paid_to_amt,0) AS credit,
    CASE 
        WHEN credit-COALESCE(paid_by_amt,0)+COALESCE(paid_to_amt,0) < 0
        THEN 'Yes'
        ELSE 'No'
    END AS credit_limit_breached
FROM Users u LEFT JOIN u_paid_by pby
        ON u.user_id = pby.paid_by
    LEFT JOIN u_paid_to pto 
        ON  u.user_id = pto.paid_to;


-- **Key learnings from this problem:**

-- **1. Double LEFT JOIN causes row multiplication**
--     When you LEFT JOIN the same base table to two different tables, 
--         matching rows multiply (2 paid × 3 received = 6 rows). 
--         Aggregates like SUM become inflated and give wrong results.

-- **2. Fix: Pre-aggregate in separate CTEs**
--     Compute each aggregate independently first (total paid, total received), 
--         so each CTE produces one row per user. 
--     Then LEFT JOIN both to the base table — no multiplication since 
--         each join matches at most one row.

-- **3. SUM takes one argument, not multiple**
--     `SUM(a, b, c)` is invalid SQL. 
--     For adding columns in the same row, use plain arithmetic: `a + b + c`. 
--     SUM is for adding values across rows.

-- **4. COALESCE when LEFT JOINing aggregates**
--     Pre-aggregated CTEs joined via LEFT JOIN produce NULLs for users with no transactions. 
--     Wrap in COALESCE to avoid NULL poisoning your arithmetic.
