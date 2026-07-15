-- 1174. Immediate Food Delivery II
-- https://leetcode.com/problems/immediate-food-delivery-ii/description/

-- Table: Delivery

-- +-----------------------------+---------+
-- | Column Name                 | Type    |
-- +-----------------------------+---------+
-- | delivery_id                 | int     |
-- | customer_id                 | int     |
-- | order_date                  | date    |
-- | customer_pref_delivery_date | date    |
-- +-----------------------------+---------+
-- delivery_id is the column of unique values of this table.
-- The table holds information about food delivery to customers that make orders at some date and specify a preferred delivery date (on the same order date or after it).
 

-- If the customer's preferred delivery date is the same as the order date, 
        -- then the order is called immediate; otherwise, it is called scheduled.
-- The first order of a customer is the order with the earliest order date that the customer made. 
        -- It is guaranteed that a customer has precisely one first order.

-- Write a solution to find the percentage of immediate orders in the first orders of all customers, rounded to 2 decimal places.

-- The result format is in the following example.

 

-- Example 1:

-- Input: 
-- Delivery table:
-- +-------------+-------------+------------+-----------------------------+
-- | delivery_id | customer_id | order_date | customer_pref_delivery_date |
-- +-------------+-------------+------------+-----------------------------+
-- | 1           | 1           | 2019-08-01 | 2019-08-02                  |
-- | 2           | 2           | 2019-08-02 | 2019-08-02                  |
-- | 3           | 1           | 2019-08-11 | 2019-08-12                  |
-- | 4           | 3           | 2019-08-24 | 2019-08-24                  |
-- | 5           | 3           | 2019-08-21 | 2019-08-22                  |
-- | 6           | 2           | 2019-08-11 | 2019-08-13                  |
-- | 7           | 4           | 2019-08-09 | 2019-08-09                  |
-- +-------------+-------------+------------+-----------------------------+
-- Output: 
-- +----------------------+
-- | immediate_percentage |
-- +----------------------+
-- | 50.00                |
-- +----------------------+
-- Explanation: 
-- The customer id 1 has a first order with delivery id 1 and it is scheduled.
-- The customer id 2 has a first order with delivery id 2 and it is immediate.
-- The customer id 3 has a first order with delivery id 5 and it is scheduled.
-- The customer id 4 has a first order with delivery id 7 and it is immediate.
-- Hence, half the customers have immediate first orders.

WITH cust_order AS (
    SELECT customer_id, order_date, customer_pref_delivery_date, 
        ROW_NUMBER() OVER(PARTITION BY customer_id ORDER BY order_date) AS date_rnk
    FROM Delivery
)
SELECT ROUND(
        (COUNT(
            CASE 
                WHEN order_date = customer_pref_delivery_date
                THEN 1
            END
        )
        / COUNT(customer_id)) * 100
    ,2) AS immediate_percentage
FROM cust_order
WHERE date_rnk = 1;

-- ALTERNATE -> without window function
SELECT ROUND(
        (
            COUNT(
                CASE 
                    WHEN order_date = customer_pref_delivery_date
                    THEN 1
                END
            )
            /COUNT(customer_id)
        )*100
    ,2) AS immediate_percentage
FROM Delivery
WHERE (customer_id, order_date) IN (
    SELECT customer_id, MIN(order_date)
    FROM Delivery
    GROUP BY customer_id
)

-- ## Window (ROW_NUMBER) vs MIN/IN — comparison

-- Window version:
--   1 pass over Delivery — ranks + filters in one windowed scan
--   Cost: requires a sort within each customer_id partition

-- MIN/IN version:
--   2 passes — one for MIN(order_date) subquery, one for outer scan + tuple lookup
--   Cost: no sort, but (customer_id, order_date) IN (...) needs a hash/index
--         lookup per row; benefits a lot from an index on (customer_id, order_date)

-- Both correct, both give 50.00 on the sample.

-- Better: the window function (ROW_NUMBER) version.
-- Reason: it does the ranking and filtering in a single pass 
--             with no dependency on whether a specific composite index exists. 
--         The MIN/IN version can be faster, but only conditionally 
--             — it needs (customer_id, order_date) indexed to avoid a full scan on the IN check; 
--             without that index, it's doing a costly unindexed tuple match on every row. 
--         The window version has no such prerequisite 
--             — it performs consistently regardless of indexing, 
--             which makes it the safer default to lead with in an interview 
--             unless you know the schema is indexed the way you need.



-- The window version is less sensitive to whether a specific composite index exists 
--     (it degrades to "needs a sort" without one, rather than "needs a full scan" 
--     — both versions get worse without any index, just differently), 
--     while the IN version has more upside if that specific index is present, 
--     due to the row-skipping trick that window functions structurally can't replicate.