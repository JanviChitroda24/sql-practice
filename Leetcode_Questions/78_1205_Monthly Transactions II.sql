-- 1205. Monthly Transactions II
-- https://leetcode.ca/all/1205.html

-- Table: Transactions
-- +----------------+---------+
-- | Column Name    | Type    |
-- +----------------+---------+
-- | id             | int     |
-- | country        | varchar |
-- | state          | enum    |
-- | amount         | int     |
-- | trans_date     | date    |
-- +----------------+---------+
-- id is the primary key of this table.
-- The table has information about incoming transactions.
-- The state column is an enum of type ["approved", "declined"].

-- Table: Chargebacks
-- +----------------+---------+
-- | Column Name    | Type    |
-- +----------------+---------+
-- | trans_id       | int     |
-- | charge_date    | date    |
-- +----------------+---------+
-- Chargebacks contains basic information regarding incoming chargebacks from some transactions placed in Transactions table.
-- trans_id is a foreign key to the id column of Transactions table.
-- Each chargeback corresponds to a transaction made previously even if they were not approved.
 


-- Write an SQL query to find for each month and country, the number of approved transactions and their total amount, the number of chargebacks and their total amount.Programming

-- Note: In your query, given the month and country, ignore rows with all zeros.

-- The query result format is in the following example:

-- Transactions table:
-- +------+---------+----------+--------+------------+
-- | id   | country | state    | amount | trans_date |
-- +------+---------+----------+--------+------------+
-- | 101  | US      | approved | 1000   | 2019-05-18 |
-- | 102  | US      | declined | 2000   | 2019-05-19 |
-- | 103  | US      | approved | 3000   | 2019-06-10 |
-- | 104  | US      | approved | 4000   | 2019-06-13 |
-- | 105  | US      | approved | 5000   | 2019-06-15 |
-- +------+---------+----------+--------+------------+

-- Chargebacks table:
-- +------------+------------+
-- | trans_id   | trans_date |
-- +------------+------------+
-- | 102        | 2019-05-29 |
-- | 101        | 2019-06-30 |
-- | 105        | 2019-09-18 |
-- +------------+------------+

-- Result table:
-- +----------+---------+----------------+-----------------+-------------------+--------------------+
-- | month    | country | approved_count | approved_amount | chargeback_count  | chargeback_amount  |
-- +----------+---------+----------------+-----------------+-------------------+--------------------+
-- | 2019-05  | US      | 1              | 1000            | 1                 | 2000               |
-- | 2019-06  | US      | 3              | 12000           | 1                 | 1000               |
-- | 2019-09  | US      | 0              | 0               | 1                 | 5000               |
-- +----------+---------+----------------+-----------------+-------------------+--------------------+

WITH t_andc AS (
    SELECT id, DATE_FORMAT(trans_date, '%Y-%m') AS month, country, state, amount, 'Transactions' AS tbl
    FROM Transactions

    UNION all
    
    SELECT c.trans_id, DATE_FORMAT(c.trans_date, '%Y-%m') AS month, t.country, t.state, t.amount, 'Chargebacks' AS tbl
    FROM Transactions t JOIN  Chargebacks c 
         ON t.id = c.trans_id
)
SELECT month, country, 
    COUNT(
        CASE
            WHEN state='approved' AND tbl='Transactions' THEN 1
            ELSE NULL
        END
    ) AS approved_count,
    SUM(
        CASE
            WHEN state='approved' AND tbl='Transactions' THEN amount
            ELSE 0
        END
    ) AS approved_amount,
    COUNT(
        CASE
            WHEN tbl='Chargebacks' THEN 1
            ELSE NULL
        END
    )
    AS chargeback_count,
    SUM(
        CASE
            WHEN tbl='Chargebacks' THEN amount
            ELSE 0
        END
    )
    AS chargeback_amount
FROM t_andc
GROUP BY month, country
HAVING approved_count > 0 OR chargeback_count > 0;

--- OPTIMIZED SOLUTION
WITH t_andc AS (
    SELECT id, DATE_FORMAT(trans_date, '%Y-%m') AS month, country, state, amount, 'Transactions' AS tbl
    FROM Transactions
    WHERE state='approved'

    UNION all
    
    SELECT c.trans_id, DATE_FORMAT(c.trans_date, '%Y-%m') AS month, t.country, t.state, t.amount, 'Chargebacks' AS tbl
    FROM Transactions t JOIN  Chargebacks c 
         ON t.id = c.trans_id
)
SELECT month, country, 
    COUNT(
        CASE
            WHEN tbl='Transactions' THEN 1
        END
    ) AS approved_count,
    SUM(
        CASE
            WHEN tbl='Transactions' THEN amount
        END
    ) AS approved_amount,
    COUNT(
        CASE
            WHEN tbl='Chargebacks' THEN 1
        END
    )
    AS chargeback_count,
    SUM(
        CASE
            WHEN tbl='Chargebacks' THEN amount
        END
    )
    AS chargeback_amount
FROM t_andc
GROUP BY month, country
HAVING approved_count > 0 OR chargeback_count > 0;


-- Great question. Here's a mental framework:

-- **Start from the output.** Look at the expected result table and ask: "Where does each column come from?" If different columns in the same row come from **different tables using different grouping keys** (like different date columns), that's your signal. A single `JOIN + GROUP BY` can't group by two different dates simultaneously.

-- **The pattern to recognize:** When you need to aggregate data from two (or more) independent sources that share the same output shape (same columns) but are computed differently, think `UNION ALL` first. You're essentially building each piece separately and stacking them.

-- **A simple test:** Ask yourself — "Can I get all the numbers I need with one `GROUP BY`?" If the answer is no because the rows are determined by different logic (different dates, different tables, different filters), you likely need `UNION ALL`.

-- **Common scenarios where this shows up:**
-- - Two different date columns determine the month (like this problem)
-- - Combining "income" and "expense" from different tables
-- - Combining "sent" and "received" messages to get total activity
-- - Any problem where the same entity appears in two roles

-- So next time, before writing any SQL, look at the output columns and trace each one back to its source. If they don't all flow naturally from one query path, that's your cue to split into streams and union them.