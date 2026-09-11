-- You have a table called transactions:

-- transactions
-- ├── transaction_id   INT (PK)
-- ├── customer_id      INT
-- ├── amount           DECIMAL(10,2)
-- ├── transaction_date DATE

-- Some customers have multiple transactions on the same date. When that happens, use the highest transaction_id as the tiebreaker.

-- Write a query that returns one row per customer — their most recent transaction only. Return all four columns.
WITH transactions_ranked AS (
SELECT customer_id, transaction_id, amount, transaction_date,
    ROW_NUMBER() OVER(PARTITION BY customer_id ORDER BY transaction_date DESC, transaction_id DESC) AS transaction_rn
FROM transactions
)
SELECT customer_id, transaction_id, amount, transaction_date
FROM transactions_ranked
WHERE transaction_rn = 1;