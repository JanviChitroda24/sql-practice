-- Table: Customers

-- +---------------+---------+
-- | Column Name   | Type    |
-- +---------------+---------+
-- | customer_id   | int     |
-- | customer_name | varchar |
-- +---------------+---------+
-- customer_id is the primary key for this table.
-- Each row of this table contains the name and the id customer.
 

-- Write an SQL query to find the missing customer IDs. The missing IDs are ones that are not in the Customers table but are in the range between 1 and the maximum customer_id present in the table.Programming

-- Notice that the maximum customer_id will not exceed 100.

-- Return the result table ordered by ids in ascending order.

-- The query result format is in the following example.

 

-- Customer table:
-- +-------------+---------------+
-- | customer_id | customer_name |
-- +-------------+---------------+
-- | 1           | Alice         |
-- | 4           | Bob           |
-- | 5           | Charlie       |
-- +-------------+---------------+

-- Result table:
-- +-----+
-- | ids |
-- +-----+
-- | 2   |
-- | 3   |
-- +-----+
-- The maximum customer_id present in the table is 5, so in the range [1,5], IDs 2 and 3 are missing from the table.

WITH RECURSIVE continuous_seq AS (
    SELECT 1 AS n
    
    UNION ALL 

    SELECT n+1
    FROM continuous_seq
    WHERE n < (SELECT MAX(customer_id) FROM Customer)
)
SELECT cs.n AS ids
FROM continuous_seq cs LEFT JOIN Customer c ON cs.n=c.customer_id
WHERE c.customer_id IS NULL;