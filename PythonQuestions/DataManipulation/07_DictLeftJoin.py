# Write a function that takes two lists of dictionaries (like two tables) 
# and performs a left join on a shared key, returning the merged result.

# Table 1: Orders
orders = [
    {"order_id": 101, "customer_id": 1, "amount": 250},
    {"order_id": 102, "customer_id": 2, "amount": 150},
    {"order_id": 103, "customer_id": 3, "amount": 300},
    {"order_id": 104, "customer_id": 4, "amount": 500},
]

# Table 2: Customers
customers = [
    {"customer_id": 1, "name": "Alice", "city": "Boston"},
    {"customer_id": 2, "name": "Bob", "city": "NYC"},
    {"customer_id": 3, "name": "Charlie", "city": "Chicago"},
]

# Left join: orders LEFT JOIN customers ON customer_id
# Expected output:
# [
#     {"order_id": 101, "customer_id": 1, "amount": 250, "name": "Alice", "city": "Boston"},
#     {"order_id": 102, "customer_id": 2, "amount": 150, "name": "Bob", "city": "NYC"},
#     {"order_id": 103, "customer_id": 3, "amount": 300, "name": "Charlie", "city": "Chicago"},
#     {"order_id": 104, "customer_id": 4, "amount": 500, "name": None, "city": None},
# ]

import copy
result = copy.deepcopy(orders)

# this is of O(m*n) time complexity and fixed schema for left and right
for ind, order in enumerate(orders):
    for customer in customers:
        if customer['customer_id'] == order['customer_id']:
            result[ind].update({'name':customer.get('name'), 'city':customer.get('city')})
    if not result[ind].get('name'):
        result[ind].update({'name':None, 'city':None})

print(result)

# optimized version with O(m+n) complexity and generalized
def left_join(left, right, key_col):

    result = []

    lookup = {}
    for row in right:
        lookup.update({row[key_col]: row})
    
    # one line dict comprehension
    # lookup = {row[key_col]: row for row in right}
    print(lookup)

    for row in left:
        merge = copy.deepcopy(row)
        match = lookup.get(merge[key_col])
        print(match, type(match))
        if match:
            for k,val in match.items():
                if k not in merge:
                    merge.update({k:val})
        else:
            if right:
                for k in right[0].keys():
                    if k not in merge:
                        merge.update({k:None})
        result.append(merge)
    return result
print(left_join(orders, customers, 'customer_id'))


print("optimized version with O(m+n) complexity and generalized")
# optimized version with O(m+n) complexity and generalized
def optimized_left_join(left, right, key_col):
    result = []

    lookup = {}
    for d in right:
        lookup[d[key_col]] = d
    print(lookup)

    for row in left:
        merged_row = copy.deepcopy(row)
        match = lookup.get(merged_row[key_col])
        if match:
            for k,val in match.items():
                if k != key_col:
                    merged_row[k] = val
        else:
            if right:
                for k in right[0].keys():
                    if k != key_col:
                        merged_row[k] = None
        result.append(merged_row)
    return result

print(optimized_left_join(orders, customers, 'customer_id'))
