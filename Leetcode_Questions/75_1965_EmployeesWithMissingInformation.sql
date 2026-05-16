-- 1965. Employees With Missing Information
-- https://leetcode.com/problems/employees-with-missing-information/description/

-- Table: Employees

-- +-------------+---------+
-- | Column Name | Type    |
-- +-------------+---------+
-- | employee_id | int     |
-- | name        | varchar |
-- +-------------+---------+
-- employee_id is the column with unique values for this table.
-- Each row of this table indicates the name of the employee whose ID is employee_id.
 

-- Table: Salaries

-- +-------------+---------+
-- | Column Name | Type    |
-- +-------------+---------+
-- | employee_id | int     |
-- | salary      | int     |
-- +-------------+---------+
-- employee_id is the column with unique values for this table.
-- Each row of this table indicates the salary of the employee whose ID is employee_id.
 

-- Write a solution to report the IDs of all the employees with missing information. The information of an employee is missing if:

-- The employee's name is missing, or
-- The employee's salary is missing.
-- Return the result table ordered by employee_id in ascending order.

-- The result format is in the following example.

 

-- Example 1:

-- Input: 
-- Employees table:
-- +-------------+----------+
-- | employee_id | name     |
-- +-------------+----------+
-- | 2           | Crew     |
-- | 4           | Haven    |
-- | 5           | Kristian |
-- +-------------+----------+
-- Salaries table:
-- +-------------+--------+
-- | employee_id | salary |
-- +-------------+--------+
-- | 5           | 76071  |
-- | 1           | 22517  |
-- | 4           | 63539  |
-- +-------------+--------+
-- Output: 
-- +-------------+
-- | employee_id |
-- +-------------+
-- | 1           |
-- | 2           |
-- +-------------+
-- Explanation: 
-- Employees 1, 2, 4, and 5 are working at this company.
-- The name of employee 1 is missing.
-- The salary of employee 2 is missing.

-- approach 1
WITH emp_miss_info AS (
    SELECT e.employee_id 
    FROM Employees e LEFT JOIN Salaries s
        ON e.employee_id = s.employee_id
    WHERE e.name IS NULL OR s.salary IS NULL
    UNION 
    SELECT s.employee_id 
    FROM Salaries s LEFT JOIN Employees e
        ON e.employee_id = s.employee_id
    WHERE s.salary IS NULL OR e.name IS NULL
)
SELECT * 
FROM emp_miss_info
ORDER BY employee_id;

-- not exists approach
WITH emp_miss_info AS (
    SELECT e.employee_id
    FROM Employees e
    WHERE NOT EXISTS (
        SELECT 1
        FROM Salaries s
        WHERE e.employee_id = s.employee_id
    )
    UNION
    SELECT s.employee_id
    FROM Salaries s
    WHERE NOT EXISTS (
        SELECT 1
        FROM Employees e
        WHERE e.employee_id = s.employee_id
    )
)
SELECT employee_id
FROM emp_miss_info
ORDER BY employee_id;


-- | Aspect | LEFT JOIN + UNION | NOT IN | NOT EXISTS |
-- |---|---|---|---|
-- | **How it works** | Joins ALL rows from both tables, builds full result set, then filters WHERE NULL | Materializes the full subquery result into a list, checks each row against it | For each row, peeks into other table — stops the moment it finds a match |
-- | **Memory** | Builds two full joined result sets before filtering | Holds entire subquery result list in memory | No intermediate result set needed |
-- | **Short-circuit** | No — must complete full join first | No — builds entire list first | Yes — stops after first match found |
-- | **Index usage** | Uses index for join but materializes all matched rows | May not leverage indexes effectively | Uses index for correlated lookup directly |
-- | **NULL safety** | ✅ Safe — NULL checks are explicit in WHERE | ❌ Breaks if subquery returns NULLs (entire result becomes empty) | ✅ Safe — NULL comparisons simply don't match |
-- | **Work done** | Joins every row → filters → UNION deduplicates | Builds two lists → checks membership | Peeks per row → short-circuits → UNION deduplicates |
-- | **Best case** | Small tables where join overhead is minimal | Small subquery results that fit in memory | Large tables where early termination saves work |
-- | **Worst case** | Large tables — lots of joined rows just to throw them away | NULLs in subquery silently return zero rows | Minimal difference from best case |

-- **Think of it as finding students absent from class:**

-- - **LEFT JOIN**: Take the full class roster, match every student with the attendance sheet, lay it all out on the table, then circle the ones with no match
-- - **NOT IN**: Write down every name on the attendance sheet first, then go through the roster checking "is this name on my list?"
-- - **NOT EXISTS**: Go through the roster one by one — for each name, peek at the attendance sheet. See them? Move on. Don't see them? Mark absent. Never need to build a full list.

