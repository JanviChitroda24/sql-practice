-- 1907. Count Salary Categories
-- https://leetcode.com/problems/count-salary-categories/description/

-- Table: Accounts

-- +-------------+------+
-- | Column Name | Type |
-- +-------------+------+
-- | account_id  | int  |
-- | income      | int  |
-- +-------------+------+
-- account_id is the primary key (column with unique values) for this table.
-- Each row contains information about the monthly income for one bank account.
 

-- Write a solution to calculate the number of bank accounts for each salary category. The salary categories are:

-- "Low Salary": All the salaries strictly less than $20000.
-- "Average Salary": All the salaries in the inclusive range [$20000, $50000].
-- "High Salary": All the salaries strictly greater than $50000.
-- The result table must contain all three categories. If there are no accounts in a category, return 0.

-- Return the result table in any order.

-- The result format is in the following example.

 

-- Example 1:

-- Input: 
-- Accounts table:
-- +------------+--------+
-- | account_id | income |
-- +------------+--------+
-- | 3          | 108939 |
-- | 2          | 12747  |
-- | 8          | 87709  |
-- | 6          | 91796  |
-- +------------+--------+
-- Output: 
-- +----------------+----------------+
-- | category       | accounts_count |
-- +----------------+----------------+
-- | Low Salary     | 1              |
-- | Average Salary | 0              |
-- | High Salary    | 3              |
-- +----------------+----------------+
-- Explanation: 
-- Low Salary: Account 2.
-- Average Salary: No accounts.
-- High Salary: Accounts 3, 6, and 8.

(SELECT 'Low Salary' AS category,
    COUNT(
        CASE 
            WHEN income<20000 THEN 1
        END
    ) AS accounts_count
FROM Accounts)
UNION ALL
(SELECT 'Average Salary' AS category,
    COUNT(
        CASE 
            WHEN income>=20000 AND income<=50000 THEN 1
        END
    ) AS accounts_count
FROM Accounts)
UNION ALL
(SELECT 'High Salary' AS category,
    COUNT(
        CASE 
            WHEN income>50000 THEN 1
        END
    ) AS accounts_count
FROM Accounts);


-- **1. COUNT counts non-NULL values, not non-zero values.**
--     `COUNT(0)` = 1, `COUNT(1)` = 1, `COUNT(NULL)` = 0. 
--     It only skips NULLs. 
--     So when pairing COUNT with CASE, never use `ELSE 0` — use `ELSE NULL` 
--         or just omit the ELSE.

-- **2. CASE without ELSE defaults to NULL.**
--     This is why `COUNT(CASE WHEN condition THEN 1 END)` works 
--     — non-matching rows return NULL, and COUNT skips them.

-- **3. COUNT never returns NULL.**
--     It always returns a number — 0 when no rows match. 
--     So COALESCE around COUNT is always redundant.

-- **4. SUM vs COUNT with CASE — know when to use which.**
--     `SUM(CASE WHEN ... THEN 1 ELSE 0 END)` — uses 0 in ELSE, sums the values.
--     `COUNT(CASE WHEN ... THEN 1 END)` — omits ELSE (defaults NULL), counts non-NULLs.
--     Both give the same result. Pick one style and be consistent.

-- **5. SUM can return NULL.**
--     Unlike COUNT, `SUM()` over zero matching rows returns NULL, not 0. 
--     So `COALESCE(SUM(...), 0)` is sometimes needed, 
--     but `COALESCE(COUNT(...), 0)` never is.