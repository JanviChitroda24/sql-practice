# # https://leetcode.com/problems/longest-consecutive-sequence/description/
# 128. Longest Consecutive Sequence
# Medium
# Topics
# premium lock icon
# Companies
# Given an unsorted array of integers nums, return the length of the longest consecutive elements sequence.

# You must write an algorithm that runs in O(n) time.

 

# Example 1:

# Input: nums = [100,4,200,1,3,2]
# Output: 4
# Explanation: The longest consecutive elements sequence is [1, 2, 3, 4]. Therefore its length is 4.
# Example 2:

# Input: nums = [0,3,7,2,5,8,4,6,0,1]
# Output: 9
# Example 3:

# Input: nums = [1,0,1,2]
# Output: 3
 

# Constraints:

# 0 <= nums.length <= 105
# -109 <= nums[i] <= 109

# A set is a hash table. 
# When you check membership, 
#     Python hashes the value and that hash maps directly to a memory bucket, 
#         so it's a single jump rather than a scan. 
#     That's O(1) average case. 
#     A list has no index into its contents, 
#         so it compares element by element until it finds a match — O(n).

class Solution(object):
    def longestConsecutive(self, nums):
        result=0
        nums = set(nums)
        for num in nums:
            temp = 1
            if num-1 not in nums:
                while num+1 in nums:
                    temp+=1
                    num+=1
            if temp>result:
                result=temp
        return result
        
# {num: True for num in nums}
# dict.fromkeys(nums)

# A set is a hash table. 
# When you check membership, 
#     Python hashes the value and that hash maps directly to a memory bucket, 
#     so it's a single jump rather than a scan. 
# That's O(1) average case. 
# A list has no index into its contents, 
#     so it compares element by element until it finds a match — O(n).

# but functionally a set is the right choice here since I only need membership, not key-value pairs


def run():
    sol = Solution()

    print(sol.longestConsecutive([100, 4, 200, 1, 3, 2]))
    print(sol.longestConsecutive([0, 3, 7, 2, 5, 8, 4, 6, 0, 1]))
    print(sol.longestConsecutive([1, 0, 1, 2]))


if __name__ == "__main__":
    run()

