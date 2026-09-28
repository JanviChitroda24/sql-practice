-- You have two tables:

-- customers
-- ├── customer_id     INT (PK)
-- ├── customer_name   VARCHAR(100)
-- ├── region          VARCHAR(50)

-- orders
-- ├── order_id        INT (PK)
-- ├── customer_id     INT
-- ├── order_date      DATE
-- ├── total_amount    DECIMAL(10,2)

-- Write a query that for each region finds the customer who spent the most 
--     AND the customer who spent the least. A customer must have at least 3 orders to be considered. 
-- If a region has fewer than 2 qualifying customers, exclude that region. 
-- Return region, top_customer_name, top_customer_spend, bottom_customer_name, bottom_customer_spend.

WITH customer_order_join AS (
    SELECT c.customer_id, c.customer_name, c.region, SUM(o.total_amount) AS customer_spend
    FROM customers c JOIN orders o 
        ON c.customer_id = o.customer_id
    GROUP BY c.customer_id, c.customer_name, c.region
    HAVING COUNT(*) >=3
),
customer_spend_rank AS (
    SELECT region, customer_name, customer_spend,
        DENSE_RANK() OVER(PARTITION BY region ORDER BY customer_spend) AS bottom_rank,
        DENSE_RANK() OVER(PARTITION BY region ORDER BY customer_spend DESC) AS top_rank,
        COUNT(*) OVER(PARTITION BY region) AS cust_cnt
    FROM customer_order_join
)
SELECT region,
    MIN(CASE 
        WHEN top_rank = 1
        THEN customer_name
    END) AS top_customer_name,
    MIN(CASE 
        WHEN top_rank = 1
        THEN customer_spend
    END) AS top_customer_spend,
    MIN(CASE 
        WHEN bottom_rank = 1
        THEN customer_name
    END) AS bottom_customer_name,
    MIN(CASE 
        WHEN bottom_rank = 1
        THEN customer_spend
    END) AS bottom_customer_spend
FROM customer_spend_rank
WHERE cust_cnt >= 2
GROUP BY region;