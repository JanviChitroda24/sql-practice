# Given a list of dictionaries representing user sessions with user_id, login_time, and logout_time, 
# find users with overlapping sessions.

sessions = [
    {"user_id": 1, "login_time": "2024-01-01 09:00", "logout_time": "2024-01-01 10:30"},
    {"user_id": 1, "login_time": "2024-01-01 10:00", "logout_time": "2024-01-01 11:00"},
    {"user_id": 2, "login_time": "2024-01-01 09:00", "logout_time": "2024-01-01 09:45"},
    {"user_id": 2, "login_time": "2024-01-01 10:00", "logout_time": "2024-01-01 11:00"},
    {"user_id": 3, "login_time": "2024-01-01 14:00", "logout_time": "2024-01-01 15:00"},
    {"user_id": 3, "login_time": "2024-01-01 14:30", "logout_time": "2024-01-01 16:00"},
    {"user_id": 1, "login_time": "2024-01-01 13:00", "logout_time": "2024-01-01 14:00"},
]

# Expected output:
# User 1 — sessions 1 and 2 overlap (09:00-10:30 overlaps with 10:00-11:00)
# User 2 — no overlap (09:00-09:45 ends before 10:00-11:00 starts)
# User 3 — sessions overlap (14:00-15:00 overlaps with 14:30-16:00)
# User 1's third session (13:00-14:00) doesn't overlap with the other two

# output:
# {
#     1: [(session1, session2), (session1, session3)],
#     3: [(session6, session7)],
# }

users = {}
for session in sessions:
    if session['user_id'] not in users:
        users[session['user_id']] = [session]
    else:
         users[session['user_id']].append(session)
print(users)

ans = []
for u_id, u_list in users.items():
    for i in range(len(u_list)):
        for j in range(i+1, len(u_list)):
            if u_list[i]['logout_time'] > u_list[j]['login_time'] and u_list[j]['logout_time'] > u_list[i]['login_time'] :
                ans.append([u_id, u_list[i], u_list[j]])

print(ans)
