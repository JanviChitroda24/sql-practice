-- A client runs a subscription fitness app and wants to understand engagement. 

-- We have a table of workout activity:
-- user_activity(user_id, activity_date, workout_type, duration_min)

-- For each user, find their longest streak of consecutive days with at least one workout. 
-- Return the user_id, the streak length in days, and the start and end dates of that streak.

-- The client says a single rest day shouldn't break a streak. 
-- Workouts on Monday, Tuesday, Thursday, and Friday should count as one streak. 
-- How would you change your approach?

-- we need to do lag approach in order to identify gaps (create new day_since_prev col) 
-- and then we do flag (new_streak) where day_since_prev <= 2 will be 0 rest will be 1
-- then we do a running sum of gap_flag since consecutive days new_streak will be 0 and it will give streak_id

WITH user_activity_dedup AS (
    SELECT user_id, activity_date
    FROM user_activity
    GROUP BY user_id, activity_date
),
user_activity_prev_day AS (
    SELECT user_id, activity_date,
        LAG(activity_date) OVER(PARTITION BY user_id ORDER BY activity_date) AS activity_prev_date
    FROM user_activity_dedup
),
user_activity_prev_day_no AS (
    SELECT user_id, activity_date,
        DATEDIFF(activity_date, activity_prev_date) AS day_since_prev
    FROM user_activity_prev_day
),
user_activity_flag AS (
    SELECT user_id, activity_date, 
        CASE 
            WHEN day_since_prev>2 THEN 1
            ELSE 0
        END AS new_day_flag
    FROM user_activity_prev_day_no
),
user_activity_running_streak AS (
    SELECT user_id, activity_date, 
        SUM(new_day_flag) OVER(PARTITION BY user_id ORDER BY activity_date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS streak_id
    FROM user_activity_flag
),
user_activity_all_streaks AS (
    SELECT user_id, 
        COUNT(*) AS streak_length,
        MIN(activity_date) AS streak_start_day,
        MAX(activity_date) AS streak_end_day
    FROM user_activity_running_streak
    GROUP BY user_id, streak_id
),
user_activity_streak_rank AS (
    SELECT user_id, streak_length, streak_start_day, streak_end_day,
        ROW_NUMBER() OVER(PARTITION BY user_id ORDER BY streak_length DESC, streak_end_day DESC) AS streak_rnk
    FROM user_activity_all_streaks
)
SELECT user_id, streak_length, streak_start_day, streak_end_day
FROM user_activity_streak_rank
WHERE streak_rnk=1;