-- **Bottom line:** NOT EXISTS is the best default — NULL-safe, short-circuits, index-friendly, and never worse than the others. NOT IN is fine here since `employee_id` is a primary key (never NULL), but building the habit of NOT EXISTS pays off in interviews and production.


-------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------


-- For NOT EXISTS in **this specific problem**, we're looking for rows that **DON'T exist** in the other table. So:

-- **When a match EXISTS (employee is in both tables):**
-- - Peek → find match on first index lookup → return TRUE → skip this row
-- - This is fast — one lookup, done

-- **When a match DOESN'T exist (employee is missing):**
-- - Peek → search the index → confirm nothing's there → return FALSE → include this row
-- - This is also just one index lookup — it checks the B-tree and finds nothing

-- The key insight is: with an index on `employee_id`, both "found" and "not found" are **O(log n)** — a single index lookup either way. It's not scanning row by row through the table. The B-tree tells you immediately whether the value exists or not.

-- **Where your concern WOULD be valid:** if there were **no index** and it had to do a full table scan for each outer row. Then yes, the worst case for "not found" means scanning every single row before concluding it's missing. That would be O(n) per outer row → O(n × m) total.

-- So the real answer is:

-- | Scenario | With Index | Without Index |
-- |---|---|---|
-- | Match found | O(log n) — one lookup | O(1) best, O(n) worst |
-- | Match NOT found | O(log n) — one lookup | O(n) — must scan everything |

-- **With an index, there's no meaningful best/worst difference because every lookup is O(log n).** That's what I meant by "minimal difference" — but I should have been clearer that this assumes an indexed column.


-------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------


-- | Aspect | LEFT JOIN | NOT IN | NOT EXISTS |
-- |---|---|---|---|
-- | | **With Index** | **Without Index** | **With Index** | **Without Index** | **With Index** | **Without Index** |
-- |---|---|---|---|---|---|---|
-- | **Match found** | O(log n) per row — index lookup for join | O(n) per row — full scan to find match | O(log n) per row — index lookup in list | O(n) per row — scan list until found | O(log n) per row — one index peek, stops | O(1) best, O(n) worst — scan until found, stops |
-- | **Match NOT found** | O(log n) per row — index confirms absence | O(n) per row — full scan to confirm | O(log n) per row — index confirms absence | O(n) per row — must scan entire list | O(log n) per row — one index peek, confirms | O(n) per row — must scan entire table |
-- | **Total (m outer rows, n inner rows)** | O(m log n) | O(m × n) | O(m log n) | O(m × n) | O(m log n) | O(m × n) worst |
-- | **Memory** | Builds full joined result set | Builds full joined result set | Holds entire subquery list in memory | Holds entire subquery list in memory | No intermediate result set | No intermediate result set |
-- | **Short-circuit** | ❌ Never — must complete full join | ❌ Never | ❌ Never — builds full list first | ❌ Never | ✅ Yes — stops on first match | ✅ Yes — stops on first match |
-- | **NULL safety** | ✅ Safe | ✅ Safe | ❌ Breaks if NULLs in subquery | ❌ Breaks if NULLs in subquery | ✅ Safe | ✅ Safe |
-- | **Best case per row** | O(log n) | O(n) | O(log n) | O(1) if first item matches | O(log n) | O(1) — first row is a match, stops |
-- | **Worst case per row** | O(log n) | O(n) | O(log n) | O(n) — scan full list | O(log n) | O(n) — scan full table, no match |

-- **Key takeaways:**

-- **1. With an index, all three perform similarly** — O(m log n). The index makes every lookup a B-tree search regardless of whether the value exists or not. The difference becomes memory and short-circuiting.

-- **2. Without an index, NOT EXISTS has an advantage for "match found" cases.** LEFT JOIN and NOT IN must process all rows regardless. NOT EXISTS stops the moment it finds a match — so if most employees exist in both tables, it skips them fast.

-- **3. Without an index, "match NOT found" is equally bad for everyone** — O(n) per row because you must scan the entire table to confirm something isn't there. No shortcut for proving absence without an index.

-- **4. The real differentiator isn't speed — it's safety and memory:**

-- | | LEFT JOIN | NOT IN | NOT EXISTS |
-- |---|---|---|---|
-- | **Speed** | 🟡 Same with index | 🟡 Same with index | 🟡 Same with index |
-- | **NULL safe** | ✅ | ❌ | ✅ |
-- | **Memory efficient** | ❌ | ❌ | ✅ |
-- | **Short-circuits** | ❌ | ❌ | ✅ |

-- **Bottom line:** With proper indexes, pick based on safety and readability — NOT EXISTS wins both. Without indexes, NOT EXISTS still wins because short-circuiting saves work on every matching row.