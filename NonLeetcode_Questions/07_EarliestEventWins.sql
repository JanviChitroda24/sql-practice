Question 12: Deduplicate Events (Earliest Event Wins)
Problem Statement:
When multiple events exist with the same user_id and event_type, keep only the event with the earliest timestamp. Remove all duplicate events.
Schema:
sqlevents(user_id INT, event_type VARCHAR, ts TIMESTAMP)
```

**Sample Input:**
```
user_id | event_type | ts
--------|------------|--------------------
101     | login      | 2024-01-01 08:00:00
101     | login      | 2024-01-01 09:00:00
101     | click      | 2024-01-01 08:30:00
102     | login      | 2024-01-01 10:00:00
102     | purchase   | 2024-01-01 10:30:00
102     | purchase   | 2024-01-01 11:00:00
103     | login      | 2024-01-01 07:00:00
103     | login      | 2024-01-01 07:30:00
103     | login      | 2024-01-01 08:00:00
```

**Expected Output:**
```
user_id | event_type | ts
--------|------------|--------------------
101     | click      | 2024-01-01 08:30:00
101     | login      | 2024-01-01 08:00:00
102     | login      | 2024-01-01 10:00:00
102     | purchase   | 2024-01-01 10:30:00
103     | login      | 2024-01-01 07:00:00
Explanation:

User 101 had 2 login events → kept earliest at 08:00:00
User 102 had 2 purchase events → kept earliest at 10:30:00
User 103 had 3 login events → kept earliest at 07:00:00