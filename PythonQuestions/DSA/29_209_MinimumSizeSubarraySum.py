# 12. 209 Minimum Size Subarray Sum

# Given an array of positive integers nums and a positive integer target, 
#     return the minimal length of a subarray whose sum is greater than or equal to target. 
# If there is no such subarray, return 0 instead.

 

# Example 1:

# Input: target = 7, nums = [2,3,1,2,4,3]
# Output: 2
# Explanation: The subarray [4,3] has the minimal length under the problem constraint.
# Example 2:

# Input: target = 4, nums = [1,4,4]
# Output: 1
# Example 3:

# Input: target = 11, nums = [1,1,1,1,1,1,1,1]
# Output: 0
 

# Constraints:

# 1 <= target <= 109
# 1 <= nums.length <= 105
# 1 <= nums[i] <= 104
 

# Follow up: If you have figured out the O(n) solution, 
#     try coding another solution of which the time complexity is O(n log(n)).

class Solution:
    def minSubArrayLenBruteForce(self, target: int, nums: list[int]) -> int:
        min_subarray_length = float('inf')
        left = 0 
        right = 0
        subarray_sum=0
        subarray_cnt = 0
        n = len(nums)
        while left < len(nums):
            if right < n:
                subarray_sum+=nums[right]
                subarray_cnt += 1
                if subarray_sum >= target:
                    min_subarray_length = min(min_subarray_length, subarray_cnt)
                    subarray_sum=0
                    subarray_cnt=0
                    left+=1
                    right=left
                else:
                    right+=1
            else:
                subarray_sum=0
                subarray_cnt=0
                left+=1
                right=left
        if min_subarray_length != float('inf'):
            return min_subarray_length
        else:
            return 0

    def minSubArrayLen_01(self, target: int, nums: list[int]) -> int:
        left = 0 
        right = 0
        n = len(nums)
        min_subarray_cnt = float('inf')
        subarray_sum = 0
        subarray_cnt = 0 
        while left < n and right < n:
            subarray_sum += nums[right]
            subarray_cnt += 1
            
            if subarray_sum >= target:
                min_subarray_cnt = min(min_subarray_cnt, subarray_cnt)
                subarray_sum = subarray_sum - nums[left] - nums[right]
                subarray_cnt = subarray_cnt - 2
                left += 1
            else:
                right += 1
        
        if min_subarray_cnt == float('inf'):
            return 0
        else: 
            return min_subarray_cnt

    def minSubArrayLen_02(self, target: int, nums: list[int]) -> int:
        left = 0 
        right = 0
        n = len(nums)
        min_subarray_cnt = float('inf')
        subarray_sum = 0
        subarray_cnt = 0 
        while left < n and right < n:
            subarray_sum += nums[right]
            subarray_cnt += 1
            
            if subarray_sum >= target:
                min_subarray_cnt = min(min_subarray_cnt, subarray_cnt)
                subarray_sum = subarray_sum - nums[left] - nums[right]
                subarray_cnt = subarray_cnt - 2
                left += 1
            else:
                right += 1
        
        if min_subarray_cnt == float('inf'):
            return 0
        else: 
            return min_subarray_cnt

    def minSubArrayLen_02(self, target: int, nums: list[int]) -> int:
        n = len(nums)
        min_subarray_cnt = float('inf')
        subarray_cnt = 0 
        subarray_sum = 0
        left = 0 
        for right in range(n):
            subarray_sum += nums[right]
            subarray_cnt += 1

            while subarray_sum>=target:
                min_subarray_cnt = min(min_subarray_cnt, subarray_cnt)
                subarray_cnt -= 1
                subarray_sum -= nums[left]
                left += 1
        
        if min_subarray_cnt == float('inf'):
            return 0 
        else:
            return min_subarray_cnt


def run():
    sol = Solution()
    cases = [
        (7, [2, 3, 1, 2, 4, 3]),
        (4, [1, 4, 4]),
        (11, [1, 1, 1, 1, 1, 1, 1, 1]),
    ]

    for target, nums in cases:
        print(f"Input: target = {target}, nums = {nums}")
        print("minSubArrayLenBruteForce:", sol.minSubArrayLenBruteForce(target, nums))
        print("minSubArrayLen_01:", sol.minSubArrayLen_01(target, nums))
        print("minSubArrayLen_02:", sol.minSubArrayLen_02(target, nums))
        print()


if __name__ == "__main__":
    run()