-- 1164. Product Price at a Given Date
-- https://leetcode.com/problems/product-price-at-a-given-date/description/

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

-- Table: Products

-- +---------------+---------+
-- | Column Name   | Type    |
-- +---------------+---------+
-- | product_id    | int     |
-- | new_price     | int     |
-- | change_date   | date    |
-- +---------------+---------+
-- (product_id, change_date) is the primary key (combination of columns with unique values) of this table.
-- Each row of this table indicates that the price of some product was changed to a new price at some date.
-- Initially, all products have price 10.

-- Write a solution to find the prices of all products on the date 2019-08-16.

-- Return the result table in any order.

-- The result format is in the following example.

 

-- Example 1:

-- Input: 
-- Products table:
-- +------------+-----------+-------------+
-- | product_id | new_price | change_date |
-- +------------+-----------+-------------+
-- | 1          | 20        | 2019-08-14  |
-- | 2          | 50        | 2019-08-14  |
-- | 1          | 30        | 2019-08-15  |
-- | 1          | 35        | 2019-08-16  |
-- | 2          | 65        | 2019-08-17  |
-- | 3          | 20        | 2019-08-18  |
-- +------------+-----------+-------------+
-- Output: 
-- +------------+-------+
-- | product_id | price |
-- +------------+-------+
-- | 2          | 50    |
-- | 1          | 35    |
-- | 3          | 10    |
-- +------------+-------+

--------------------------------------------------------------------------------
WITH product_max_date AS (
    SELECT product_id, new_price, change_date,
        MAX(change_date) OVER(PARTITION BY product_id) AS max_change_date
    FROM Products
    WHERE change_date <= '2019-08-16'
)
SELECT product_id, new_price AS price
FROM product_max_date
WHERE change_date = max_change_date
UNION ALL
SELECT product_id, 10 AS price
FROM Products
GROUP BY product_id
HAVING MIN(change_date) > '2019-08-16';

-- Alternative approach left join 
    --> all distinct products + only products before the given date
    --> then use coalesce where nulls 

WITH distinct_product AS (
    SELECT DISTINCT product_id
    FROM Products
), 
product_rank AS (
    SELECT product_id, new_price AS price, 
        ROW_NUMBER() OVER(PARTITION BY product_id ORDER BY change_date DESC) AS prod_rank
    FROM Products
    WHERE change_date <= '2019-08-16'
)
SELECT dp.product_id, COALESCE(pr.price, 10) AS price
FROM distinct_product dp LEFT JOIN product_rank pr 
    ON dp.product_id = pr.product_id AND pr.prod_rank = 1;