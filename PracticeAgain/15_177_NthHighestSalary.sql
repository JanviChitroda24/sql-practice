"""
177. Nth Highest Salary
http://leetcode.com/problems/nth-highest-salary/description/

Table: Employee

+-------------+------+
| Column Name | Type |
+-------------+------+
| id          | int  |
| salary      | int  |
+-------------+------+
id is the primary key (column with unique values) for this table.
Each row of this table contains information about the salary of an employee.
 

Write a solution to find the nth highest distinct salary from the Employee table. If there are less than n distinct salaries, return null.

The result format is in the following example.

 

Example 1:

Input: 
Employee table:
+----+--------+
| id | salary |
+----+--------+
| 1  | 100    |
| 2  | 200    |
| 3  | 300    |
+----+--------+
n = 2
Output: 
+------------------------+
| getNthHighestSalary(2) |
+------------------------+
| 200                    |
+------------------------+
Example 2:

Input: 
Employee table:
+----+--------+
| id | salary |
+----+--------+
| 1  | 100    |
+----+--------+
n = 2
Output: 
+------------------------+
| getNthHighestSalary(2) |
+------------------------+
| null                   |
+------------------------+

"""
CREATE FUNCTION getNthHighestSalary(N INT) RETURNS INT
BEGIN
  RETURN (
      WITH sal_rank AS (
        SELECT salary, 
            DENSE_RANK() OVER(ORDER BY salary DESC) AS sal_rnk,
            COUNT(salary) AS sal_cnt
        FROM Employee
        GROUP BY salary
    )
    SELECT 
        CASE
        WHEN N = sal_cnt
        THEN salary
        ELSE 
            NULL
        END AS getNthHighestSalary
    FROM sal_rank
  );
END


-- Nth Highest = DENSE_RANK → WHERE rnk = N
    -- GROUP BY the value first to deduplicate ties before ranking
    -- NULL case is handled automatically — if N exceeds distinct count, WHERE returns no rows → function returns NULL
    -- Never use LIMIT N-1, 1 — breaks on ties and not interview-friendly