-- 608. Tree Node
-- https://leetcode.com/problems/tree-node/description/
-- SQL Schema
-- Pandas Schema
-- Table: Tree

-- +-------------+------+
-- | Column Name | Type |
-- +-------------+------+
-- | id          | int  |
-- | p_id        | int  |
-- +-------------+------+
-- id is the column with unique values for this table.
-- Each row of this table contains information about the id of a node and the id of its parent node in a tree.
-- The given structure is always a valid tree.
 

-- Each node in the tree can be one of three types:

-- "Leaf": if the node is a leaf node.
-- "Root": if the node is the root of the tree.
-- "Inner": If the node is neither a leaf node nor a root node.
-- Write a solution to report the type of each node in the tree.

-- Return the result table in any order.

-- The result format is in the following example.

 

-- Example 1:


-- Input: 
-- Tree table:
-- +----+------+
-- | id | p_id |
-- +----+------+
-- | 1  | null |
-- | 2  | 1    |
-- | 3  | 1    |
-- | 4  | 2    |
-- | 5  | 2    |
-- +----+------+
-- Output: 
-- +----+-------+
-- | id | type  |
-- +----+-------+
-- | 1  | Root  |
-- | 2  | Inner |
-- | 3  | Leaf  |
-- | 4  | Leaf  |
-- | 5  | Leaf  |
-- +----+-------+
-- Explanation: 
-- Node 1 is the root node because its parent node is null and it has child nodes 2 and 3.
-- Node 2 is an inner node because it has parent node 1 and child node 4 and 5.
-- Nodes 3, 4, and 5 are leaf nodes because they have parent nodes and they do not have child nodes.
-- Example 2:


-- Input: 
-- Tree table:
-- +----+------+
-- | id | p_id |
-- +----+------+
-- | 1  | null |
-- +----+------+
-- Output: 
-- +----+-------+
-- | id | type  |
-- +----+-------+
-- | 1  | Root  |
-- +----+-------+
-- Explanation: If there is only one node on the tree, you only need to output its root attributes.

SELECT id, 
    CASE 
        WHEN p_id IS NULL
        THEN 'Root'
        WHEN id IN (SELECT p_id FROM Tree)
        THEN 'Inner'
        ELSE 'Leaf'
    END AS type
FROM Tree;

-- approach 2: using exist for checking id
SELECT id,
    CASE 
    WHEN p_id is NULL THEN 'Root'
    WHEN EXISTS(
        SELECT 1
        FROM Tree t2
        WHERE t1.id = t2.p_id
    ) THEN 'Inner'
    ELSE 'Leaf'
    END AS type
FROM Tree t1;

-- approach 3: join with distinct p_id
SELECT t1.id,
    CASE 
        WHEN t1.p_id IS NULL THEN 'Root'
        WHEN t2.p_id IS NOT NULL tHEN 'Inner'
        ELSE 'Leaf'
    END AS type
FROM Tree t1 
    LEFT JOIN (
        SELECT DISTINCT p_id
        FROM Tree
        WHERE p_id IS NOT NULL
    ) t2
    ON t1.id = t2.p_id;


-- Both solutions are correct. 
    -- One thing to note: your IN approach has a potential NULL issue — 
    -- `SELECT p_id FROM Tree` will include NULL values (the root's p_id). 
    -- It works here because `IN` with NULL is safe (as you learned earlier), 
    -- but adding `WHERE p_id IS NOT NULL` makes it explicit 
    --     and slightly faster since the subquery returns fewer rows.

-- | Factor | Approach 1 (IN) | Approach 2 (EXISTS) |
-- |---|---|---|
-- | Table scans | 2 (main + subquery) | 2 (main + correlated) |
-- | Subquery execution | Once (builds full list) | Once per row (correlated) |
-- | NULL risk | Safe but includes NULLs in list | Safe (JOIN condition skips NULLs) |
-- | Index usage | Good if p_id indexed | Better (stops at first match) |
-- | Small table | Both equal | Both equal |
-- | Large table | Slower (full list comparison) | Faster (short-circuits) |
-- | Readability | Simpler | Slightly more verbose |

-- **Bottom line:** EXISTS is the stronger interview answer — 
    -- it short-circuits (stops as soon as one child is found), 
    -- handles NULLs naturally, and scales better. 
    -- IN is fine for small tables and quicker to write.

-- There's also a third approach using LEFT JOIN if you want to show range:

-- ```sql
-- SELECT t1.id,
--     CASE
--         WHEN t1.p_id IS NULL THEN 'Root'
--         WHEN t2.id IS NOT NULL THEN 'Inner'
--         ELSE 'Leaf'
--     END AS type
-- FROM Tree t1
-- LEFT JOIN (SELECT DISTINCT p_id AS id FROM Tree WHERE p_id IS NOT NULL) t2
-- ON t1.id = t2.id;
-- ```

-- This avoids repeated subquery execution entirely — single join, no correlation. Worth mentioning in interviews as the "production" approach.

-- IN approach: 
--     For every row in the main table, SQL compares the id against the entire list 
--         built by the subquery. 
--     If there are 1M rows, that's 1M list lookups. 
--     The list itself sits in memory the whole time.

-- EXISTS approach: 
--     For every row in the main table, SQL runs the correlated subquery. 
--     Yes it short-circuits on first match, but it still initiates a subquery execution per row. 
--     On 1M rows, that's up to 1M subquery calls.

-- LEFT JOIN approach: 
--     The optimizer builds a hash table from the small DISTINCT subquery (unique parent ids) once. 
--     Then it scans the main table once and does O(1) hash lookups per row. 
--     Two scans total, no repeated execution, no list comparison.

-- So the key difference is: 
--     IN and EXISTS both do per-row work against the subquery. 
--     LEFT JOIN does the heavy lifting once upfront and then just looks things up.