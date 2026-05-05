```sql
1384 — Total Sales Amount by Year

Table: Product
+---------------+---------+
| Column Name   | Type    |
+---------------+---------+
| product_id    | int     |
| product_name  | varchar |
+---------------+---------+
product_id is the primary key for this table.
product_name is the name of the product.

Table: Sales

+---------------------+---------+
| Column Name         | Type    |
+---------------------+---------+
| product_id          | int     |
| period_start        | varchar |
| period_end          | date    |
| average_daily_sales | int     |
+---------------------+---------+
product_id is the primary key for this table.
period_start and period_end indicates the start and end date for sales period, both dates are inclusive.
The average_daily_sales column holds the average daily sales amount of the items for the period.

Write an SQL query to report the Total sales amount of each item for each year, with corresponding product name, product_id, product_name and report_year. Programming

Dates of the sales years are between 2018 to 2020. Return the result table ordered by product_id and report_year.

The query result format is in the following example:

Product table:
+------------+--------------+
| product_id | product_name |
+------------+--------------+
| 1          | LC Phone     |
| 2          | LC T-Shirt   |
| 3          | LC Keychain  |
+------------+--------------+

Sales table:
+------------+--------------+-------------+---------------------+
| product_id | period_start | period_end  | average_daily_sales |
+------------+--------------+-------------+---------------------+
| 1          | 2019-01-25   | 2019-02-28  | 100                 |
| 2          | 2018-12-01   | 2020-01-01  | 10                  |
| 3          | 2019-12-01   | 2020-01-31  | 1                   |
+------------+--------------+-------------+---------------------+

Result table:
+------------+--------------+-------------+--------------+
| product_id | product_name | report_year | total_amount |
+------------+--------------+-------------+--------------+
| 1          | LC Phone     |    2019     | 3500         |
| 2          | LC T-Shirt   |    2018     | 310          |
| 2          | LC T-Shirt   |    2019     | 3650         |
| 2          | LC T-Shirt   |    2020     | 10           |
| 3          | LC Keychain  |    2019     | 31           |
| 3          | LC Keychain  |    2020     | 31           |
+------------+--------------+-------------+--------------+
LC Phone was sold for the period of 2019-01-25 to 2019-02-28, and there are 35 days for this period. Total amount 35*100 = 3500. 
LC T-shirt was sold for the period of 2018-12-01 to 2020-01-01, and there are 31, 365, 1 days for years 2018, 2019 and 2020 respectively.
LC Keychain was sold for the period of 2019-12-01 to 2020-01-31, and there are 31, 31 days for years 2019 and 2020 respectively.
Difficulty:
```



WITH RECURSIVE sales_by_year AS (

    SELECT  product_id, product_name, period_start, period_end, average_daily_sales,
            YEAR(period_start) AS report_year, 
            CASE 
                WHEN YEAR(period_start) = YEAR(period_end)
                    THEN (DATEDIFF(period_end, period_start)+1) * average_daily_sales
                ELSE
                    (DATEDIFF(DATE(CONCAT(YEAR(period_start), '-12-31')),period_start)+1) *average_daily_sales
            END AS total_amount
    FROM Product p JOIN Sales s
    ON p.product_id = s.product_id

    UNION ALL 

    SELECT  product_id, product_name, 
            DATE(CONCAT(YEAR(period_start)+1,'-01-01')) AS period_start, 
            period_end, average_daily_sales,
            YEAR(period_start)+1 AS report_year, 
            CASE 
                WHEN YEAR(period_start) + 1 = YEAR(period_end)
                    THEN (DATEDIFF(period_end, DATE(CONCAT(YEAR(period_start)+1, '-01-01'))) +1) * average_daily_sales
                ELSE
                    365 * average_daily_sales
            END AS total_amount
    FROM sales_by_year
    WHERE YEAR(period_start) < YEAR(period_end) 
)
SELECT  product_id, product_name, report_year, total_amount
FROM sales_by_year;

----
---- Without reruison since the years are between 2018 - 2020
----

-- Let me walk through step by step with Product 2:

-- ---

-- ### Setup

-- **Product 2:** period_start = 2018-12-01, period_end = 2020-01-01

-- **Years table:**
-- ```
-- | year |
-- |------|
-- | 2018 |
-- | 2019 |
-- | 2020 |
-- ```

-- ---

-- ### Step 1: The JOIN

