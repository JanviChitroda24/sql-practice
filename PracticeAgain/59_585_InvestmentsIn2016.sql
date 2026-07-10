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

WITH lat_long_pair_tbl AS (
    SELECT  pid, tiv_2015, tiv_2016, lat, lon, 
        CONCAT(CAST(lat AS CHAR) , '_',  CAST(lon AS CHAR)) AS lat_long_pair
    FROM Insurance
),
record_count AS (
    SELECT  pid, tiv_2016,  
        COUNT(tiv_2015) OVER(PARTITION BY tiv_2015) AS tiv_105_cnt,
        COUNT(lat_long_pair) OVER(PARTITION BY lat_long_pair) AS lat_long_pair_cnt
    FROM lat_long_pair_tbl
)
SELECT ROUND(SUM(tiv_2016),2) AS tiv_2016
FROM record_count
WHERE tiv_105_cnt>1 AND lat_long_pair_cnt=1;

--- alternate soltuion without window function
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

-- Combining both approaches
WITH pairs_count AS (
    SELECT pid, tiv_2015, tiv_2016, lat, lon, 
        COUNT(tiv_2015) OVER(PARTITION BY tiv_2015) AS tiv_2015_cnt,
        COUNT(*) OVER(PARTITION BY LAT, lon) AS lat_lon_cnt
    FROM Insurance
)
SELECT ROUND(SUM(tiv_2016),2) AS tiv_2016
FROM pairs_count
WHERE tiv_2015_cnt>1 AND lat_lon_cnt=1;


-- ## Window vs subquery: 3 approaches to "shared value + unique pair" checks

-- 1. Window + CONCAT(lat,lon)      → BUG: string concat can collide (1,23 = 12,3)
-- 2. IN (subquery GROUP BY/HAVING) → correct, 2 scans, reads like plain English
-- 3. Window + PARTITION BY lat,lon → correct, 1 scan, shortest — DEFAULT TO THIS

-- Rule: never CONCAT columns to compare combos.
-- Use PARTITION BY col1, col2 (window) or GROUP BY col1, col2 (subquery) directly.


-- ## Subquery (GROUP BY/HAVING) vs Window function — pass count

-- Subquery version:
--   IN (SELECT tiv_2015 FROM Insurance GROUP BY tiv_2015 HAVING COUNT(*)>1)
--   AND (lat,lon) IN (SELECT lat,lon FROM Insurance GROUP BY lat,lon HAVING COUNT(*)=1)
-- → 2 separate scans/aggregations, each independent, each rebuilt from scratch
-- → each subquery is NOT correlated (no outer row reference), so still just 1 scan
--    per subquery — but that's 2 total table reads, not 1

-- Window function version:
--   COUNT(*) OVER(PARTITION BY tiv_2015) AS tiv_cnt,
--   COUNT(*) OVER(PARTITION BY lat, lon) AS loc_cnt
-- → 1 single scan of the table computes BOTH counts simultaneously,
--   attached to every row inline — no separate subquery executions at all

-- Rule: when you need 2+ independent "how many rows share X" checks,
-- window functions compute them all in one pass; stacked subqueries
-- each re-scan/re-aggregate the table separately.