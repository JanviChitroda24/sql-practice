-- 1917 - Leetcodify Friends Recommendations
-- https://leetcode.ca/2021-08-01-1917-Leetcodify-Friends-Recommendations/

-- 1917. Leetcodify Friends Recommendations
-- Level
-- Hard

-- Description

-- Table: Listens
-- +-------------+---------+
-- | Column Name | Type    |
-- +-------------+---------+
-- | user_id     | int     |
-- | song_id     | int     |
-- | day         | date    |
-- +-------------+---------+
-- There is no primary key for this table. It may contain duplicates.
-- Each row of this table indicates that the user user_id listened to the song song_id on the day day.

-- Table: Friendship

-- +---------------+---------+
-- | Column Name   | Type    |
-- +---------------+---------+
-- | user1_id      | int     |
-- | user2_id      | int     |
-- +---------------+---------+
-- (user1_id, user2_id) is the primary key for this table.
-- Each row of this table indicates that the users user1_id and user2_id are friends.
-- Note that user1_id < user2_id.

-- Write an SQL query to recommend friends to Leetcodify users. We recommend user x to user y if:
-- Users x and y are not friends, and
-- Users x and y listened to the same three or more different songs on the same day.
-- Note that friend recommendations are unidirectional, meaning if user x and user y should be recommended to each other, the result table should have both user x recommended to user y and user y recommended to user x. Also, note that the result table should not contain duplicates (i.e., user y should not be recommended to user x multiple times.).Programming


-- Return the result table in any order.

-- The query result format is in the following example:

-- Listens table:
-- +---------+---------+------------+
-- | user_id | song_id | day        |
-- +---------+---------+------------+
-- | 1       | 10      | 2021-03-15 |
-- | 1       | 11      | 2021-03-15 |
-- | 1       | 12      | 2021-03-15 |
-- | 2       | 10      | 2021-03-15 |
-- | 2       | 11      | 2021-03-15 |
-- | 2       | 12      | 2021-03-15 |
-- | 3       | 10      | 2021-03-15 |
-- | 3       | 11      | 2021-03-15 |
-- | 3       | 12      | 2021-03-15 |
-- | 4       | 10      | 2021-03-15 |
-- | 4       | 11      | 2021-03-15 |
-- | 4       | 13      | 2021-03-15 |
-- | 5       | 10      | 2021-03-16 |
-- | 5       | 11      | 2021-03-16 |
-- | 5       | 12      | 2021-03-16 |
-- +---------+---------+------------+

-- Friendship table:
-- +----------+----------+
-- | user1_id | user2_id |
-- +----------+----------+
-- | 1        | 2        |
-- +----------+----------+

-- Result table:
-- +---------+----------------+
-- | user_id | recommended_id |
-- +---------+----------------+
-- | 1       | 3              |
-- | 2       | 3              |
-- | 3       | 1              |
-- | 3       | 2              |
-- +---------+----------------+
-- Users 1 and 2 listened to songs 10, 11, and 12 on the same day, but they are already friends.
-- Users 1 and 3 listened to songs 10, 11, and 12 on the same day. Since they are not friends, we recommend them to each other.
-- Users 1 and 4 did not listen to the same three songs.
-- Users 1 and 5 listened to songs 10, 11, and 12, but on different days.

-- Similarly, we can see that users 2 and 3 listened to songs 10, 11, and 12 on the same day and are not friends, so we recommend them to each other.

WITH dedup_listens AS (
    SELECT user_id, song_id, day 
    FROM Listens
    GROUP BY user_id, song_id, day 
), 
user_pairs AS(
    SELECT l1.user_id AS user1, l1.day AS day1, 
            l2.user_id AS user2, l2.day AS day2,
            COUNT(l1.song_id) OVER(PARTITION BY l1.day, l1.user_id, l2.user_id) AS dist_songs
    FROM dedup_listens l1 JOIN dedup_listens l2 
    ON l1.user_id != l2.user_id AND l1.day = L2.day AND L1.song_id = L2.song_id
),
user_friend AS (
    SELECT user1, user2
    FROM user_pairs
    WHERE dist_songs >=3
)
SELECT DISTINCT uf.user1 AS user_id, uf.user2 AS recommended_id
FROM user_friend uf LEFT JOIN Friendship f
    ON (uf.user1 = f.user1_id AND uf.user2 = f.user2_id) 
        OR 
        (uf.user2 = f.user1_id AND uf.user1 = f.user2_id)
WHERE f.user1_id IS NULL AND f.user2_id IS NULL;

-- **Bi-directional Friendship Check**

-- Friendship table stores `user1_id < user2_id`, so only (1,2) exists, not (2,1).

-- **Without OR:** checking `user1=f.user1_id AND user2=f.user2_id`
-- - Pair (1,2) → matches (1,2) ✓ filtered out
-- - Pair (2,1) → no match ✗ **slips through as "not friends" — WRONG!**

-- **With OR:** also checking `user1=f.user2_id AND user2=f.user1_id`
-- - Pair (1,2) → first condition matches (1,2) ✓ filtered out
-- - Pair (2,1) → second condition flips to (1,2) ✓ filtered out

-- **Rule:** When a relationship table enforces ordering (user1 < user2), always check both directions when matching pairs against it.

-- optimize solution by using having and removing the window function
WITH dedup_listens AS (
    SELECT user_id, song_id, day 
    FROM Listens
    GROUP BY user_id, song_id, day 
), 
user_pairs AS(
    SELECT l1.user_id AS user1, l2.user_id AS user2, l2.day AS day2
    FROM dedup_listens l1 JOIN dedup_listens l2 
        ON l1.user_id != l2.user_id AND l1.day = L2.day AND L1.song_id = L2.song_id
    GROUP BY l1.user_id, l2.user_id, l2.day
    HAVING COUNT(l1.song_id) >= 3
)
SELECT DISTINCT up.user1 AS user_id, up.user2 AS recommended_id
FROM user_pairs up LEFT JOIN Friendship f
    ON (up.user1 = f.user1_id AND up.user2 = f.user2_id) 
        OR 
        (up.user2 = f.user1_id AND up.user1 = f.user2_id)
WHERE f.user1_id IS NULL AND f.user2_id IS NULL;

-- 1. MySQL doesn't support COUNT(DISTINCT) in window functions
-- COUNT(DISTINCT column) OVER(...) is not valid in MySQL. 
-- So if you need distinct counts, you have two options: 
--     deduplicate the data first so COUNT() naturally gives distinct counts, 
--     or use GROUP BY + HAVING instead of window functions. 
-- This is why deduplication was a necessary first step in this problem.

-- From the 1917 problem you learned:

-- **1. Deduplicate before joining**
-- When a table says "no primary key, may contain duplicates," always deduplicate first with GROUP BY. Otherwise duplicate rows inflate your counts.

-- **2. GROUP BY + HAVING > Window Functions for pair counting**
-- Instead of using `COUNT() OVER(PARTITION BY ...)` and then filtering, use GROUP BY with HAVING COUNT >= 3. Simpler, more efficient, and avoids the "COUNT DISTINCT not supported in window functions" issue.

-- **3. Bi-directional Friendship Check**
-- When a relationship table enforces ordering (user1 < user2), always check both directions when matching pairs:
-- ```sql
-- ON (uf.user1 = f.user1_id AND uf.user2 = f.user2_id)
-- OR (uf.user1 = f.user2_id AND uf.user2 = f.user1_id)
-- ```
-- Without this, reversed pairs slip through as "not friends."

-- **4. DISTINCT at the end**
-- When pairs could match on multiple days, add SELECT DISTINCT to avoid duplicate recommendations in the output.