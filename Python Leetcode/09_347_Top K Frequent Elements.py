# 347. Top K Frequent Elements
# https://leetcode.com/problems/top-k-frequent-elements/description/

# Given an integer array nums and an integer k, return the k most frequent elements. You may return the answer in any order.

# Example 1:
# Input: nums = [1,1,1,2,2,3], k = 2
# Output: [1,2]

# Example 2:
# Input: nums = [1], k = 1
# Output: [1]

# Example 3:
# Input: nums = [1,2,1,2,1,2,3,1,3,2], k = 2
# Output: [1,2]

 

# Constraints:

# 1 <= nums.length <= 105
# -104 <= nums[i] <= 104
# k is in the range [1, the number of unique elements in the array].
# It is guaranteed that the answer is unique.
 

# Follow up: Your algorithm's time complexity must be better than O(n log n), where n is the array's size.

class Solution:
    def topKFrequent(self, nums: List[int], k: int) -> List[int]:
        d = {}
        for ele in nums:
            if ele in d:
                d[ele] += 1
            else:
                d[ele] = 1
        sorted_d = sorted(d.items(), key=lambda x:x[1], reverse=True)
        output = []
        for i in range(k):
            output.append(sorted_d[i][0])
        return output

# **Sorting a Dictionary by Values — Reference**

# ---

# **Problem:** Dictionaries have no built-in sort method. You need to convert and sort.

# **Step 1: Convert to list of tuples**
# ```python
# freq = {1: 3, 2: 2, 3: 1}
# freq.items() → [(1, 3), (2, 2), (3, 1)]
# ```

# **Step 2: Sort with `sorted()`**
# ```python
# sorted(freq.items())
# ```
# By default: sorts by first element of each tuple, ascending.

# **Step 3: Custom sort key with `lambda`**
# ```python
# sorted(freq.items(), key=lambda x: x[1])
# ```
# `lambda x: x[1]` = "for each tuple x, sort by the second element"
# - `x[0]` = key
# - `x[1]` = value

# **Step 4: Descending order**
# ```python
# sorted(freq.items(), key=lambda x: x[1], reverse=True)
# ```
# Highest value first.

# **Lambda is just a one-line function:**
# ```python
# lambda x: x[1]
# # same as:
# def get_value(x):
#     return x[1]
# ```

# **Full pattern:**
# ```python
# freq = {1: 3, 2: 2, 3: 1}
# sorted_freq = sorted(freq.items(), key=lambda x: x[1], reverse=True)
# # result: [(1, 3), (2, 2), (3, 1)]
# ```

# optimized --> o(n) approach
def topKFrequent(self, nums: List[int], k: int) -> List[int]:
    d = {}
    for ele in nums:
        if ele in d:
            d[ele] += 1
        else:
            d[ele] = 1

    d_list = d.items()
    max_freq = max(d.values())
    bucket = [[] for _ in range(max_freq+1)]
    for [key, freq] in d_list:
        bucket[freq].append(key)

    result = []
    for ind in range(len(bucket)-1, -1, -1):
        for num in bucket[ind]:
            result.append(num)
            if len(result) == k:
                return result


# **Key notes for revision:**

# **Top K Frequent pattern:**
# - Count frequencies with a dictionary
# - Use bucket sort: index = frequency, value = list of elements with that frequency
# - Walk buckets from right to left, collect until you have k elements

# **Three approaches to "Top K" problems:**
# - Sort by frequency: O(n log n)
# - Heap: O(n log k)
# - Bucket sort: O(n) — best, works when frequency has a bounded range

# **Useful Python shortcuts:**
# - `d.items()` → list of (key, value) tuples
# - `d.values()` → all values
# - `sorted(d.items(), key=lambda x: x[1], reverse=True)` → sort dict by value descending
# - `[[] for _ in range(n)]` → list of n empty lists