Question 11: Compute Daily Retention
Problem Statement:
Calculate the day-over-day retention rate. For each day, determine what percentage of users who logged in on that day also logged in on the following day.
Schema:
sqlevents(user_id INT, event_type VARCHAR, ts TIMESTAMP)
```

**Sample Input:**
```
user_id | event_type | ts
--------|------------|--------------------
101     | login      | 2024-01-01 08:00:00
102     | login      | 2024-01-01 09:00:00
103     | login      | 2024-01-01 10:00:00
104     | login      | 2024-01-01 11:00:00
101     | login      | 2024-01-02 08:00:00
102     | login      | 2024-01-02 09:00:00
103     | login      | 2024-01-02 10:00:00
101     | login      | 2024-01-03 08:00:00
104     | login      | 2024-01-03 11:00:00
```

**Expected Output:**
```
day        | total_users | retained_users | retention_rate
-----------|-------------|----------------|---------------
2024-01-01 | 4           | 3              | 75.00
2024-01-02 | 3           | 1              | 33.33
Explanation:

2024-01-01: 4 users logged in (101, 102, 103, 104). Of these, 3 users (101, 102, 103) also logged in on 2024-01-02. Retention = 3/4 = 75%
2024-01-02: 3 users logged in (101, 102, 103). Of these, only 1 user (101) also logged in on 2024-01-03. Retention = 1/3 = 33.33%


SELECT DATE(ts) AS day, total_users, retained_users, rentention_rate
FROM (
    SELECT ts, 
    COUNT(user_id) OVER( PARTITION BY DATE(ts)) as total_users,
    LEAD(ts,1,0) OVER(PARTITION BY ts )
    WHERE event_type = 'login'
)