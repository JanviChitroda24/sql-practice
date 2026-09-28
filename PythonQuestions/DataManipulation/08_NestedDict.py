# Given a nested dictionary of arbitrary depth, 
#     flatten it so that keys become dot-separated paths (e.g., {"a": {"b": 1}} becomes {"a.b": 1}).

# Input:
data = {
    "user": {
        "id": 101,
        "name": "Alice",
        "address": {
            "city": "Boston",
            "state": "MA",
            "zip": {
                "code": "02101",
                "plus4": "1234"
            }
        }
    },
    "order": {
        "id": 501,
        "total": 250
    },
    "status": "active"
}

# # Expected output:
# {
#     "user.id": 101,
#     "user.name": "Alice",
#     "user.address.city": "Boston",
#     "user.address.state": "MA",
#     "user.address.zip.code": "02101",
#     "user.address.zip.plus4": "1234",
#     "order.id": 501,
#     "order.total": 250,
#     "status": "active"
# }


def recursive_flatten(d, parent_key='', sep='.'):
    output = {}
    for k,val in d.items():
        if parent_key:
            new_key = parent_key+sep+k
        else:
            new_key = k
        if isinstance(val,dict):
            output.update(recursive_flatten(val, new_key, '.'))
        else:
            output[new_key]=val
    return output

print(recursive_flatten(data, '', '.'))