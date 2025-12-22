Problem Statement:
Identify users who have more than 5 failed login attempts within any 1-hour window. This helps detect potential security threats like brute-force attacks.
Schema:
sqlevents(user_id INT, event_type VARCHAR, ts TIMESTAMP)
```

**Sample Input:**
```
user_id | event_type   | ts
--------|--------------|--------------------
101     | failed_login | 2024-01-01 08:00:00
101     | failed_login | 2024-01-01 08:10:00
101     | failed_login | 2024-01-01 08:15:00
101     | failed_login | 2024-01-01 08:30:00
101     | failed_login | 2024-01-01 08:45:00
101     | failed_login | 2024-01-01 08:50:00
101     | login        | 2024-01-01 09:00:00
102     | failed_login | 2024-01-01 08:00:00
102     | failed_login | 2024-01-01 08:30:00
102     | failed_login | 2024-01-01 10:00:00
103     | failed_login | 2024-01-01 09:00:00
103     | failed_login | 2024-01-01 09:05:00
103     | failed_login | 2024-01-01 09:10:00
103     | failed_login | 2024-01-01 09:20:00
103     | failed_login | 2024-01-01 09:30:00
103     | failed_login | 2024-01-01 09:45:00
103     | failed_login | 2024-01-01 09:50:00
```

**Expected Output:**
```
user_id
--------
101
103
Explanation:

User 101: 6 failed logins between 08:00 and 08:50 (within 1 hour)
User 103: 7 failed logins between 09:00 and 09:50 (within 1 hour)
User 102: Only 3 failed logins total, never more than 5 in any 1-hour window

SELECT DISTINCT user_id
FROM (
    SELECT user_id, 
        COUNT(user_id) OVER(PARTITION BY user_id ORDER BY ts
        RANGE BETWEEN CURRENT ROW AND INTERVAL '1 hour' FOLLOWING) AS event_count
    FROM sqlevents
    WHERE event_type = 'failed_login'
)
WHERE event_count > 5;

-- ALWAYS ALIAS A WINDLOW FUNCTION