-- 33

-- app_sessions
-- ├── session_id      INT (PK)
-- ├── user_id         INT
-- ├── start_time      DATETIME
-- ├── end_time        DATETIME
-- ├── app_version     VARCHAR(20)

-- Write a query that finds users who have downgraded their app 
--     — meaning they used a higher version in an earlier session and a lower version in a later session. 
--     Assume version strings follow semantic versioning (e.g. ‘2.1.0’, ‘2.10.3’). 
--     Return user_id, previous_version, new_version, downgrade_date. 
--     If a user downgraded multiple times, return all instances.

WITH prev_app_sessions AS (
    SELECT user_id, DATE_FORMAT(start_time, '%Y-%m-%d') AS user_date,
        app_version AS new_version, 
        LAG(app_version) OVER(PARTITION BY user_id ORDER BY start_time) AS previous_version
    FROM app_sessions
)
SELECT user_id, previous_version, new_version, user_date AS downgrade_date
FROM prev_app_sessions
WHERE new_version<previous_version; --assuming it will return correct comparison

-- WHERE 
--     CAST(SUBSTRING_INDEX(new_version, '.', 1) AS UNSIGNED) < CAST(SUBSTRING_INDEX(previous_version, '.', 1) AS UNSIGNED)
--     OR (
--         CAST(SUBSTRING_INDEX(new_version, '.', 1) AS UNSIGNED) = CAST(SUBSTRING_INDEX(previous_version, '.', 1) AS UNSIGNED)
--         AND CAST(SUBSTRING_INDEX(SUBSTRING_INDEX(new_version, '.', 2), '.', -1) AS UNSIGNED) < CAST(SUBSTRING_INDEX(SUBSTRING_INDEX(previous_version, '.', 2), '.', -1) AS UNSIGNED)
--     )
--     OR (
--         CAST(SUBSTRING_INDEX(new_version, '.', 1) AS UNSIGNED) = CAST(SUBSTRING_INDEX(previous_version, '.', 1) AS UNSIGNED)
--         AND CAST(SUBSTRING_INDEX(SUBSTRING_INDEX(new_version, '.', 2), '.', -1) AS UNSIGNED) = CAST(SUBSTRING_INDEX(SUBSTRING_INDEX(previous_version, '.', 2), '.', -1) AS UNSIGNED)
--         AND CAST(SUBSTRING_INDEX(new_version, '.', -1) AS UNSIGNED) < CAST(SUBSTRING_INDEX(previous_version, '.', -1) AS UNSIGNED)
--     )

-- the string comparison will not give correct out put since it will compare element by element using ascii value 
-- 2.1.0 < 2.10.0 will work since ascii value of (. is 46) and (0 is 48)
-- but it will fail in comparing 2.10.9 and 2.9.9 since the ascii value of 9 is greater than 1

-- how to solve this in python:
    -- l1 = [int(ele) for ele in '2.10.0'.split('.')]
    -- l2 = [int(ele) for ele in '2.9.0'.split('.')]
    -- then we can direclty compare the two list

