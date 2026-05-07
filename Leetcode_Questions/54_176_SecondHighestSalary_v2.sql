-- 176. Second Highest Salary
-- https://leetcode.com/problems/second-highest-salary/description/

-- Table: Employee

-- +-------------+------+
-- | Column Name | Type |
-- +-------------+------+
-- | id          | int  |
-- | salary      | int  |
-- +-------------+------+
-- id is the primary key (column with unique values) for this table.
-- Each row of this table contains information about the salary of an employee.
 

-- Write a solution to find the second highest distinct salary from the Employee table. If there is no second highest salary, return null (return None in Pandas).

-- The result format is in the following example.

 

-- Example 1:

-- Input: 
-- Employee table:
-- +----+--------+
-- | id | salary |
-- +----+--------+
-- | 1  | 100    |
-- | 2  | 200    |
-- | 3  | 300    |
-- +----+--------+
-- Output: 
-- +---------------------+
-- | SecondHighestSalary |
-- +---------------------+
-- | 200                 |
-- +---------------------+
-- Example 2:

-- Input: 
-- Employee table:
-- +----+--------+
-- | id | salary |
-- +----+--------+
-- | 1  | 100    |
-- +----+--------+
-- Output: 
-- +---------------------+
-- | SecondHighestSalary |
-- +---------------------+
-- | null                |
-- +---------------------+


-- SOLUTION 1
WITH ranked_salary AS (
    SELECT salary, DENSE_RANK() OVER(ORDER BY salary DESC) AS rnk
    FROM Employee
)
SELECT MAX(salary) AS SecondHighestSalary
FROM ranked_salary
WHERE rnk = 2;

-- SOLUTION 2
SELECT IFNULL(
    (SELECT DISTINCT salary
    FROM Employee
    ORDER BY SALARY DESC
    LIMIT 1 OFFSET 1), NULL) AS SecondHighestSalary

-- SOLUTION 3
SELECT MAX(salary) AS SecondHighestSalary
FROM Employee
WHERE salary < (
    SELECT MAX(salary)
    FROM Employee
);

-- ---

-- # 📊 Comparison Table

-- | Criteria                    | Solution 1 (DENSE_RANK) | Solution 2 (DISTINCT + LIMIT) | Solution 3 (MAX + WHERE) |
-- | --------------------------- | ----------------------- | ----------------------------- | ------------------------ |
-- | ✅ Correct                   | Yes                     | Yes                           | Yes                      |
-- | 🚀 Performance              | ❌ Medium                | ❌ Medium                      | ✅ Best                   |
-- | 🔄 Sorting Required         | ✅ Yes (window fn)       | ✅ Yes (ORDER BY)              | ❌ No                     |
-- | 📈 Time Complexity          | ~ O(n log n)            | ~ O(n log n)                  | ~ O(n)                   |
-- | 📦 Memory Usage             | Higher (window fn)      | Medium                        | Low                      |
-- | 🔁 Handles Duplicates       | ✅ Yes                   | ✅ Yes (DISTINCT)              | ✅ Yes                    |
-- | ⚠️ Handles No Result (NULL) | ✅ (via MAX)             | ✅ (via IFNULL)                | ✅ (natural)              |
-- | 🧠 Readability              | Medium                  | Easy                          | Very clean               |
-- | 🔧 Extendable to Nth        | ✅ Best                  | ✅ Yes                         | ❌ Not easily             |

-- ---


-- # NULL Handling in SQL — Quick Reference

-- ## Two Different Problems
-- - **NULL value in a row** → `salary = NULL` (row exists, value is missing)
-- - **No row at all** → empty result set (query matched nothing)

-- > Most interview mistakes come from confusing these two.

-- ---

-- ## IFNULL / COALESCE → Fix values inside existing rows

-- ```sql
-- IFNULL(salary, 0)          -- MySQL only, 2 args
-- COALESCE(salary, bonus, 0) -- Standard SQL, multiple args
-- ```

-- ✅ Replaces NULL with a fallback **when a row exists**  
-- ❌ Cannot help when query returns **zero rows** — result stays empty

-- ---

-- ## MAX / MIN / COUNT → Work even on empty sets

-- ```sql
-- SELECT MAX(salary) FROM Employee WHERE salary < 100;
-- -- No matches? → returns one row with NULL (not empty)
-- ```

-- ✅ Aggregates **always return one row**, even on an empty set  
-- ✅ Naturally handles "no second highest" → returns NULL

-- ---

-- ## Decision Rule

-- | Situation | Use |
-- |---|---|
-- | Row exists, value might be NULL | `COALESCE` / `IFNULL` |
-- | Query might return no rows at all | `MAX()` or wrap in subquery |

-- ---

-- ## One-liner

-- > **IFNULL fixes values. MAX fixes absence.**