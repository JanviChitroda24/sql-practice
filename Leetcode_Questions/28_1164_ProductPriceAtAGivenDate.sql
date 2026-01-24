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
--------------------------------------------------------------------------------

-- There would be 2 groups:
-- 1 --> where there is not price change for a product_id for a given date (it would have literal value 10 {initial value})
-- 2 --> there is price change, we will take the latest date price from the filtered row
-- We will use UNION to join both the groups

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Naive Approach:
-- Without join, there would be 2 CTE and one CTE wil lhave a window function

with prod_bef_date as (
    select *
    from Products
    where change_date<='2019-08-16'
), 
prod_group as (
    select product_id, new_price, change_date, max(change_date) over(partition by product_id) as max_date
    from prod_bef_date
)
select product_id, 10 as price
from Products
where product_id not in (select product_id from prod_bef_date)
union 
select product_id, new_price as price
from prod_group
where change_date=max_date


--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Optimized Approach:
WITH latest_date AS (
    SELECT product_id, max(change_date) AS max_date
    FROM Products
    WHERE change_date<='2019-08-16'
    GROUP BY product_id
)
SELECT p.product_id, p.new_price AS price
FROM Products p INNER JOIN latest_date l 
        ON (
                p.product_id = l.product_id AND 
                p.change_date = l.max_date
        )
UNION
SELECT product_id, 10 AS price
FROM Products
WHERE product_id NOT IN (SELECT product_id FROM latest_date)
