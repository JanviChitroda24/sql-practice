# 238 Product of Array Except Self

# Given an integer array nums, 
#     return an array answer such that answer[i] is 
#     equal to the product of all the elements of nums except nums[i].

# The product of any prefix or suffix of nums is guaranteed to 
#     fit in a 32-bit integer.

# You must write an algorithm that runs in O(n) time and 
# without using the division operation.

 

# Example 1:

# Input: nums = [1,2,3,4]
# Output: [24,12,8,6]
# Example 2:

# Input: nums = [-1,1,0,-3,3]
# Output: [0,0,9,0,0]
 

# Constraints:
# 2 <= nums.length <= 105
# -30 <= nums[i] <= 30
# The input is generated such that answer[i] is guaranteed to fit in a 32-bit integer.
 
# Follow up: Can you solve the problem in O(1) extra space complexity? (The output array does not count as extra space for space complexity analysis.)

class Solution:
    # using // operator and checking zeros (3 cases: zeroes>=2, zeroes=1, no zero then //)
    def productExceptSelf1(self, nums: list[int]) -> list[int]:
        n = len(nums)
        answer = [0]*n
        if nums.count(0) >= 2:
            return answer
        elif nums.count(0) == 1:
            running_prod = 1
            zeroth_index = 0
            for ind in range(n):
                if nums[ind]!=0:
                    running_prod = running_prod*nums[ind]
                else:
                    zeroth_index = ind
            answer = [0]*n
            answer[zeroth_index] = running_prod
        else:
            total_prod = 1
            for num in nums:
                total_prod*=num
            answer = []
            for num in nums:
                answer.append(total_prod//num )
        return answer

    # using using 2 arrays left (iterate from start) and right (iterate from last) and then answer array
    def productExceptSelf2(self, nums: list[int]) -> list[int]:
        n = len(nums)
        left_prod = [1]
        right_prod = [1]*n

        for ind in range(1,n):
            left_prod.append(nums[ind-1]*left_prod[ind-1])
        # print(left_prod)

        for ind in range(n-2,-1,-1):
            right_prod[ind] = nums[ind+1]*right_prod[ind+1]
        # print(right_prod)

        for ind in range(n):
            left_prod[ind] = left_prod[ind]*right_prod[ind]
        return left_prod

    # using single array build the left array and than right variable where you store the right running sum and than multiply right by left  you start the right by last element 
    def productExceptSelf3(self, nums: list[int]) -> list[int]:
        n = len(nums)
        left_prod = [1]
        right_prod = [1]*n

        for ind in range(1,n):
            left_prod.append(nums[ind-1]*left_prod[ind-1])
        # print(left_prod)

        right_prod = 1 
        for ind in range(n-1,-1,-1):
            left_prod[ind] = left_prod[ind]*right_prod
            right_prod = right_prod*nums[ind]

        return left_prod


def run():
    sol = Solution()

    print(sol.productExceptSelf3([1, 2, 3, 4]))
    print(sol.productExceptSelf3([-1, 1, 0, -3, 3]))
    print(sol.productExceptSelf3([2, 3, 4]))


if __name__ == "__main__":
    run()