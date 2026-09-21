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

WITH cus_orders AS (
    SELECT c.customer_id, c.customer_name, c.region,
        SUM(total_amount) AS total_customer_spend
    FROM customers c JOIN ORDERS o
        ON c.customer_id = o.customer_id
    GROUP BY c.customer_id, c.customer_name, c.region
    HAVING COUNT(o.order_id)>=3 
),
customer_ranking AS (
    SELECT customer_id, customer_name, region, total_customer_spend,
        COUNT(customer_id) OVER(PARTITION BY region) AS cust_per_region_cnt,
        DENSE_RANK() OVER(PARTITION BY region ORDER BY total_customer_spend DESC) AS top_spender_rnk,
        DENSE_RANK() OVER(PARTITION BY region ORDER BY total_customer_spend) AS bottom_spender_rnk
    FROM cus_orders
)
SELECT region, 
    MIN(CASE 
        WHEN top_spender_rnk=1
        THEN customer_name
    END) AS top_customer_name, 
    MIN(CASE 
        WHEN top_spender_rnk=1
        THEN total_customer_spend
    END) AS top_customer_spend, 
    MIN(CASE 
        WHEN bottom_spender_rnk=1
        THEN customer_name
    END) AS bottom_customer_name, 
    MIN(CASE 
        WHEN bottom_spender_rnk=1
        THEN total_customer_spend
    END) AS bottom_customer_spend
FROM customer_ranking
WHERE cust_per_region_cnt>=2
GROUP BY region;