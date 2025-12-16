-- 569. Median Employee Salary
-- The Employee table holds all employees. The employee table has three columns: Employee Id, Company Name, and Salary.

-- +-----+------------+--------+
-- |Id   | Company    | Salary |
-- +-----+------------+--------+
-- |1    | A          | 2341   |
-- |2    | A          | 341    |
-- |3    | A          | 15     |
-- |4    | A          | 15314  |
-- |5    | A          | 451    |
-- |6    | A          | 513    |
-- |7    | B          | 15     |
-- |8    | B          | 13     |
-- |9    | B          | 1154   |
-- |10   | B          | 1345   |
-- |11   | B          | 1221   |
-- |12   | B          | 234    |
-- |13   | C          | 2345   |
-- |14   | C          | 2645   |
-- |15   | C          | 2645   |
-- |16   | C          | 2652   |
-- |17   | C          | 65     |
-- +-----+------------+--------+

-- Write a SQL query to find the median salary of each company. Bonus points if you can solve it without using any built-in SQL functions.

-- +-----+------------+--------+
-- |Id   | Company    | Salary |
-- +-----+------------+--------+
-- |5    | A          | 451    |
-- |6    | A          | 513    |
-- |12   | B          | 234    |
-- |9    | B          | 1154   |
-- |14   | C          | 2645   |
-- +-----+------------+--------+




Approach: Using ROW_NUMBER
Step 1: Assign Row Numbers to Each Salary (Ascending and Descending)
For each company, rank salaries from both directions:
sqlSELECT 
    Id,
    Company,
    Salary,
    ROW_NUMBER() OVER(PARTITION BY Company ORDER BY Salary ASC) AS rank_asc,
    ROW_NUMBER() OVER(PARTITION BY Company ORDER BY Salary DESC) AS rank_desc
FROM Employee
```

### Why Both Directions?

**For Company A (6 employees):**
```
Salary | rank_asc | rank_desc
-------|----------|----------
15     | 1        | 6
341    | 2        | 5
451    | 3        | 4    ← Median (difference = 1)
513    | 4        | 3    ← Median (difference = 1)
2341   | 5        | 2
15314  | 6        | 1
```

**For Company C (5 employees):**
```
Salary | rank_asc | rank_desc
-------|----------|----------
65     | 1        | 5
2345   | 2        | 4
2645   | 3        | 3    ← Median (difference = 0)
2645   | 4        | 2
2652   | 5        | 1
The Pattern:

Median values have ABS(rank_asc - rank_desc) <= 1
This works for both odd and even counts!

--- My Recommendation: Solution 1 (ROW_NUMBER ASC/DESC)
sqlSELECT Id, Company, Salary
FROM (
    SELECT 
        Id,
        Company,
        Salary,
        ROW_NUMBER() OVER(PARTITION BY Company ORDER BY Salary ASC) AS rank_asc,
        ROW_NUMBER() OVER(PARTITION BY Company ORDER BY Salary DESC) AS rank_desc
    FROM Employee
) ranked
WHERE ABS(rank_asc - rank_desc) <= 1
ORDER BY Company, Salary;

--- Using ROW_NUMBER with COUNT
SELECT Id, Company, Salary
FROM (
    SELECT 
        Id,
        Company,
        Salary,
        ROW_NUMBER() OVER(PARTITION BY Company ORDER BY Salary) AS row_num,
        COUNT(*) OVER(PARTITION BY Company) AS total_count
    FROM Employee
) ranked
WHERE row_num BETWEEN total_count/2.0 AND total_count/2.0 + 1
ORDER BY Company, Salary;