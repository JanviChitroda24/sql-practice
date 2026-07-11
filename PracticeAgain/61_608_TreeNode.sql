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

