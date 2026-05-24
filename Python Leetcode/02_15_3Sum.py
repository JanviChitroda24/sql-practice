# 15. 3Sum
# https://leetcode.com/problems/3sum/description/

# Given an integer array nums, return all the triplets [nums[i], nums[j], nums[k]] such that i != j, i != k, and j != k, and nums[i] + nums[j] + nums[k] == 0.

# Notice that the solution set must not contain duplicate triplets.

 

# Example 1:

# Input: nums = [-1,0,1,2,-1,-4]
# Output: [[-1,-1,2],[-1,0,1]]
# Explanation: 
# nums[0] + nums[1] + nums[2] = (-1) + 0 + 1 = 0.
# nums[1] + nums[2] + nums[4] = 0 + 1 + (-1) = 0.
# nums[0] + nums[3] + nums[4] = (-1) + 2 + (-1) = 0.
# The distinct triplets are [-1,0,1] and [-1,-1,2].
# Notice that the order of the output and the order of the triplets does not matter.
# Example 2:

# Input: nums = [0,1,1]
# Output: []
# Explanation: The only possible triplet does not sum up to 0.
# Example 3:

# Input: nums = [0,0,0]
# Output: [[0,0,0]]
# Explanation: The only possible triplet sums up to 0.
 

# Constraints:

# 3 <= nums.length <= 3000
# -105 <= nums[i] <= 105

class Solution:
    def threeSum(self, nums: list[int]) -> list[list[int]]:
        nums.sort()
        print(nums)
        i = 0 
        n = len(nums)
        output = []
        while i < n:
            if i > 0 and nums[i] == nums[i-1]:
                i+=1
                continue
            left = i+1
            right = n-1
            while left < right:
                if nums[i]+nums[left]+nums[right] == 0:
                    output.append([nums[i],nums[left],nums[right]])
                    left+=1 
                    right-=1
                    while left < right and nums[left] == nums[left-1]:
                        left += 1
                    while left < right and nums[right] == nums[right+1]:
                        right -= 1
                elif nums[i] + nums[left] + nums[right] < 0:
                    left+=1
                else:
                    right-=1
            i+=1
        return output

# just one line optimization - extra check if nums[i] > 0, then break
class Solution:
    def threeSum(self, nums: list[int]) -> list[list[int]]:
        nums.sort()
        n = len(nums)
        i=0
        output = []
        while i < n:
            if i >0 and nums[i] == nums[i-1]:
                i+=1
                continue
            if nums[i] > 0:
                break
            left=i+1
            right=n-1
            while left < right:
                if nums[i] + nums[left] + nums[right] == 0:
                    output.append([nums[i], nums[left], nums[right]])
                    left+=1
                    right-=1
                    while left < right and nums[left] == nums[left-1]:
                        left+=1
                    while left < right and nums[right] == nums[right+1]:
                        right-=1
                elif nums[i]+nums[left]+nums[right] < 0:
                    left+=1
                else:
                    right-=1
            i+=1
        return output