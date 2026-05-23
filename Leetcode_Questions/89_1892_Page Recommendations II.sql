-- 1892. Page Recommendations II
-- https://leetcode.ca/2021-07-25-1892-Page-Recommendations-II/

-- Description
-- Table: Friendship

-- +---------------+---------+
-- | Column Name   | Type    |
-- +---------------+---------+
-- | user1_id      | int     |
-- | user2_id      | int     |
-- +---------------+---------+
-- (user1_id, user2_id) is the primary key for this table.
-- Each row of this table indicates that the users user1_id and user2_id are friends.
-- Table: Likes

-- +-------------+---------+
-- | Column Name | Type    |
-- +-------------+---------+
-- | user_id     | int     |
-- | page_id     | int     |
-- +-------------+---------+
-- (user_id, page_id) is the primary key for this table.
-- Each row of this table indicates that user_id likes page_id.
-- You are implementing a page recommendation system for a social media website. Your system will recommend a page to user_id if the page is liked by at least one friend of user_id and is not liked by user_id.


-- Write an SQL query to find all the possible page recommendations for every user. Each recommendation should appear as a row in the result table with these columns:Programming

-- user_id: The ID of the user that your system is making the recommendation to.
-- page_id: The ID of the page that will be recommended to user_id.
-- friends_likes: The number of the friends of user_id that like page_id.
-- Return result table in any order.

-- The query result format is in the following example:

-- Friendship table:
-- +----------+----------+
-- | user1_id | user2_id |
-- +----------+----------+
-- | 1        | 2        |
-- | 1        | 3        |
-- | 1        | 4        |
-- | 2        | 3        |
-- | 2        | 4        |
-- | 2        | 5        |
-- | 6        | 1        |
-- +----------+----------+
 
-- Likes table:
-- +---------+---------+
-- | user_id | page_id |
-- +---------+---------+
-- | 1       | 88      |
-- | 2       | 23      |
-- | 3       | 24      |
-- | 4       | 56      |
-- | 5       | 11      |
-- | 6       | 33      |
-- | 2       | 77      |
-- | 3       | 77      |
-- | 6       | 88      |
-- +---------+---------+

-- Result table:
-- +---------+---------+---------------+
-- | user_id | page_id | friends_likes |
-- +---------+---------+---------------+
-- | 1       | 77      | 2             |
-- | 1       | 23      | 1             |
-- | 1       | 24      | 1             |
-- | 1       | 56      | 1             |
-- | 1       | 33      | 1             |
-- | 2       | 24      | 1             |
-- | 2       | 56      | 1             |
-- | 2       | 11      | 1             |
-- | 2       | 88      | 1             |
-- | 3       | 88      | 1             |
-- | 3       | 23      | 1             |
-- | 4       | 88      | 1             |
-- | 4       | 77      | 1             |
-- | 4       | 23      | 1             |
-- | 5       | 77      | 1             |
-- | 5       | 23      | 1             |
-- +---------+---------+---------------+
-- Take user 1 as an example:
--   - User 1 is friends with users 2, 3, 4, and 6.
--   - Recommended pages are 23 (user 2 liked it), 24 (user 3 liked it), 56 (user 3 liked it), 33 (user 6 liked it), and 77 (user 2 and user 3 liked it).
--   - Note that page 88 is not recommended because user 1 already liked it.

-- Another example is user 6:
--   - User 6 is friends with user 1.
--   - User 1 only liked page 88, but user 6 already liked it. Hence, user 6 has no recommendations.

-- You can recommend pages for users 2, 3, 4, and 5 using a similar process.


-- NOT IN CONDIDTION 
WITH bi_dir_friendship AS (
    SELECT user1_id AS user_id, user2_id AS frnd_id
    FROM Friendship
    UNION ALL 
    SELECT user2_id AS user_id, user1_id AS frnd_id
    FROM Friendship
)
SELECT f.user_id, l.page_id,
    COUNT(*) AS friends_likes
FROM bi_dir_friendship f JOIN Likes l
    ON f.frnd_id = l.user_id
WHERE (f.user_id, l.page_id) NOT IN (
    SELECT user_id, page_id
    FROM Likes
)
GROUP BY f.user_id, l.page_id
ORDER BY f.user_id, friends_likes;

-- NOT EXIST CONDITION
WITH bi_dir_friendship AS (
    SELECT user1_id AS user_id, user2_id AS frnd_id
    FROM Friendship
    UNION ALL
    SELECT user2_id AS user_id, user1_id AS frnd_id
    FROM Friendship
)
SELECT f.user_id, l.page_id, 
    COUNT(*) AS friends_likes
FROM bi_dir_friendship f JOIN Likes l 
    ON f.frnd_id = l.user_id
WHERE NOT EXISTS (
    SELECT 1 
    FROM Likes l2
    WHERE f.user_id = l2.user_id AND l.page_id = l2.page_id
)
GROUP BY f.user_id, l.page_id
ORDER BY f.user_id, l.page_id;

-- JOIN condition 
WITH bi_friends AS (
    SELECT user1_id AS user_id, user2_id AS frnd_id FROM Friendship
    UNION ALL
    SELECT user2_id AS user_id, user1_id AS frnd_id FROM Friendship
)
SELECT bf.user_id, l.page_id, COUNT(*) AS friends_likes
FROM bi_friends bf 
JOIN Likes l ON bf.frnd_id = l.user_id
LEFT JOIN Likes l2 ON bf.user_id = l2.user_id AND l.page_id = l2.page_id
WHERE l2.user_id IS NULL
GROUP BY bf.user_id, l.page_id;

-- **LEFT JOIN + IS NULL** 
--     — Best. Single pass join, optimizer can use indexes on both conditions. 
--     Most efficient for large datasets because it processes everything in one operation 
--     without repeated subquery execution.

-- **NOT EXISTS** 
--     — Close second. Correlated subquery but short-circuits on first match. 
--     Very efficient with proper indexes. 
--     Some optimizers convert this to the same plan as LEFT JOIN.

-- **NOT IN** 
--     — Worst. Builds the entire subquery result set in memory, 
--     then checks each row against it. 
--     Dangerous with NULLs — if any value in the subquery is NULL, 
--         the entire NOT IN returns no rows. Also can't short-circuit.

-- **Rule of thumb for "exclude matching rows":**
-- - **LEFT JOIN + IS NULL** → safest and most performant, use as default
-- - **NOT EXISTS** → equally good, more readable for some people
-- - **NOT IN** → only use when you're certain there are no NULLs and the subquery is small

-- Here's what you learned today:

-- **1. Bi-directional Friendship Tables**
-- When a relationship table stores `user1_id < user2_id`, 
--     UNION ALL both directions to get every user's friends. 
--     Without this, you miss half the friendships.

-- **3. Tuple NOT IN**
--     You can check multiple columns together: `WHERE (col1, col2) NOT IN (SELECT col1, col2 FROM ...)`. 
--     Useful but remember the NULL risk.
