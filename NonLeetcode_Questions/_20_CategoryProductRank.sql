-- Q20

-- You have two tables:

-- products
-- ├── product_id      INT (PK)
-- ├── product_name    VARCHAR(100)
-- ├── category        VARCHAR(50)
-- ├── launch_date     DATE

-- sales
-- ├── sale_id         INT (PK)
-- ├── product_id      INT
-- ├── customer_id     INT
-- ├── sale_date       DATE
-- ├── quantity         INT
-- ├── unit_price      DECIMAL(10,2)

-- Write a query that classifies each product into a performance tier based on its revenue rank within its category. 
-- Top 10% = 'Platinum', next 20% = 'Gold', next 30% = 'Silver', bottom 40% = 'Bronze'. 
-- Return product_id, product_name, category, total_revenue, and performance_tier. Include products with zero sales as 'Bronze'.

WITH product_revenue AS(
    SELECT p.product_id, p.product_name, p.category,
        IFNULL(ROUND(SUM(s.quantity*s.unit_price),2),0) AS total_revenue
    FROM products p LEFT JOIN sales s
        ON p.product_id = s.product_id
    GROUP BY p.product_id, p.product_name, p.category
),
product_category_revenue AS(
    SELECT product_id, product_name, category, total_revenue, 
        DENSE_RANK() OVER(PARTITION BY category order by total_revenue DESC) AS prod_rev_rank,
        COUNT(product_id) OVER(PARTITION BY category) AS total_prod_category
    FROM product_revenue
)
SELECT product_id, product_name, category, total_revenue, 
    CASE 
        WHEN total_revenue = 0
            THEN 'Bronze'
        WHEN (prod_rev_rank*100.0)/total_prod_category <= 10
            THEN 'Platinum'
        WHEN (prod_rev_rank*100.0)/total_prod_category <= 30
            THEN 'Gold'
        WHEN (prod_rev_rank*100.0)/total_prod_category <= 60
            THEN 'Silver'
        ELSE 
            'Bronze'
    END AS performance_tier
FROM product_category_revenue;

-- PERCENT RANK FUNCTION
WITH product_revenue AS(
    SELECT p.product_id, p.product_name, p.category,
        IFNULL(ROUND(SUM(s.quantity*s.unit_price),2),0) AS total_revenue
    FROM products p LEFT JOIN sales s
        ON p.product_id = s.product_id
    GROUP BY p.product_id, p.product_name, p.category
),
product_category_revenue AS(
    SELECT product_id, product_name, category, total_revenue, 
        PERCENT_RANK() OVER(PARTITION BY category order by total_revenue DESC) AS prod_rev_rank
    FROM product_revenue
)
SELECT product_id, product_name, category, total_revenue, 
    CASE 
        WHEN total_revenue = 0
            THEN 'Bronze'
        WHEN (prod_rev_rank*100.0) <= 10
            THEN 'Platinum'
        WHEN (prod_rev_rank*100.0) <= 30
            THEN 'Gold'
        WHEN (prod_rev_rank*100.0) <= 60
            THEN 'Silver'
        ELSE 
            'Bronze'
    END AS performance_tier
FROM product_category_revenue;
