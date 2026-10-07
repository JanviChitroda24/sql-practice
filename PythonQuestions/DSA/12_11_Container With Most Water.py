# Container With Most Water: #11
# https://leetcode.com/problems/container-with-most-water/description/

# 11. Container With Most Water

# You are given an integer array height of length n. There are n vertical lines drawn such that the two endpoints of the ith line are (i, 0) and (i, height[i]).

# Find two lines that together with the x-axis form a container, such that the container contains the most water.

# Return the maximum amount of water a container can store.

# Notice that you may not slant the container.

 

# Example 1:


# Input: height = [1,8,6,2,5,4,8,3,7]
# Output: 49
# Explanation: The above vertical lines are represented by array [1,8,6,2,5,4,8,3,7]. In this case, the max area of water (blue section) the container can contain is 49.
# Example 2:

# Input: height = [1,1]
# Output: 1
 

# Constraints:

# n == height.length
# 2 <= n <= 105
# 0 <= height[i] <= 104

# brute force appraoch
class Solution:
    def maxAreaBruteForce(self, height: list[int]) -> int:
        max_height = 0
        for i in range(len(height)):
            for j in range(i+1, len(height)):
                t = min(height[i], height[j])*(j-i)
                if t>max_height:
                    max_height = t
        return max_height

    def maxArea(self, height: list[int]) -> int:
        max_area = 0
        left = 0 
        right = len(height)-1
        while left < right:
            temp_area = min(height[left],height[right])*(right-left)
            if temp_area > max_area:
                max_area = temp_area
            if height[left] <= height[right]:
                left += 1
            else:
                right-=1
        return max_area

def run():
    sol = Solution()

    print(sol.maxAreaBruteForce([1, 8, 6, 2, 5, 4, 8, 3, 7]))
    print(sol.maxAreaBruteForce([1, 1]))

    print(sol.maxArea([1, 8, 6, 2, 5, 4, 8, 3, 7]))
    print(sol.maxArea([1, 1]))


if __name__ == "__main__":
    run()

