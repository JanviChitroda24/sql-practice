-- 585. Investments in 2016
-- http://leetcode.com/problems/investments-in-2016/description/

-- Table: Insurance

-- +-------------+-------+
-- | Column Name | Type  |
-- +-------------+-------+
-- | pid         | int   |
-- | tiv_2015    | float |
-- | tiv_2016    | float |
-- | lat         | float |
-- | lon         | float |
-- +-------------+-------+
-- pid is the primary key (column with unique values) for this table.
-- Each row of this table contains information about one policy where:
-- pid is the policyholder's policy ID.
-- tiv_2015 is the total investment value in 2015 and tiv_2016 is the total investment value in 2016.
-- lat is the latitude of the policy holder's city. It's guaranteed that lat is not NULL.
-- lon is the longitude of the policy holder's city. It's guaranteed that lon is not NULL.
 

-- Write a solution to report the sum of all total investment values in 2016 tiv_2016, for all policyholders who:

-- have the same tiv_2015 value as one or more other policyholders, and
-- are not located in the same city as any other policyholder (i.e., the (lat, lon) attribute pairs must be unique).
-- Round tiv_2016 to two decimal places.

-- The result format is in the following example.

 

-- Example 1:

-- Input: 
-- Insurance table:
-- +-----+----------+----------+-----+-----+
-- | pid | tiv_2015 | tiv_2016 | lat | lon |
-- +-----+----------+----------+-----+-----+
-- | 1   | 10       | 5        | 10  | 10  |
-- | 2   | 20       | 20       | 20  | 20  |
-- | 3   | 10       | 30       | 20  | 20  |
-- | 4   | 10       | 40       | 40  | 40  |
-- +-----+----------+----------+-----+-----+
-- Output: 
-- +----------+
-- | tiv_2016 |
-- +----------+
-- | 45.00    |
-- +----------+
-- Explanation: 
-- The first record in the table, like the last record, meets both of the two criteria.
-- The tiv_2015 value 10 is the same as the third and fourth records, and its location is unique.

-- The second record does not meet any of the two criteria. Its tiv_2015 is not like any other policyholders and its location is the same as the third record, which makes the third record fail, too.
-- So, the result is the sum of tiv_2016 of the first and last record, which is 45.

-- # Write your MySQL query statement below

-- approach 1: using window functions
WITH policy_comparison AS (
    SELECT pid, tiv_2015, tiv_2016, lat, lon,
            COUNT(tiv_2015) OVER(PARTITION BY tiv_2015) AS tiv_2015_count,
            COUNT(*) OVER(PARTITION BY lat, lon) AS lat_long_pair
    FROM Insurance
)
SELECT ROUND(SUM(tiv_2016),2) AS tiv_2016
FROM policy_comparison
WHERE tiv_2015_count>=2 AND lat_long_pair=1;

-- approach 2: using subquery + group by
SELECT ROUND(SUM(tiv_2016),2) AS tiv_2016
FROM Insurance
WHERE 
    tiv_2015 IN (
        SELECT tiv_2015
        FROM Insurance
        GROUP BY tiv_2015
        HAVING COUNT(tiv_2015) > 1
    )
    AND 
    (lat, lon) IN (
        SELECT lat, lon
        FROM Insurance
        GROUP BY lat, lon
        HAVING COUNT(*) = 1
    );

-- approach 3: using join and group by
SELECT ROUND(SUM(tiv_2016),2) AS tiv_2016
FROM Insurance i 
JOIN (
    SELECT tiv_2015
    FROM Insurance
    GROUP BY tiv_2015
    HAVING COUNT(tiv_2015) > 1

) t15
ON i.tiv_2015 = t15.tiv_2015
JOIN (
    SELECT lat, lon
    FROM Insurance
    GROUP BY lat, lon
    HAVING COUNT(*)=1
) ll
ON i.lat = ll.lat AND i.lon = ll.lon


-- | Factor | Approach 1 (Window) | Approach 2 (Subquery IN) | Approach 3 (JOIN) |
-- |---|---|---|---|
-- | Table scans | 1 | 3 | 3 |
-- | Intermediate rows | Full table + 2 extra cols | 2 small grouped sets | 2 small grouped sets |
-- | Memory | Higher (window buffers) | Low | Low |
-- | Index usage | Moderate (partitions) | Good (GROUP BY + IN) | Best (GROUP BY + equi-join) |
-- | Readability | Cleanest | Medium | Most verbose |
-- | NULL safety | Safe (COUNT ignores NULLs) | IN can break with NULLs | JOIN skips NULLs naturally |
-- | Small table (<10K rows) | Best | Good | Good |
-- | Large table (1M+ rows) | Slowest (buffers everything) | Good | Best |

-- **When to use which:**

-- **Approach 1 (Window)** — Best for interviews and small-to-medium data. Single scan, easy to read, shows advanced SQL. But window functions buffer the entire table in memory before filtering, so on very large tables the overhead adds up.

-- **Approach 2 (Subquery IN)** — Good middle ground. Three scans but each subquery produces a small result. The risk is that IN does a list comparison for every row, which can be slower than a hash join on large datasets.

-- **Approach 3 (JOIN)** — Best for production on large tables. The optimizer can use hash joins or index lookups on the derived tables, which scale better than IN lists. Three scans but the join execution is more efficient than IN matching.

-- **Bottom line:** Lead with Approach 1 in interviews for clarity, mention Approach 3 as the production optimization if they ask about scale.