Problem Statement:
Given 30 days of login data (2024-01-01 to 2024-01-30), find all users who logged in at least once on each of the 30 days.
Schema:
sqlevents(user_id INT, event_type VARCHAR, ts TIMESTAMP)
```

**Sample Input:**
```
user_id | event_type | ts
--------|------------|--------------------
101     | login      | 2024-01-01 08:00:00
101     | login      | 2024-01-02 09:00:00
101     | click      | 2024-01-02 09:05:00
...     | ...        | ... (101 logs in all 30 days)
102     | login      | 2024-01-01 10:00:00
102     | login      | 2024-01-02 11:00:00
...     | ...        | ... (102 logs in only 28 days)
103     | login      | 2024-01-01 07:00:00
103     | login      | 2024-01-02 07:30:00
...     | ...        | ... (103 logs in all 30 days)
```

**Expected Output:**
```
user_id
--------
101
103
Explanation: Only users 101 and 103 have at least one login event on each of the 30 days. User 102 missed 2 days.


-------------------

SELECT user_id
FROM (
    SELECT user_id, COUNT(DISTINCT DATE(ts)) as user_id_count_distinct_days
    FROM sqlevents
    GROUP BY user_id
    WHERE event_type = 'login' AND  ts >= '2024-01-01' AND  ts <= '2024-01-30'
)
WHERE user_id_count_distinct_days = 30;

-- why it is important to do distinct: if we dont do that 
-- then a user might login to 30 times same day and have the count as 30 
-- that is why is it important to count distinct day where the user has logged in