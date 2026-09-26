# data = [
#     {"id": 1, "timestamp": "2024-01-01 10:00", "value": "A"},
#     {"id": 2, "timestamp": "2024-01-01 11:00", "value": "B"},
#     {"id": 3, "timestamp": "2024-01-01 12:00", "value": "C"},
#     {"id": 1, "timestamp": "2024-01-01 09:00", "value": "D"},
#     {"id": 2, "timestamp": "2024-01-01 12:00", "value": "C"},
#     {"id": 1, "timestamp": "2024-01-01 03:00", "value": "D"},
# ]

# here the output should be in same format 
# just htat we want the latest timestampt for each id.. just the lastest timestamp


data = [
    {"id": 1, "timestamp": "2024-01-01 10:00", "value": "A"},
    {"id": 2, "timestamp": "2024-01-01 11:00", "value": "B"},
    {"id": 3, "timestamp": "2024-01-01 12:00", "value": "C"},
    {"id": 1, "timestamp": "2024-01-01 09:00", "value": "D"},
    {"id": 2, "timestamp": "2024-01-01 12:00", "value": "C"},
    {"id": 1, "timestamp": "2024-01-01 03:00", "value": "D"},
]


output = []
op = {}
for d in data:
    rec_id = d.get('id')
    if op.get(rec_id):
        if op[rec_id]['timestamp'] < d['timestamp']:
            op[rec_id] = d
    else:
        op[rec_id] = d

print(list(op.values()))

