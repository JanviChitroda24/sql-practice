-- 571. Find Median Given Frequency of Numbers
-- https://leetcode.ca/all/571.html

-- he Numbers table keeps the value of number and its frequency.

-- +----------+-------------+
-- |  Number  |  Frequency  |
-- +----------+-------------|
-- |  0       |  7          |
-- |  1       |  1          |
-- |  2       |  3          |
-- |  3       |  1          |
-- +----------+-------------+

-- In this table, the numbers are 0, 0, 0, 0, 0, 0, 0, 1, 2, 2, 2, 3, so the median is (0 + 0) / 2 = 0.

-- +--------+
-- | median |
-- +--------|
-- | 0.0000 |
-- +--------+
-- Write a query to find the median of all numbers and name the result as median.

WITH freq_num AS (
    SELECT Number, Frequency, 
        SUM(Frequency) OVER(ORDER BY Number ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS cum_sum,
        SUM(Frequency) OVER() AS total_freq
    FROM Numbers
)
SELECT ROUND(
        AVG(Number)
    ,4) AS median
FROM freq_num
WHERE total_freq/2 <= cum_sum AND total_freq/2 >= cum_sum-Frequency;


-- **Median from Frequency Table — The Math Behind It**

-- **Why cumulative sum?**
-- The table gives compressed data — Number 0 with Frequency 7 means 0 appears 7 times. If you expanded it, you'd get: 0,0,0,0,0,0,0,1,2,2,2,3. The median is the middle value of this expanded list. Cumulative sum lets you figure out each number's position range WITHOUT actually expanding the list.

-- **Position range logic:**
-- - `cum_sum` = running total of frequencies = the LAST position this number occupies
-- - `cum_sum - Frequency` = the last position BEFORE this number starts
-- - So Number occupies positions `(cum_sum - Frequency + 1)` through `cum_sum`

-- Example: Number 2 has Frequency 3 and cum_sum 11
-- - It starts at position `11 - 3 + 1 = 9`
-- - It ends at position `11`
-- - So it covers positions 9, 10, 11

-- **Where is the median?**
-- - Total count = N
-- - Median position = N/2 (using decimal division)
-- - We need the number(s) whose position range CONTAINS this midpoint

-- **The two conditions are a range check:**
-- - `cum_sum >= N/2` → "this number's range ENDS at or after the midpoint" (reaches far enough)
-- - `cum_sum - Frequency <= N/2` → "this number's range STARTS at or before the midpoint" (starts early enough)
-- - Both true → the midpoint falls INSIDE this number's range

-- **Why AVG at the end?**
-- - Odd N → exactly one number contains the midpoint → AVG returns it
-- - Even N → one or two numbers contain the midpoint → AVG gives the mean of the two middle values

-- **Why decimal division handles both odd and even:**
-- - Even: N=12, N/2=6.0 → finds number(s) covering position 6
-- - Odd: N=5, N/2=2.5 → finds the number covering positions 2 AND 3 (since 2.5 sits between them, only the number straddling that point passes both conditions)