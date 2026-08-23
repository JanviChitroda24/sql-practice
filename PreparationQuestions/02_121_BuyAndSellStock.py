# You are given an array prices where prices[i] is the price of a given stock on the ith day.

# You want to maximize your profit by choosing a single day to buy one stock and choosing a different day in the future to sell that stock.

# Return the maximum profit you can achieve from this transaction. If you cannot achieve any profit, return 0.

 

# Example 1:

# Input: prices = [7,1,5,3,6,4]
# Output: 5
# Explanation: Buy on day 2 (price = 1) and sell on day 5 (price = 6), profit = 6-1 = 5.
# Note that buying on day 2 and selling on day 1 is not allowed because you must buy before you sell.
# Example 2:

# Input: prices = [7,6,4,3,1]
# Output: 0
# Explanation: In this case, no transactions are done and the max profit = 0.

# Input: prices = [10 3 10 2 6 8 5 1]
# Output: 7

class Solution(object):
    def maxProfit(self, prices):
        mini = prices[0]
        profit = 0
        for i in range(1,len(prices)):
            temp = prices[i]-mini
            if prices[i] < mini:
                mini = prices[i]
            if temp > profit:
                profit = temp
        return profit


def run():
    sol = Solution()

    prices1 = [7, 1, 5, 3, 6, 4]
    print(sol.maxProfit(prices1))

    prices2 = [7, 6, 4, 3, 1]
    print(sol.maxProfit(prices2))

    prices3 = [10, 3, 10, 2, 6, 8, 5, 1]
    print(sol.maxProfit(prices3))


if __name__ == "__main__":
    run()

# python PreparationQuestions/02_121_BuyAndSellStock.py