# You have a list of (timestamp, value) tuples. 
# Write a function that computes a rolling average over a window of N entries.

data = [
    ("2024-01-01 09:00", 10),
    ("2024-01-01 09:05", 20),
    ("2024-01-01 09:10", 30),
    ("2024-01-01 09:15", 40),
    ("2024-01-01 09:20", 50),
    ("2024-01-01 09:25", 60),
]

window = 3

# Expected output (rolling average with window of 3):
# "2024-01-01 09:00" → 10.0        (only 1 value, avg of [10])
# "2024-01-01 09:05" → 15.0        (only 2 values, avg of [10,20])
# "2024-01-01 09:10" → 20.0        (avg of [10, 20, 30])
# "2024-01-01 09:15" → 30.0        (avg of [20, 30, 40])
# "2024-01-01 09:20" → 40.0        (avg of [30, 40, 50])
# "2024-01-01 09:25" → 50.0        (avg of [40, 50, 60])


### solution
result = []
n = len(data)
if n>=1:
    result.append((data[0][0], float(data[0][1])))
if n>=2:
    result.append((data[1][0], (data[0][1]+data[1][1])/2))
if n>3:
    for i in range(2,n):
        summ = sum([data[i-2][1],data[i-1][1], data[i][1]])
        result.append((data[i][0], summ/3 ))
print(result)

# generalized solution for variable window
result = []
n = len(data)
if n<window:
    i=0
    while i!=n:
        j = 0
        summ = 0
        while j!=i:
            summ += data[j][0]
            j+=1
        result.append((data[i][0], summ/i))
        i+=1
else:
    for i in range(0,window):
        summ = 0
        nsumm=0
        for j in range(0,i+1):
            summ += data[j][1]
            nsumm+=1
        result.append((data[i][0], summ/nsumm))
    for i in range(window,n):
        summ = 0
        for j in range(i-window+1,i+1):
            summ += data[j][1]
        result.append((data[i][0], summ/window))
print(result)

# most optimized solution 
# we dont need separate cases for the cases of start it all will be taken care by fixing the start position
# the start will be max(0,i-window+1) since for inital elements we get negative index then we start with 0
# and for division we always divide by the numberof elements upto that point 

def rolling_avg(data,window):
    n = len(data)
    if n==0:
        return []
    result = []
    for i in range(0,n):
        start = max(0,i-window+1)
        sub_array = [ data[j][1] for j in range(start,i+1) ]
        roll_avg = sum(sub_array)/len(sub_array)
        result.append((data[i][0], roll_avg))
    return result

print(rolling_avg(data, window))