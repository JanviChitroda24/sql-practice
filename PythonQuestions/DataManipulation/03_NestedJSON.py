# Parse a large JSON log file with nested structures 
#     and extract specific fields into a flat list of dictionaries 
#     — without loading the entire file into memory at once.

# {"event_id": "e001", "timestamp": "2024-01-01 09:00", "user": {"id": 101, "name": "Alice", "location": {"city": "Boston", "state": "MA"}}, "action": {"type": "login", "details": {"device": "mobile", "os": "iOS"}}}
# {"event_id": "e002", "timestamp": "2024-01-01 09:05", "user": {"id": 102, "name": "Bob", "location": {"city": "NYC", "state": "NY"}}, "action": {"type": "purchase", "details": {"device": "desktop", "os": "Windows"}}}
# {"event_id": "e003", "timestamp": "2024-01-01 09:10", "user": {"id": 101, "name": "Alice", "location": {"city": "Boston", "state": "MA"}}, "action": {"type": "logout", "details": {"device": "mobile", "os": "iOS"}}}
# {"event_id": "e004", "timestamp": "2024-01-01 09:15", "user": {"id": 103, "name": "Charlie", "location": {"city": "Chicago", "state": "IL"}}, "action": {"type": "purchase", "details": {"device": "tablet", "os": "Android"}}}
# {"event_id": "e005", "timestamp": "2024-01-01 09:20", "user": {"id": 102, "name": "Bob", "location": {"city": "NYC", "state": "NY"}}, "action": {"type": "login", "details": {"device": "desktop", "os": "Windows"}}}

# Your goal: extract a flat list of dicts like this:
# [
#     {"event_id": "e001", "timestamp": "2024-01-01 09:00", "user_id": 101, "city": "Boston", "action_type": "login", "device": "mobile"},
#     {"event_id": "e002", "timestamp": "2024-01-01 09:05", "user_id": 102, "city": "NYC", "action_type": "purchase", "device": "desktop"},
#     ...
# ]

import json

# One level flattening 

# with open('./InputData/03_data.jsonl', 'r') as f:
#     l = []
#     for line in f:
#         data = json.loads(line.strip())
#         new_data = {}
#         for k,val in data.items():
#             if not isinstance(val,dict):
#                 new_data[k] = val
#             else:
#                 for val_k,val_val in val.items():
#                     new_key = str(k)+"_"+str(val_k)
#                     new_data[new_key] = val_val
#         l.append(new_data)
# print(l)

def recursive_flatten(data, parent_key='', sep='_'):
    output = {}
    for k,val in data.items():
        if parent_key:
            new_key = parent_key+sep+k
        else:
            new_key = k
        if isinstance(val,dict):
            output.update(recursive_flatten(val, new_key, '_'))
        else:
            output[new_key] = val
    return output

with open('./InputData/03_data.jsonl', 'r') as f:
    l = []
    for line in f:
        data = json.loads(line.strip())
        l.append(recursive_flatten(data,'','_'))
    print(l)