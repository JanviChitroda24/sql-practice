# 17. 739 Daily Temperatures

# Given an array of integers temperatures represents the daily temperatures, 
#  return an array answer such that answer[i] is the number of days you have to wait 
#  after the ith day to get a warmer temperature. 
# If there is no future day for which this is possible, keep answer[i] == 0 instead.

 

# Example 1:

# Input: temperatures = [73,74,75,71,69,72,76,73]
# Output: [1,1,4,2,1,1,0,0]
# Example 2:

# Input: temperatures = [30,40,50,60]
# Output: [1,1,1,0]
# Example 3:

# Input: temperatures = [30,60,90]
# Output: [1,1,0]
 

# Constraints:

# 1 <= temperatures.length <= 105
# 30 <= temperatures[i] <= 100

# monotonic stack --- decreasing element stack
class Solution:

    # brute force solution 
    # Time complexity = O(n^2), Space complexity = O(1)
    def dailyTemperaturesBruteForce(self, temperatures: list[int]) -> list[int]:
        n = len(temperatures)
        answer = [0]*n

        for ind, temp in enumerate(temperatures):
            for j in range(ind+1,n):
                if temperatures[j] > temperatures[ind]:
                    answer[ind] = j - ind
                    break

        return answer

    
    # Storing the smaller temperatures with index in a list (using list of list) waiting list 
    # Time complexity = O(n^2), Space complexity = O(2n)= O(n)
    def dailyTemperatures2ndBest(self, temperatures: list[int]) -> list[int]:
        n = len(temperatures)
        answer = [0]*n
        waiting = []
        for ind, cur_temp in enumerate(temperatures):
            while waiting:
                smallest_temp = waiting[-1][1]
                st_ind = waiting[-1][0]
                if cur_temp > smallest_temp:
                    answer[st_ind] = ind-st_ind
                    waiting.pop()
                else:
                    break
            waiting.append([ind, cur_temp])
        return answer

    # brute force solution 
    # Time complexity = O(n^2), Space complexity = O(1)
    def dailyTemperatures(self, temperatures: list[int]) -> list[int]:
        n = len(temperatures)
        answer = [0]*n
        waiting = []
        for ind, temp in enumerate(temperatures):
            while waiting:
                smallest_temp = temperatures[waiting[-1]]
                st_ind = waiting[-1]
                if temp>smallest_temp:
                    answer[st_ind] = ind - st_ind
                    waiting.pop()
                else:
                    break
            waiting.append(ind)
        return answer


def run():
    sol = Solution()
    cases = [
        [73, 74, 75, 71, 69, 72, 76, 73],
        [30, 40, 50, 60],
        [30, 60, 90],
    ]

    for temperatures in cases:
        print(f"Input: temperatures = {temperatures}")
        print("dailyTemperaturesBruteForce:", sol.dailyTemperaturesBruteForce(temperatures))
        print("dailyTemperatures2ndBest:", sol.dailyTemperatures2ndBest(temperatures))
        print("dailyTemperatures:", sol.dailyTemperatures(temperatures))
        print()


if __name__ == "__main__":
    run()