-- ```sql
-- JOIN years y ON y.year BETWEEN YEAR(s.period_start) AND YEAR(s.period_end)
-- ```

-- For Product 2:
-- ```
-- YEAR(period_start) = 2018
-- YEAR(period_end) = 2020

-- Which years are BETWEEN 2018 AND 2020?
-- → 2018 ✓
-- → 2019 ✓
-- → 2020 ✓
-- ```

-- **Result:** Product 2 joins with **3 rows** (one per year):

-- ```
-- | product_id | period_start | period_end | year |
-- |------------|--------------|------------|------|
-- | 2          | 2018-12-01   | 2020-01-01 | 2018 |
-- | 2          | 2018-12-01   | 2020-01-01 | 2019 |
-- | 2          | 2018-12-01   | 2020-01-01 | 2020 |
-- ```

-- ---

-- ### Step 2: GREATEST and LEAST Logic

-- For each row, we calculate the **overlap** between:
-- - The product's sale period (period_start to period_end)
-- - That year's boundaries (Jan 1 to Dec 31)

-- ```
-- GREATEST(period_start, year_start) → Where overlap BEGINS
-- LEAST(period_end, year_end)        → Where overlap ENDS
-- ```

-- ---

-- ### Step 3: Walk Through Each Year

-- **Year 2018:**
-- ```
-- Year boundaries:  2018-01-01 to 2018-12-31
-- Sale period:      2018-12-01 to 2020-01-01

-- Overlap start: GREATEST(2018-12-01, 2018-01-01) = 2018-12-01
-- Overlap end:   LEAST(2020-01-01, 2018-12-31)    = 2018-12-31

-- Days: DATEDIFF(2018-12-31, 2018-12-01) + 1 = 31
-- ```

-- **Year 2019:**
-- ```
-- Year boundaries:  2019-01-01 to 2019-12-31
-- Sale period:      2018-12-01 to 2020-01-01

-- Overlap start: GREATEST(2018-12-01, 2019-01-01) = 2019-01-01
-- Overlap end:   LEAST(2020-01-01, 2019-12-31)    = 2019-12-31

-- Days: DATEDIFF(2019-12-31, 2019-01-01) + 1 = 365
-- ```

-- **Year 2020:**
-- ```
-- Year boundaries:  2020-01-01 to 2020-12-31
-- Sale period:      2018-12-01 to 2020-01-01

-- Overlap start: GREATEST(2018-12-01, 2020-01-01) = 2020-01-01
-- Overlap end:   LEAST(2020-01-01, 2020-12-31)    = 2020-01-01

-- Days: DATEDIFF(2020-01-01, 2020-01-01) + 1 = 1
-- ```

-- ---

-- ### Visual

-- ```
-- 2018          2019          2020
-- |-------------|-------------|-------------|
--         Jan 1       Jan 1       Jan 1

-- Sale period for Product 2:
--             [=========================]
--          2018-12-01              2020-01-01

-- Overlap per year:
-- 2018:       [===]                           → 31 days (Dec only)
-- 2019:             [=====================]   → 365 days (full year)
-- 2020:                                 [=]   → 1 day (Jan 1 only)
-- ```

-- ---

-- ### Final Output

-- | product_id | year | days | total_amount |
-- |------------|------|------|--------------|
-- | 2 | 2018 | 31 | 31 × 10 = 310 |
-- | 2 | 2019 | 365 | 365 × 10 = 3650 |
-- | 2 | 2020 | 1 | 1 × 10 = 10 |

-- ---

-- ### Key Insight

-- **JOIN** expands one row into multiple rows (one per year).

-- **GREATEST/LEAST** calculates the overlap for each year.

-- No recursion needed — just smart date math.

WITH years AS (
    SELECT 2018 AS year
    UNION 
    SELECT 2019 
    UNION 
    SELECT 2020
)
SELECT p.product_id, p.product_name, y.year AS report_year, 
       (DATEDIFF(
            LEAST(s.period_end, DATE(CONCAT(y.year, '-12-31'))),
            GREATEST(s.period_start, DATE(CONCAT(y.year, '-01-01')))
       ) +1) * s.average_daily_sales AS total_amount
FROM Product p 
JOIN Sales s ON p.product_id =  s.product_id
JOIN years y ON y.year BETWEEN YEAR(s.period_start) AND YEAR(s.period_end)
ORDER BY p.product_id, y.year;