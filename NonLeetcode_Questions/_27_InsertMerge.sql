-- You have a table called transactions:

-- transactions
-- ├── txn_id          INT (PK)
-- ├── account_id      INT
-- ├── txn_date        DATE
-- ├── txn_type        VARCHAR(10)  ('credit' or 'debit')
-- ├── amount          DECIMAL(12,2)

-- You need to merge new data into this table. 
-- Write a MERGE statement (or MySQL equivalent) that takes data from a staging table called staging_transactions with the same schema. 
-- If a txn_id already exists, update the amount and txn_date. If it doesn't exist, insert the new row.

INSERT INTO transactions (txn_id, account_id, txn_date, txn_type, amount)
SELECT  txn_id, account_id, txn_date, txn_type, amount
FROM staging_transactions
ON DUPLICATE KEY UPDATE
    txn_date = VALUES(txn_date),
    amount = VALUES(amount);

-- --
-- GENERAL SYNTAX:
-- INSERT INTO target_table (co1, col2, col3)
-- SELECT co1, col2, col3
-- FROM source_table
-- ON DUPLICATE KEY UPDATE
--     col1 = VALUES(col1),
--     col2 = VALUES(col2),
--     col3 = VALUES(col3);