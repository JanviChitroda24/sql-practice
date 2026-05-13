-- 626. Exchange Seats
-- https://leetcode.com/problems/exchange-seats/description/

-- SQL Schema

-- Table: Seat

-- +-------------+---------+
-- | Column Name | Type    |
-- +-------------+---------+
-- | id          | int     |
-- | student     | varchar |
-- +-------------+---------+
-- id is the primary key (unique value) column for this table.
-- Each row of this table indicates the name and the ID of a student.
-- The ID sequence always starts from 1 and increments continuously.
 

-- Write a solution to swap the seat id of every two consecutive students. If the number of students is odd, the id of the last student is not swapped.

-- Return the result table ordered by id in ascending order.

-- The result format is in the following example.

 

-- Example 1:

-- Input: 
-- Seat table:
-- +----+---------+
-- | id | student |
-- +----+---------+
-- | 1  | Abbot   |
-- | 2  | Doris   |
-- | 3  | Emerson |
-- | 4  | Green   |
-- | 5  | Jeames  |
-- +----+---------+
-- Output: 
-- +----+---------+
-- | id | student |
-- +----+---------+
-- | 1  | Doris   |
-- | 2  | Abbot   |
-- | 3  | Green   |
-- | 4  | Emerson |
-- | 5  | Jeames  |
-- +----+---------+
-- Explanation: 
-- Note that if the number of students is odd, there is no need to change the last one's seat.

SELECT CASE 
            WHEN id = (SELECT MAX(id) FROM Seat) AND id%2=1
                THEN id
            WHEN id % 2 = 0 THEN id - 1
            ELSE id + 1
        END AS id,
        student
FROM Seat
ORDER BY id;

-- alternative solution with 2 cases and row_number()
SELECT 
    ROW_NUMBER() OVER( ORDER BY 
            CASE 
                WHEN id % 2 = 0 THEN id - 1
                ELSE id + 1
            END
        )
        AS id,
    student
FROM Seat;

-- MAX subquery is O(n) yes, but it only runs once (the optimizer computes it before scanning). The CASE itself is O(1) per row, so the main scan is O(n). ORDER BY is O(n log n).
-- So your total is: O(n) for MAX + O(n) for CASE scan + O(n log n) for ORDER BY = O(n log n) overall, dominated by the sort.
-- The window function version is also O(n log n) because ROW_NUMBER needs sorting too. So both are the same complexity — your version just has less overhead and is simpler.