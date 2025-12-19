Question 8: Top 3 Users with Highest Event Count
Problem Statement:
Given a table of user events, identify the top 3 users who have generated the most events. If there are ties, include all users with the same count.
Schema:
sqlevents(user_id INT, event_type VARCHAR, ts TIMESTAMP)
```

**Sample Input:**
```
user_id | event_type | ts
--------|------------|--------------------
101     | login      | 2024-01-01 08:00:00
101     | click      | 2024-01-01 08:05:00
101     | logout     | 2024-01-01 09:00:00
102     | login      | 2024-01-01 08:30:00
102     | click      | 2024-01-01 08:35:00
103     | login      | 2024-01-01 09:00:00
103     | click      | 2024-01-01 09:05:00
103     | click      | 2024-01-01 09:10:00
103     | purchase   | 2024-01-01 09:15:00
103     | logout     | 2024-01-01 10:00:00
104     | login      | 2024-01-01 10:00:00
```

**Expected Output:**
```
user_id | event_count
--------|------------
103     | 5
101     | 3
102     | 2

SELECT DISTINCT user_id, event_count
FROM (
    SELECT user_id, COUNT(user_id) as event_count, 
            DENSE_RANK() OVER(ORDER BY COUNT(user_id) DESC) AS user_cnt
    FROM events
    GROUP BY user_id
)
WHERE user_cnt < 4;