-- 1767 - Find the Subtasks That Did Not Execute
-- https://leetcode.ca/2021-04-19-1767-Find-the-Subtasks-That-Did-Not-Execute/

-- Hard

-- Description

-- Table: Tasks
-- +----------------+---------+
-- | Column Name    | Type    |
-- +----------------+---------+
-- | task_id        | int     |
-- | subtasks_count | int     |
-- +----------------+---------+
-- task_id is the primary key for this table.
-- Each row in this table indicates that task_id was divided into subtasks_count subtasks labelled from 1 to subtasks_count.
-- It is guaranteed that 2 <= subtasks_count <= 20.

-- Table: Executed
-- +---------------+---------+
-- | Column Name   | Type    |
-- +---------------+---------+
-- | task_id       | int     |
-- | subtask_id    | int     |
-- +---------------+---------+
-- (task_id, subtask_id) is the primary key for this table.
-- Each row in this table indicates that for the task task_id, the subtask with ID subtask_id was executed successfully.
-- It is guaranteed that subtask_id <= subtasks_count for each task_id.
-- Write an SQL query to report the IDs of the missing subtasks for each task_id.


-- Return the result table in any order.

-- The query result format is in the following example:Programming

-- Tasks table:
-- +---------+----------------+
-- | task_id | subtasks_count |
-- +---------+----------------+
-- | 1       | 3              |
-- | 2       | 2              |
-- | 3       | 4              |
-- +---------+----------------+

-- Executed table:
-- +---------+------------+
-- | task_id | subtask_id |
-- +---------+------------+
-- | 1       | 2          |
-- | 3       | 1          |
-- | 3       | 2          |
-- | 3       | 3          |
-- | 3       | 4          |
-- +---------+------------+

-- Result table:
-- +---------+------------+
-- | task_id | subtask_id |
-- +---------+------------+
-- | 1       | 1          |
-- | 1       | 3          |
-- | 2       | 1          |
-- | 2       | 2          |
-- +---------+------------+
-- Task 1 was divided into 3 subtasks (1, 2, 3). Only subtask 2 was executed successfully, so we include (1, 1) and (1, 3) in the answer.
-- Task 2 was divided into 2 subtasks (1, 2). No subtask was executed successfully, so we include (2, 1) and (2, 2) in the answer.
-- Task 3 was divided into 4 subtasks (1, 2, 3, 4). All of the subtasks were executed successfully.

WITH RECURSIVE subtask_nos AS (
    SELECT task_id, subtasks_count, 1 AS subtask_id
    FROM Tasks
    UNION ALL 
    SELECT task_id, subtasks_count, subtask_id+1
    FROM subtask_nos
    WHERE subtask_id<subtasks_count
)
SELECT s.task_id, s.subtask_id
FROM subtask_nos s LEFT JOIN Executed e
    ON s.task_id = e.task_id AND s.subtask_id = e.subtask_id
WHERE e.subtask_id IS NULL;

-- One thing to be aware of:
-- The constraint says subtasks_count <= 20, so the recursion depth is shallow and this will always perform fine. 
-- If subtasks_count were unbounded (say thousands), recursive CTEs can get expensive compared to a numbers table 
-- or a pre-generated series. 
-- Worth mentioning in an interview if asked about scalability, but for this problem it's a non-issue.

-- alternative not exists solution
WITH RECURSIVE subtask_nos AS (
    SELECT task_id, subtasks_count, 1 AS subtask_id
    FROM Tasks
    UNION ALL 
    SELECT task_id, subtasks_count, subtask_id+1
    FROM subtask_nos
    WHERE subtask_id<subtasks_count
)
SELECT s.task_id, s.subtask_id
FROM subtask_nos s 
WHERE NOT EXISTS (
    SELECT 1 
    FROM Executed e
    WHERE s.task_id = e.task_id 
        AND s.subtask_id = e.subtask_id 
);

For this specific problem (small data, `subtasks_count <= 20`), 
    all three perform nearly identically. But here's how they differ in general:

**LEFT JOIN + WHERE NULL** — 
    The join builds a combined result set, then filters out matches. 
    On large datasets this can use more memory since it materializes the full join before filtering. 
    However, most modern optimizers recognize this pattern and convert it internally to an anti-join, 
        making it equivalent to NOT EXISTS.

**NOT EXISTS** — 
    Evaluates the subquery per row and short-circuits as soon as it finds a match (stops scanning early). 
    This makes it slightly better when the `Executed` table is large and matches are found quickly. 
    It also handles NULLs safely, unlike NOT IN.

**NOT IN** — 
    The subquery runs once and builds a list, then each row is checked against it. 
    The major downside: if any value in the subquery result is NULL, 
    the entire NOT IN evaluates to UNKNOWN and returns zero rows — a silent, hard-to-debug failure. 
    Performance-wise, for large subquery results, the lookup list can get expensive.

**Practical ranking for interviews:**

1. **NOT EXISTS** — safest, NULL-proof, short-circuits, universally recommended
2. **LEFT JOIN + WHERE NULL** — equally safe, most readable, often optimizer-equivalent to NOT EXISTS
3. **NOT IN** — works fine when you're certain there are no NULLs, but risky as a default habit

For this problem specifically, it genuinely doesn't matter — pick whichever you're most comfortable explaining.