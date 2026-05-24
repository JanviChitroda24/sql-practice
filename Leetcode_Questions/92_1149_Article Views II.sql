-- 1149. Article Views II
-- https://leetcode.ca/all/1149.html

-- 1149. Article Views II
-- Table: Views

-- +---------------+---------+
-- | Column Name   | Type    |
-- +---------------+---------+
-- | article_id    | int     |
-- | author_id     | int     |
-- | viewer_id     | int     |
-- | view_date     | date    |
-- +---------------+---------+
-- There is no primary key for this table, it may have duplicate rows.
-- Each row of this table indicates that some viewer viewed an article (written by some author) on some date.
-- Note that equal author_id and viewer_id indicate the same person.


-- Write an SQL query to find all the people who viewed more than one article on the same date, sorted in ascending order by their id.Programming

-- The query result format is in the following example:

-- Views table:
-- +------------+-----------+-----------+------------+
-- | article_id | author_id | viewer_id | view_date  |
-- +------------+-----------+-----------+------------+
-- | 1          | 3         | 5         | 2019-08-01 |
-- | 3          | 4         | 5         | 2019-08-01 |
-- | 1          | 3         | 6         | 2019-08-02 |
-- | 2          | 7         | 7         | 2019-08-01 |
-- | 2          | 7         | 6         | 2019-08-02 |
-- | 4          | 7         | 1         | 2019-07-22 |
-- | 3          | 4         | 4         | 2019-07-21 |
-- | 3          | 4         | 4         | 2019-07-21 |
-- +------------+-----------+-----------+------------+

-- Result table:
-- +------+
-- | id   |
-- +------+
-- | 5    |
-- | 6    |
-- +------+

WITH dedup_views AS (
    SELECT article_id, viewer_id, view_date 
    FROM Views
    GROUP BY article_id, viewer_id, view_date 
), view_count AS (
    SELECT viewer_id, view_date, COUNT(article_id) AS article_count
    FROM dedup_views
    GROUP BY viewer_id, view_date
)
SELECT DISTINCT viewer_id AS id
FROM view_count
WHERE article_count > 1
ORDER BY id;

--- USING SINCLE CTE
WITH dedup_views AS (
    SELECT article_id, viewer_id, view_date 
    FROM Views
    GROUP BY article_id, viewer_id, view_date 
)
SELECT  DISTINCT viewer_id AS id
FROM dedup_views
GROUP BY viewer_id, view_date 
HAVING COUNT(article_id) > 1
ORDER BY id;