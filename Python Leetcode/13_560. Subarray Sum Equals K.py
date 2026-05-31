# 560. Subarray Sum Equals K
# https://leetcode.com/problems/subarray-sum-equals-k/description/

# Given an array of integers nums and an integer k, return the total number of subarrays whose sum equals to k.

# A subarray is a contiguous non-empty sequence of elements within an array.

 

# Example 1:

# Input: nums = [1,1,1], k = 2
# Output: 2
# Example 2:

# Input: nums = [1,2,3], k = 3
# Output: 2
 

# Constraints:

# 1 <= nums.length <= 2 * 104
# -1000 <= nums[i] <= 1000
# -107 <= k <= 107

# two sum prolem -- basic solution
def subarraySum(self, nums: List[int], k: int) -> int:
    cnt = 0
    store = {0:1}
    running_total = [nums[0]]
    for ind in range(1,len(nums)):
        running_total.append(nums[ind]+running_total[ind-1])
    for ind,val in enumerate(running_total):
        check = val - k
        if check in store:
            cnt += store[check]
        if val in store:
            store[val] += 1
        else:
            store[val] = 1
    return cnt



# Pattern: Prefix Sum + Hash Map (variation of Two Sum)
# Core idea: Running total at position j minus running total at position i = sum of subarray between i and j. If that equals k, we found one.
# Algorithm:

# Initialize: store = {0: 1}, running_total = 0, cnt = 0
# For each number in array:

# Add number to running_total
# Calculate complement: running_total - k
# If complement exists in store → cnt += store[complement]
# Store running_total in dictionary (increment count if exists, else set to 1)


# Return cnt

# Example: nums = [1, 2, 3], k = 3
# store = {0: 1}, total = 0, cnt = 0

# num = 1:
#   total = 1
#   complement = 1 - 3 = -2
#   -2 in store? No
#   store = {0:1, 1:1}

# num = 2:
#   total = 3
#   complement = 3 - 3 = 0
#   0 in store? YES → cnt += 1 = 1
#   (subarray [1,2] sums to 3)
#   store = {0:1, 1:1, 3:1}

# num = 3:
#   total = 6
#   complement = 6 - 3 = 3
#   3 in store? YES → cnt += 1 = 2
#   (subarray [3] sums to 3)
#   store = {0:1, 1:1, 3:1, 6:1}

# return 2 ✓
# Three things to remember:

# Dictionary stores {running_total: times_seen}, NOT complements
# Look up complement, store running_total — they're different
# cnt += store[complement] not cnt += 1 — same total can appear multiple times

# Bank account analogy: "If my balance is $6 now and it was $3 before, I earned $3 in between. If it was $3 twice before, that's two different stretches where I earned $3."

# optimal solution
class Solution:
    def subarraySum(self, nums: List[int], k: int) -> int:
        cnt = 0
        running_total = 0
        store = {0:1}
        for val in nums:
            running_total += val
            check = running_total - k
            if check in store:
                cnt+=store[check]
            if running_total in store:
                store[running_total]+=1
            else:
                store[running_total]=1
        return cnt

# Before coding, write the algorithm in comments first:
# 1. init store with {0:1}, total = 0, cnt = 0
# 2. for each num: update total
# 3. check: is total - k in store? if yes, cnt += store[total-k]
# 4. store: add total to store
# 5. return cnt