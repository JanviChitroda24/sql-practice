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

SELECT DISTINCT t1.id, 
    CASE 
        WHEN t1.p_id IS NULL
        THEN 'Root'
        WHEN t2.p_id IS NOT NULL
        THEN 'Inner'
        ELSE 'Leaf'
    END AS 'type'
FROM Tree t1 LEFT JOIN Tree t2
    ON t1.id = t2.p_id;

-- the missing DISTINCT here is a good one to internalize as a checklist item 
--     specifically for self-joins: 
--         any time you self-join on a one-to-many relationship 
--         (one parent, multiple children/matches), 
--         ask yourself whether the "one" side needs deduplicating in the final output. 
--     It's an easy thing to miss because the query runs fine 
--         and even gives correct-looking data for the rows that don't have that fan-out 
--         — like your Leaf nodes here, which were correct in your very first draft. 
--     It's only the multi-child rows that expose the bug, 
--         which is exactly why it's easy to miss during a quick self-check.


-- Let's build it step by step so you can see exactly what the raw `LEFT JOIN` produces, 
    -- before any `CASE` or `DISTINCT` touches it.

-- **The data:**
-- ```
-- Tree:
-- id | p_id
-- 1  | null
-- 2  | 1
-- 3  | 1
-- 4  | 2
-- 5  | 2
-- ```

-- **The join:** `FROM Tree t1 LEFT JOIN Tree t2 ON t1.id = t2.p_id`

-- For every row in `t1`, MySQL looks for **every** row in `t2` whose `p_id` matches `t1.id`. If there are multiple matches, you get multiple output rows — one per match. If there are zero matches, `LEFT JOIN` still keeps `t1`'s row, but fills all of `t2`'s columns with `NULL`.

-- Here's the raw result, row by row:

-- | t1.id | t1.p_id | t2.id | t2.p_id | why |
-- |---|---|---|---|---|
-- | 1 | null | 2 | 1 | t2 row (id=2,p_id=1) matches, since p_id=1=t1.id |
-- | 1 | null | 3 | 1 | t2 row (id=3,p_id=1) *also* matches — same t1.id, second match |
-- | 2 | 1 | 4 | 2 | t2 row (id=4,p_id=2) matches |
-- | 2 | 1 | 5 | 2 | t2 row (id=5,p_id=2) *also* matches — second match again |
-- | 3 | 1 | null | null | nothing in Tree has p_id=3, so no match → LEFT JOIN fills nulls |
-- | 4 | 2 | null | null | nothing has p_id=4 → no match |
-- | 5 | 2 | null | null | nothing has p_id=5 → no match |

-- **That's 7 rows total** — even though the original table only has 5 rows. Notice:
-- - `t1.id=1` appears **twice** (rows 1 and 2), because node 1 has two children (2 and 3), so it gets matched twice.
-- - `t1.id=2` appears **twice** (rows 3 and 4), same reason — node 2 has two children (4 and 5).
-- - `t1.id=3,4,5` each appear **once**, because they have zero children — `LEFT JOIN` still keeps them (that's the whole point of `LEFT` vs `INNER`), just with `t2` columns as `NULL`.

-- Now when you apply your `CASE` to each of these 7 rows, `t1.id=1` computes `'Root'` twice (once per row) and `t1.id=2` computes `'Inner'` twice — that's exactly where your duplicates were coming from. `DISTINCT` then looks at the final `(id, type)` pairs and collapses `(1,Root)+(1,Root)` into a single `(1,Root)`, and same for `(2,Inner)`.

-- Does seeing the actual 7-row intermediate table make the fan-out clearer?