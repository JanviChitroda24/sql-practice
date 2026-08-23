# https://leetcode.com/problems/subarray-sum-equals-k/description/

# 560. Subarray Sum Equals K
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

class Solution(object):
    def subarraySum(self, nums, k):
        d = {0:1}
        answer = 0
        runsum=0
        for num in nums:
            runsum+=num
            if runsum-k in d:
                answer+=d[runsum-k]
            if runsum in d:
                d[runsum]+=1
            else:
                d[runsum]=1
        return answer


def run():
    sol = Solution()

    print(sol.subarraySum([1, 1, 1], 2))
    print(sol.subarraySum([1, 2, 3], 3))


if __name__ == "__main__":
    run()

# python PreparationQuestions/07_560_SubarraySumK.py

# Sliding window won't work here because the array can contain negatives, 
#     which breaks monotonicity. 
# Instead I use prefix sums — any subarray's sum equals the difference of two prefix sums, 
#     so finding subarrays summing to k means finding prefix pairs that differ by k. 
# I walk the array once, maintaining a running sum and a hashmap of prefix sum to frequency. 
# At each index I look up current sum minus k in the map and add that count to my answer, 
# then store the current sum. That's O(n) time and O(n) space.