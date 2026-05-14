-- 1978. Employees Whose Manager Left the Company

-- Table: Employees

-- +-------------+----------+
-- | Column Name | Type     |
-- +-------------+----------+
-- | employee_id | int      |
-- | name        | varchar  |
-- | manager_id  | int      |
-- | salary      | int      |
-- +-------------+----------+
-- In SQL, employee_id is the primary key for this table.
-- This table contains information about the employees, their salary, and the ID of their manager. Some employees do not have a manager (manager_id is null). 
 

-- Find the IDs of the employees whose salary is strictly less than $30000 and whose manager left the company. When a manager leaves the company, their information is deleted from the Employees table, but the reports still have their manager_id set to the manager that left.

-- Return the result table ordered by employee_id.

-- The result format is in the following example.

 

-- Example 1:

-- Input:  
-- Employees table:
-- +-------------+-----------+------------+--------+
-- | employee_id | name      | manager_id | salary |
-- +-------------+-----------+------------+--------+
-- | 3           | Mila      | 9          | 60301  |
-- | 12          | Antonella | null       | 31000  |
-- | 13          | Emery     | null       | 67084  |
-- | 1           | Kalel     | 11         | 21241  |
-- | 9           | Mikaela   | null       | 50937  |
-- | 11          | Joziah    | 6          | 28485  |
-- +-------------+-----------+------------+--------+
-- Output: 
-- +-------------+
-- | employee_id |
-- +-------------+
-- | 11          |
-- +-------------+

-- Explanation: 
-- The employees with a salary less than $30000 are 1 (Kalel) and 11 (Joziah).
-- Kalel's manager is employee 11, who is still in the company (Joziah).
-- Joziah's manager is employee 6, who left the company because there is no row for employee 6 as it was deleted.

-- USING NOT IN
SELECT employee_id
FROM Employees 
WHERE salary<30000 AND manager_id IS NOT NULL AND
    manager_id NOT IN (
        SELECT employee_id
        FROM Employees
    )
ORDER BY employee_id;


-- USING NOT EXIST
SELECT e.employee_id
FROM Employees e
WHERE salary<30000 AND manager_id IS NOT NULL AND
    NOT EXISTS (
        SELECT 1
        FROM Employees m
        WHERE e.manager_id = m.employee_id
    )
ORDER BY e.employee_id;

-- Here's a comparison across the key dimensions:

-- | Aspect | NOT IN | NOT EXISTS |
-- |---|---|---|
-- | **NULL Safety** | Breaks if subquery returns NULLs — entire result becomes empty | NULL-safe, handles NULLs gracefully |
-- | **Execution** | Materializes the full subquery result into a list, then checks each row against it | Short-circuits — stops scanning as soon as a match is found |
-- | **Best Case** | Small subquery result sets that fit in memory | Large tables where early termination saves work |
-- | **Index Usage** | May not leverage indexes effectively on the subquery | Can use an index on `e2.employee_id` for the correlated lookup |
-- | **Readability** | More intuitive, reads like English | Slightly more verbose but signals intent clearly |
-- | **Memory** | Holds entire subquery result in memory | No intermediate result set needed |
-- | **Modern Optimizers** | MySQL 8+ often rewrites NOT IN as a semi-join internally | Already in optimal form for the optimizer |
-- | **Interview Preference** | Fine for quick solutions | Shows deeper SQL knowledge — interviewers tend to prefer it |

-- **Bottom line:** For LeetCode, either works. For production or interviews at data-heavy companies, default to `NOT EXISTS` — it's safer and never worse in performance.

-- Let's walk through it step by step.

-- Say your `Employees` table has these `employee_id` values: `1, 2, NULL, 4`

-- And you run:

-- ```mysql
-- WHERE manager_id NOT IN (SELECT employee_id FROM Employees)
-- ```

-- For a row where `manager_id = 5`, SQL internally expands this to:

-- ```
-- 5 != 1 AND 5 != 2 AND 5 != NULL AND 5 != 4
-- ```

-- Now here's the problem — `5 != NULL` doesn't return TRUE or FALSE. In SQL, **any comparison with NULL returns UNKNOWN**. So it becomes:

-- ```
-- TRUE AND TRUE AND UNKNOWN AND TRUE → UNKNOWN
-- ```

-- Since the overall result is UNKNOWN (not TRUE), the row gets **excluded** from your results. Even though `5` clearly isn't in the table as a real employee, the presence of that one NULL poisoned the entire check.

-- This happens for **every row** you're checking — no `manager_id` will ever pass the `NOT IN` filter because that NULL in the subquery makes every comparison resolve to UNKNOWN.

-- **Result: zero rows returned.** Your query silently gives you an empty table with no error.

-- With `NOT EXISTS`, this doesn't happen because it's not doing an equality comparison against a list. It's asking "does a matching row exist?" — and a row where `employee_id IS NULL` simply won't match `e2.employee_id = e1.manager_id` (since `NULL = 5` is UNKNOWN, not TRUE), so it's skipped. The other valid rows still get checked normally, and the query works as expected.