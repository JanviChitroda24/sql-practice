# 322 Coin Change

# You are given an integer array coins 
#     representing coins of different denominations and an integer amount representing a total amount of money.
# Return the fewest number of coins that you need to make up that amount. 
# If that amount of money cannot be made up by any combination of the coins, return -1.

# You may assume that you have an infinite number of each kind of coin.

 

# Example 1:

# Input: coins = [1,2,5], amount = 11
# Output: 3
# Explanation: 11 = 5 + 5 + 1
# Example 2:

# Input: coins = [2], amount = 3
# Output: -1
# Example 3:

# Input: coins = [1], amount = 0
# Output: 0
 

# Constraints:

# 1 <= coins.length <= 12
# 1 <= coins[i] <= 231 - 1
# 0 <= amount <= 104

class Solution:
    def coinChange(self, coins: list[int], amount: int) -> int:
        amounts = [float('inf')]*(amount+1)
        amounts[0] = 0

        for ind in range(1, amount+1):
            vals = []
            for coin in coins:
                if coin <= ind:
                    val = 1 + amounts[ind-coin]
                    vals.append(val)
            if vals != []:
                amounts[ind] = min(vals)
        
        final_count = amounts[amount]
        if final_count != float('inf'):
            return final_count
        return -1


    def coinChangeOptimized(self, coins: list[int], amount: int) -> int:
        amounts = [float('inf')]*(amount+1)
        amounts[0] = 0

        for ind in range(1, amount+1):
            min_val = float('inf')
            for coin in coins:
                if coin <= ind:
                    val = 1 + amounts[ind-coin]
                    if val < min_val:
                        min_val = val
                amounts[ind] = min_val
        
        final_count = amounts[amount]
        if final_count != float('inf'):
            return final_count
        return -1


def run():
    sol = Solution()

    print(sol.coinChange([1, 2, 5], 11))
    print(sol.coinChange([2], 3))
    print(sol.coinChange([1], 0))


if __name__ == "__main__":
    run()