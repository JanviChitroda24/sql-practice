-- You have two tables:

-- all_products
-- ├── product_id      INT (PK)
-- ├── product_name    VARCHAR(100)
-- ├── category        VARCHAR(50)

-- all_sales
-- ├── sale_id         INT (PK)
-- ├── product_id      INT
-- ├── sale_date       DATE
-- ├── revenue         DECIMAL(10,2)

-- Write a query that returns every product and its total revenue. 
-- Products with no sales should show 0 revenue. 
-- Also return a column called sales_status 
--     — 'Active' if the product had any sale in 2026, 'Inactive' if it only had sales before 2026, and 'Never Sold' if it has no sales at all.

SELECT p.product_id, p.product_name, 
    COALESCE(SUM(s.revenue),0) AS total_revenue,
    CASE 
        WHEN MAX(sale_date) IS NULL
            THEN 'Never Sold'
        WHEN YEAR(MAX(sale_date)) = 2026
            THEN 'Active'
        ELSE 'Inactive'
    END AS sales_status
FROM all_products p LEFT JOIN all_sales s 
    ON p.product_id = s.product_id
GROUP BY p.product_id, p.product_name;