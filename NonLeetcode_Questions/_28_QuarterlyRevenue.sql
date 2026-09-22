-- Q28

-- You have a table called quarterly_revenue:

-- quarterly_revenue
-- ├── year           INT
-- ├── quarter        INT (1-4)
-- ├── region         VARCHAR(50)
-- ├── revenue        DECIMAL(12,2)

-- The data is stored with one row per year/quarter/region. 
-- Write a query that unpivots this into a normalized format 
--     AND also write a query that takes normalized data and pivots it back.

-- Part A: 
-- Given a table yearly_summary with columns region, q1_revenue, q2_revenue, q3_revenue, q4_revenue, 
--     unpivot it into rows with columns region, quarter, revenue.

-- Part B: Take the quarterly_revenue table above and pivot it so each quarter becomes a column. 
-- Return region, q1_revenue, q2_revenue, q3_revenue, q4_revenue.

-- PART A
SELECT region, 1 AS quarter, q1_revenue AS revenue
FROM yearly_summary
UNION ALL
SELECT region, 2 AS quarter, q2_revenue AS revenue
FROM yearly_summary
UNION ALL
SELECT region, 3 AS quarter, q3_revenue AS revenue
FROM yearly_summary
UNION ALL
SELECT region, 4 AS quarter, q4_revenue AS revenue
FROM yearly_summary

-- PART B
SELECT region, 
    SUM(CASE 
        WHEN quarter=1 THEN revenue
    END) AS q1_revenue, 
    SUM(CASE 
        WHEN quarter=2 THEN revenue
    END) AS q2_revenue, 
    SUM(CASE 
        WHEN quarter=3 THEN revenue
    END) AS q3_revenue, 
    SUM(CASE 
        WHEN quarter=4 THEN revenue
    END) AS q4_revenue
FROM quarterly_revenue
GROUP BY region;