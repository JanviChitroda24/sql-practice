# 347. Top K Frequent Elements
# Solved
# Medium
# Topics
# premium lock icon
# Companies
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

class Solution(object):
    def topKFrequent(self, nums, k):
        d = dict()
        n=len(nums)
        freq_list = [ [] for _ in range(n+1)]
        ans = []
        for num in nums:
            if num in d:
                d[num]+=1
            else:
                d[num]=1
        for key,value in d.items():
            freq_list[value].append(key)
        for i in range(n,0,-1):
            if freq_list[i]!=[]:
                for ele in freq_list[i]:
                    ans.append(ele)
            if len(ans) >= k:
                break
        return ans


def run():
    sol = Solution()

    print(sol.topKFrequent([1, 1, 1, 2, 2, 3], 2))
    print(sol.topKFrequent([1], 1))
    print(sol.topKFrequent([1, 2, 1, 2, 1, 2, 3, 1, 3, 2], 2))


if __name__ == "__main__":
    run()


# python PreparationQuestions/09_347_TopKFrequency.py