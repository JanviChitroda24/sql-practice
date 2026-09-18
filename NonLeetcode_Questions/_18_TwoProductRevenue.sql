-- Q18

-- You have a table called order_items:

-- order_items
-- ├── order_id        INT
-- ├── product_id      INT
-- ├── customer_id     INT
-- ├── order_date      DATE
-- ├── quantity         INT
-- ├── unit_price      DECIMAL(10,2)

-- Write a query that finds pairs of products that are frequently bought together — meaning they appear in the same order. 
-- Return product_a, product_b, times_bought_together, and avg_combined_revenue (average total revenue of both products across all orders where they appeared together). 
-- Only include pairs that co-occurred in at least 5 orders. Don't count a pair twice (A,B and B,A should appear as one row).


SELECT o1.product_id AS product_a, o2.product_id AS product_b, 
    COUNT(*) AS times_bought_together,
    ROUND(AVG(o1.quantity*o1.unit_price + o2.quantity*o2.unit_price),2) AS avg_combined_revenue
FROM order_items o1 JOIN order_items o2
    ON o1.order_id = o2.order_id 
        AND o1.customer_id = o2.customer_id
        AND o1.product_id > o2.product_id
GROUP BY o1.product_id, o2.product_id
HAVING COUNT(*) >= 5;