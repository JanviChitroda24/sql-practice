# 560 Subarray Sum Equals K

# Given an array of integers nums and an integer k, 
#     return the total number of subarrays whose sum equals to k.
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

from typing import List


class Solution:
    def subarraySumBruteForce(self, nums: List[int], k: int) -> int:
        cnt = 0 
        n = len(nums)
        for ind in range(n):
            running_sum=0
            for j in range(ind,n):
                running_sum+=nums[j]
                if running_sum == k:
                    cnt+=1
        return cnt

    def subarraySum(self, nums: List[int], k: int) -> int:
        cnt=0
        seen_sum = {0:1}
        running_sum=0
        for ind in range(len(nums)):
            running_sum+=nums[ind]
            prev_sum = running_sum-k

            if prev_sum in seen_sum:
                cnt += seen_sum[prev_sum]
        
            if running_sum in seen_sum:
                seen_sum[running_sum] += 1
            else:
                seen_sum[running_sum] = 1
                
        return cnt


def run():
    sol = Solution()
    cases = [
        ([1, 1, 1], 2),
        ([1, 2, 3], 3),
    ]

    for nums, k in cases:
        print(f"Input: nums = {nums}, k = {k}")
        print("subarraySumBruteForce:", sol.subarraySumBruteForce(nums, k))
        print("subarraySum:", sol.subarraySum(nums, k))
        print()


if __name__ == "__main__":
    run()

# The brute force is to check every start and end, which is O(n²). 
#     I can do better with prefix sums.

# The idea is that the sum of any subarray is the 
#     running sum now minus the running sum just before the subarray starts. 
#     If I want that to equal k, then the earlier running sum has to be running_sum − k. 
#     I call that prev_sum.

# So as I walk through the array, 
#     I keep a dictionary of every running sum I’ve seen and how many times.
#     At each number, I update the running sum and check how many times I’ve seen prev_sum. 
#     Each of those is a different starting point for a subarray that ends here and sums to k, so I add that count.

# Then I record the current running sum. 
#     I check before I record so a position never pairs with itself.

# I seed the dictionary with {0: 1} so subarrays starting at index 0 get counted.

# That’s O(n) time and O(n) space. 
#     Sliding window doesn’t work here because negative numbers mean the sum doesn’t move in one direction as the window grows.”

# Why counts and not just a set: 
#     “The same running sum can appear more than once, 
#     especially with zeros or negatives, and each time is a separate starting point.”