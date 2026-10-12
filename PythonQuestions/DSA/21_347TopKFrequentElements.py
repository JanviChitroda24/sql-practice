# 347. Top K Frequent Elements.

# Given an integer array nums and an integer k, return the k most frequent elements within the array.

# The test cases are generated such that the answer is always unique.

# You may return the output in any order.

# Example 1:

# Input: nums = [1,2,2,3,3,3], k = 2

# Output: [2,3]
# Example 2:

# Input: nums = [7,7], k = 1

# Output: [7]
# Constraints:

# 1 <= nums.length <= 10^4.
# -1000 <= nums[i] <= 1000
# 1 <= k <= number of distinct elements in nums.

from typing import List


class Solution:
    # most intuitive
    # create a dictionary of elements and then sort the d.items() by values in sorted function
    # eg: d_arrray = sorted(d, k=lambda x:x[1], reverse=True)
    def topKFrequent_01(self, nums: List[int], k: int) -> List[int]:
        d = dict()
        for num in nums:
            if num in d:
                d[num]+=1
            else:
                d[num]=1
        d_array = sorted(d.items(), key=lambda x: x[1], reverse=True)
        op = []
        for ele in d_array[:k]:
            op.append(ele[0])
        return op

    #instead of sorted function whose worst time complexity is o(nlogn)
    # we use bucket sort with time complexity  o(n)
    # it works here since the output is of fixed range 
        # we create a list of n+1 elements 
        # and the index denotes the count 
    # since the ansewris unique we dont have to worry wbout a case there there is uncertainty
    # dict with bucket sort 
    def topKFrequent_02(self, nums: List[int], k: int) -> List[int]:
        d = dict()
        for num in nums:
            if num in d:
                d[num]+=1
            else:
                d[num]=1
        #instead of sorting (nlogn) we do bucket sort
        d_list = [ [] for _ in range(len(nums)+1) ]
        for val,cnt in d.items():
            d_list[cnt].append(val)
        op=[]
        for val in d_list[::-1]:
            if k<=0:
                break
            if val!=[]:
                op.extend(val)
                k-=len(val)
        return op

    # inital try 
    def topKFrequent_03(self, nums: List[int], k: int) -> List[int]:
        d = dict()
        for num in nums:
            if num in d:
                d[num]+=1
            else:
                d[num]=1
        d_array = sorted(d.items(), key=lambda x: x[1], reverse=True)
        op = []
        for ele in d_array:
            if k==0:
                break
            k-=1
            op.append(ele[0])
        return op


def run():
    sol = Solution()
    cases = [
        ([1, 2, 2, 3, 3, 3], 2),
        ([7, 7], 1),
    ]

    for nums, k in cases:
        print(f"Input: nums = {nums}, k = {k}")
        print("topKFrequent_01:", sol.topKFrequent_01(nums, k))
        print("topKFrequent_02:", sol.topKFrequent_02(nums, k))
        print("topKFrequent_03:", sol.topKFrequent_03(nums, k))
        print()


if __name__ == "__main__":
    run()