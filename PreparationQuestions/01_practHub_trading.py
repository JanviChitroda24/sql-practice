# https://prachub.com/coding-questions/implement-portfolio-trading-optimizer

# Implement Portfolio Trading Optimizer
# hard
# Point72
# Data Engineer
# Quick Overview
# This question evaluates algorithmic problem-solving, array processing, input validation via decorators, and the ability to produce concise transaction reports for maximizing non-overlapping buy/sell profits.

# You are given a list prices, where prices[i] is the stock price on day i. You may complete as many buy/sell transactions as you want, but you may hold at most one share at a time, and each buy must happen before its matching sell. Your task is to return a human-readable report of the transactions that achieve the maximum total profit.

# To make the answer deterministic when multiple optimal solutions exist, use this rule while scanning from left to right:

# Skip every flat-or-falling stretch and buy at the last local minimum.
# Continue through the entire flat-or-rising stretch and sell at the last local maximum.
# Repeat until the end of the list.
# Each transaction line must have the format: buy_day=X buy_price=A sell_day=Y sell_price=B profit=P

# The final line must be: total_profit=T

# If no profitable transaction exists, return only total_profit=0.

# Your implementation must also validate the input the same way a validate_prices decorator would:

# prices must be a list
# 0 <= len(prices) <= 30000
# every element must be an integer
# 0 <= prices[i] <= 10000
# If the input is invalid, raise ValueError.

# Examples
# Example 1
# Input
# [7, 1, 5, 3, 6, 4]
# Output
# "buy_day=1 buy_price=1 sell_day=2 sell_price=5 profit=4\nbuy_day=3 buy_price=3 sell_day=4 sell_price=6 profit=3\ntotal_profit=7"
# Notes
# Buy at day 1 and sell at day 2 for profit 4, then buy at day 3 and sell at day 4 for profit 3. Total profit is 7.
# Example 2
# Input
# [1, 2, 3, 4, 5]
# Output
# "buy_day=0 buy_price=1 sell_day=4 sell_price=5 profit=4\ntotal_profit=4"
# Notes
# The whole array is one rising run, so the deterministic answer is a single transaction from the first day to the last day.
# Constraints
# 0 <= len(prices) <= 30000
# 0 <= prices[i] <= 10000
# Every price must be a non-negative integer
# Raise ValueError if the input violates the constraints


def solution(prices):
    if type(prices) != list:
        raise ValueError
    elif len(prices) > 30000:
        raise ValueError
    else:
        for pr in prices:
            if type(pr) != int:
                raise ValueError
            elif pr < 0 or pr>10000:
                raise ValueError

    n = len(prices)
    cur=0
    total=""
    total_val=0
    while cur<n:
        while cur+1 < n and prices[cur] >= prices[cur+1]:
            cur+=1
        if cur+1>=n:
            break
        buy = prices[cur]
        total+='buy_day='+str(cur)+" buy_price="+str(prices[cur])
        sell_ptr = cur+1
        while sell_ptr+1 < n and prices[sell_ptr] <= prices[sell_ptr+1]:
            sell_ptr += 1
        sell = prices[sell_ptr]
        total+=' sell_day='+str(sell_ptr)+" sell_price="+str(sell)
        total_val+= sell-buy
        total+=' profit='+str(sell-buy)+"\n"
        cur = sell_ptr+1
    if total=="":
        return 'total_profit=0'
    else:
        total+='total_profit='+str(total_val)
        return total
    
def solution(prices):
    if not isinstance(prices, list) or len(prices) > 30000:
        raise ValueError
    for p in prices:
        if not isinstance(p, int) or isinstance(p, bool) or not (0 <= p <= 10000):
            raise ValueError

    n = len(prices)
    i = 0
    lines = []
    total = 0

    while i < n:
        while i + 1 < n and prices[i] >= prices[i + 1]:
            i += 1
        if i + 1 >= n:
            break
        buy_day = i

        sell_day = i + 1
        while sell_day + 1 < n and prices[sell_day] <= prices[sell_day + 1]:
            sell_day += 1

        profit = prices[sell_day] - prices[buy_day]
        total += profit
        lines.append(f"buy_day={buy_day} buy_price={prices[buy_day]} sell_day={sell_day} sell_price={prices[sell_day]} profit={profit}")
        i = sell_day + 1

    lines.append(f"total_profit={total}")
    return "\n".join(lines)

def run():
    prices1 = [7, 1, 5, 3, 6, 4]
    print(solution(prices1))

    prices2 = [1, 2, 3, 4, 5]
    print(solution(prices2))


if __name__ == "__main__":
    run()

# python PreparationQuestions/01_practHub_trading.py