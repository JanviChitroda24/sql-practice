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