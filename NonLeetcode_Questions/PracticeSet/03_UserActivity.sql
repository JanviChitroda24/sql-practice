-- A client runs a subscription fitness app and wants to understand engagement. 

-- We have a table of workout activity:
-- user_activity(user_id, activity_date, workout_type, duration_min)

-- For each user, find their longest streak of consecutive days with at least one workout. 
-- Return the user_id, the streak length in days, and the start and end dates of that streak.

WITH user_activity_dedup AS (
    SELECT user_id, activity_date
    FROM user_activity
    GROUP BY user_id, activity_date
),
user_activity_rank AS(
    SELECT user_id, activity_date,
        ROW_NUMBER() OVER(PARTITION BY user_id ORDER BY activity_date) AS user_act_rnk
    FROM user_activity_dedup
),
user_activity_diff AS (
    SELECT user_id, activity_date, DATE_SUB(activity_date, INTERVAL user_act_rnk DAY) AS act_date_grp
    FROM user_activity_rank
),
user_activity_all_streaks AS(
    SELECT user_id, 
        COUNT(*) AS streaK_length, 
        MIN(activity_date) AS streak_start_day, 
        MAX(activity_date) AS streak_end_day
    FROM user_activity_diff
    GROUP BY user_id, act_date_grp
), 
user_activity_streak_rank AS (
    SELECT user_id, streaK_length, streak_start_day, streak_end_day,
        ROW_NUMBER() OVER(PARTITION BY user_id ORDER BY streaK_length DESC, streak_end_day DESC) AS streak_rnk
    FROM user_activity_all_streaks
)
SELECT user_id, streaK_length, streak_start_day, streak_end_day
FROM user_activity_streak_rank
WHERE streak_rnk = 1;