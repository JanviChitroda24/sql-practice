# Write a function to deduplicate a list 
# while preserving the original order.

lst = [1, 3, 5, 3, 1, 7, 5, 9]
# Output: [1, 3, 5, 7, 9]

# We can remove duplicates by converting list to set but in set the original order is not preserved!
# so we cannot do list(set(lst))
d = {}
for ele in lst:
    if d.get(ele) is None:
        d[ele] = 1
    else:
        d[ele]+=1
print(list(d.keys()))

# using set() comparison
seen = set()
op = []
for ele in lst:
    if ele not in seen:
        seen.add(ele)
        op.append(ele)
print(op)

# Note: None can be a key in dictionary!!