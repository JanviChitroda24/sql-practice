-- You have a table called page_views:

-- page_views
-- ├── view_id         INT (PK)
-- ├── user_id         INT
-- ├── page_url        VARCHAR(255)
-- ├── view_timestamp  DATETIME
-- ├── device_type     VARCHAR(20)

-- Write a query that finds the most common three-page navigation path for each device type. 
-- A path is three consecutive page views by the same user ordered by timestamp. 
-- For example, if a user visits Home → Products → Cart, that's one path. 
-- Return device_type, page1, page2, page3, and path_count. 
-- Only include paths that occurred at least 10 times.

WITH page_paths AS (
    SELECT user_id, device_type, page_url AS page1,
        LEAD(page_url,1) OVER(PARTITION BY user_id ORDER BY view_timestamp) AS page2,
        LEAD(page_url,2) OVER(PARTITION BY user_id ORDER BY view_timestamp) AS page3
    FROM page_views
),
page_rank AS (
    SELECT device_type, page1, page2, page3, COUNT(*) AS path_count, 
        DENSE_RANK() OVER(PARTITION BY device_type ORDER BY COUNT(*) DESC) AS rnk
    FROM page_paths
    WHERE page2 IS NOT NULL AND page3 IS NOT NULL
    GROUP BY device_type, page1, page2, page3
    HAVING COUNT(*)>=10
)
SELECT device_type, page1, page2, page3, path_count
FROM page_rank
WHERE rnk=1;