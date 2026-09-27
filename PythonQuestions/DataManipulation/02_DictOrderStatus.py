# Given a list of order event dictionaries (with order_id, status, and timestamp), 
# some out of order and some duplicates, write a function that returns the final status of each order.

# events = [
#     {"order_id": 101, "status": "placed",    "timestamp": "2024-01-01 09:00"},
#     {"order_id": 102, "status": "placed",    "timestamp": "2024-01-01 09:15"},
#     {"order_id": 101, "status": "shipped",   "timestamp": "2024-01-01 14:00"},
#     {"order_id": 101, "status": "placed",    "timestamp": "2024-01-01 09:00"},  # duplicate
#     {"order_id": 102, "status": "paid",      "timestamp": "2024-01-01 10:30"},
#     {"order_id": 101, "status": "paid",      "timestamp": "2024-01-01 11:00"},
#     {"order_id": 103, "status": "placed",    "timestamp": "2024-01-01 12:00"},
#     {"order_id": 102, "status": "cancelled", "timestamp": "2024-01-01 08:00"},  # out of order - earlier timestamp
#     {"order_id": 101, "status": "delivered",  "timestamp": "2024-01-01 18:00"},
#     {"order_id": 103, "status": "paid",      "timestamp": "2024-01-01 13:00"},
# ]
# Expected output should be the final (latest timestamp) status for each order:

# Order 101 → "delivered" (18:00)
# Order 102 → "paid" (10:30)
# Order 103 → "paid" (13:00)

events = [
    {"order_id": 101, "status": "placed",    "timestamp": "2024-01-01 09:00"},
    {"order_id": 102, "status": "placed",    "timestamp": "2024-01-01 09:15"},
    {"order_id": 101, "status": "shipped",   "timestamp": "2024-01-01 14:00"},
    {"order_id": 101, "status": "placed",    "timestamp": "2024-01-01 09:00"},  # duplicate
    {"order_id": 102, "status": "paid",      "timestamp": "2024-01-01 10:30"},
    {"order_id": 101, "status": "paid",      "timestamp": "2024-01-01 11:00"},
    {"order_id": 103, "status": "placed",    "timestamp": "2024-01-01 12:00"},
    {"order_id": 102, "status": "cancelled", "timestamp": "2024-01-01 08:00"},  # out of order - earlier timestamp
    {"order_id": 101, "status": "delivered",  "timestamp": "2024-01-01 18:00"},
    {"order_id": 103, "status": "paid",      "timestamp": "2024-01-01 13:00"},
]

output = {}
for event in events:
    if event['order_id'] not in output:
        output[event['order_id']] = event
    else:
        if event['timestamp'] > output[event['order_id']]['timestamp']:
            output[event['order_id']] = event

for k,val in output.items():
    print(f"Order {k} --> {val['status']} ({val['timestamp']}) ")

