-- 579. Find Cumulative Salary of an Employee
-- https://leetcode.com/problems/find-cumulative-salary-of-an-employee/

-- Problem Summary
-- For each employee, calculate the 3-month cumulative salary excluding the most recent month.

-- Cumulative = sum of current month + previous 2 months
-- Exclude the employee's most recent month from the output entirely
-- Order by id ASC, month DESC

-- Example
-- Input:

-- | Id | Month | Salary |
-- |----|-------|--------|
-- | 1  | 1     | 20     |
-- | 2  | 1     | 20     |
-- | 1  | 2     | 30     |
-- | 2  | 2     | 30     |
-- | 3  | 2     | 40     |
-- | 1  | 3     | 40     |
-- | 3  | 3     | 60     |
-- | 1  | 4     | 60     |
-- | 3  | 4     | 70     |
-- Output

-- | Id | Month | Salary |
-- |----|-------|--------|
-- | 1  | 3     | 90     |
-- | 1  | 2     | 50     |
-- | 1  | 1     | 20     |
-- | 2  | 1     | 20     |
-- | 3  | 3     | 100    |
-- | 3  | 2     | 40     |
 

-- Explanation
-- Employee '1' has 3 salary records for the following 3 months except the most recent month '4': salary 40 for month '3', 30 for month '2' and 20 for month '1'
-- So the cumulative sum of salary of this employee over 3 months is 90(40+30+20), 50(30+20) and 20 respectively.Multilateral Organizations

-- | Id | Month | Salary |
-- |----|-------|--------|
-- | 1  | 3     | 90     |
-- | 1  | 2     | 50     |
-- | 1  | 1     | 20     |
-- Employee '2' only has one salary record (month '1') except its most recent month '2'.
-- | Id | Month | Salary |
-- |----|-------|--------|
-- | 2  | 1     | 20     |
 

-- Employ '3' has two salary records except its most recent pay month '4': month '3' with 60 and month '2' with 40. So the cumulative salary is as following.
-- | Id | Month | Salary |
-- |----|-------|--------|
-- | 3  | 3     | 100    |
-- | 3  | 2     | 40     |
 


SELECT Id, Month, 
    SUM(Salary) OVER(PARTITION BY Id ORDER BY Month ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) AS Salary
FROM Employee
WHERE (Id, Month) NOT IN 
    (
        SELECT Id, MAX(Month) AS Month
        FROM Employee
        GROUP BY Id
    )
ORDER BY Id, Month DESC;

-- EXISTS approach
SELECT Id, Month, 
    SUM(Salary) OVER(PARTITION BY Id ORDER BY Month ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) AS Salary
FROM Employee e
WHERE EXISTS 
    (
        SELECT 1
        FROM Employee e1
        WHERE e.Id = e1.Id AND e.Month < e1.Month
    )
ORDER BY Id, Month DESC;

-- | **NOT IN → EXISTS conversion** | `NOT IN (SELECT max)` becomes `EXISTS (SELECT 1 WHERE same_id AND current_month < other_month)` — keeps rows that aren't the max. No GROUP BY needed |

-- Self join approach
SELECT e1.Id, e1.Month, SUM(e2.Salary)
FROM Employee e1 JOIN Employee e2
        ON e1.Id = e2.Id AND e2.Month BETWEEN e1.Month - 2 AND e1.Month
WHERE (e1.Id, e1.Month) NOT IN 
    (
        SELECT Id, MAX(Month) AS Month
        FROM Employee
        GROUP BY Id
    )
GROUP BY e1.Id, e1.Month
ORDER BY e1.Id, e1.Month DESC;