# Longest Consecutive Sequence: #128

# Given an unsorted array of integers nums, 
#     return the length of the longest consecutive elements sequence.

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

"""
Brute force approach is to first sort the list and then iterate over the list while storing the prev_element
and we also store the max_length globally and cur_length locally and when we iterate from the start and if the element = prev_element+1 than increate the curent_len and if not we reset it 
and after each iteration we compare with the gloabl max_length and update it accordingly
so the time complexity is o(nlogn) which is the complaxity of sorting
"""

class Solution:
    def longestConsecutive(self, nums: list[int]) -> int:
        nums_set = set(nums)
        max_seq_len = min(1,len(nums))
        for num in nums_set:
            if num-1 in nums_set:
                continue
            elif num+1 in nums_set:
                cur_seq_len = 1
                n= num+1
                while n in nums_set:
                    cur_seq_len+=1
                    n+=1
                if cur_seq_len>max_seq_len:
                    max_seq_len=cur_seq_len
        return max_seq_len


def run():
    sol = Solution()

    print(sol.longestConsecutive([100, 4, 200, 1, 3, 2]))
    print(sol.longestConsecutive([0, 3, 7, 2, 5, 8, 4, 6, 0, 1]))
    print(sol.longestConsecutive([1, 0, 1, 2]))


if __name__ == "__main__":
    run()
