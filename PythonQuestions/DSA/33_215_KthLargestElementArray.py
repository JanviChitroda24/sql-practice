# # 215 Kth Largest Element in an Array

# Given an integer array nums and an integer k, return the kth largest element in the array.
# Note that it is the kth largest element in the sorted order, not the kth distinct element.

# Can you solve it without sorting?

 

# Example 1:

# Input: nums = [3,2,1,5,6,4], k = 2
# Output: 5
# Example 2:

# Input: nums = [3,2,3,1,2,4,5,5,6], k = 4
# Output: 4
 

# Constraints:

# 1 <= k <= nums.length <= 105
# -104 <= nums[i] <= 104

import heapq

# solving using max heap
class Solution:
    def findKthLargestMaxHeap(self, nums: list[int], k: int) -> int:
        nums = [-1*num for num in nums]
        heapq.heapify(nums)
        while k!=1:
            heapq.heappop(nums)
            k-=1
        return -1*nums[0]

# solving using min heap
    def findKthLargestMinHeap(self, nums: list[int], k: int) -> int:
        heap = []
        for ind, num in enumerate(nums):
            heapq.heappush(heap,num)
            if ind >= k:
                heapq.heappop(heap)
        return heap[0]


# I keep a min-heap of the k largest numbers seen so far. 
# Anything popped is smaller than k others, so it can’t be in the top k, 
#     and at the end, the heap’s top is the kth largest. That’s O(n log k) time and O(k) space


def run():
    sol = Solution()
    cases = [
        ([3, 2, 1, 5, 6, 4], 2),
        ([3, 2, 3, 1, 2, 4, 5, 5, 6], 4),
    ]

    for nums, k in cases:
        print(f"Input: nums = {nums}, k = {k}")
        print("findKthLargestMaxHeap:", sol.findKthLargestMaxHeap(nums, k))
        print("findKthLargestMinHeap:", sol.findKthLargestMinHeap(nums, k))
        print()


if __name__ == "__main__":
    run()