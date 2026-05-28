# 200. Number of Islands
# https://leetcode.com/problems/number-of-islands/description/

# Given an m x n 2D binary grid grid which represents a map of '1's (land) and '0's (water), return the number of islands.

# An island is surrounded by water and is formed by connecting adjacent lands horizontally or vertically. You may assume all four edges of the grid are all surrounded by water.

 

# Example 1:

# Input: grid = [
#   ["1","1","1","1","0"],
#   ["1","1","0","1","0"],
#   ["1","1","0","0","0"],
#   ["0","0","0","0","0"]
# ]
# Output: 1
# Example 2:

# Input: grid = [
#   ["1","1","0","0","0"],
#   ["1","1","0","0","0"],
#   ["0","0","1","0","0"],
#   ["0","0","0","1","1"]
# ]
# Output: 3
 

# Constraints:

# m == grid.length
# n == grid[i].length
# 1 <= m, n <= 300
# grid[i][j] is '0' or '1'.

class Solution:
    def numIslands(self, grid: List[List[str]]) -> int:
        def dfs(grid, row, col):
            # check bounds and if cell is water
            if (row>=0 and row<len(grid))  and (col>=0 and col<len(grid[0]))  and grid[row][col]=='1':
                # mark as visited
                grid[row][col]='0'

                # explore four neighbors
                dfs(grid, row-1, col)
                dfs(grid, row+1, col)
                dfs(grid, row, col-1)
                dfs(grid, row, col+1)
        
        island_cnt = 0
        for row in range(len(grid)):
            for col in range(len(grid[0])):
                if grid[row][col] == '1':
                    dfs(grid, row, col)
                    island_cnt += 1
        
        return island_cnt


# This is O(m × n) time and space where m and n are grid dimensions. Clean solution.
# Key notes for revision:

# DFS on grid pattern:
#   Loop through every cell
#   When you find the target, explore all connected cells using DFS
#   Mark visited cells to avoid counting twice
#   DFS helper: check bounds, check if valid, mark visited, recurse on four neighbors

# When to use this pattern:
#   Counting connected components (islands, regions)
#   Flood fill
#   Finding paths in a maze
#   Any problem where you explore connected cells in a grid



# **Why "Depth First"?**
# When you find a `1`, you don't check all four neighbors first. 
# You go UP as far as possible, then when you hit a wall, backtrack and try the next direction. 
# You go **deep** before going **wide**.
# ```
# Start at X, go up until stuck, backtrack, go right...
# [1, 1, 0]
# [1, X, 0]
# [0, 0, 0]

# DFS order might be: X → up → up's left → back → up's right → back → right...
# ```

# **BFS (Breadth First Search):**
# Check all immediate neighbors first, then their neighbors, then their neighbors. 
# Goes **wide** before going **deep**. Uses a queue.
# ```
# BFS order from X: X → all 4 neighbors → all their neighbors...
# Level by level, like ripples in water.
# ```

# **DFS vs BFS:**
# DFS uses recursion or a stack. 
# Goes deep first. 
# Simpler to code for grid problems.

# BFS uses a queue. 
# Goes level by level. 
# Better when you need the **shortest path** 
#     — because the first time BFS reaches a cell, it's guaranteed to be the shortest route.

# For Number of Islands, both give the same answer. 
# DFS is simpler to code.

# **Will interviewers care about recursion?**
# For this problem, no. 
# Both recursive DFS and iterative BFS are fine. 

# But know this: 
#     very large grids can cause recursion stack overflow. 
#     If the interviewer asks "what could go wrong?", mention that, 
#         and say you could convert to iterative DFS using a stack or use BFS with a queue. 
#     You don't need to code both — just knowing the tradeoff shows maturity.

class Solution:
    def numIslands(self, grid: List[List[str]]) -> int:
        def dfs(grid, row, col):
            # check bounds and if cell is water
            if (row>=0 and row<len(grid))  and (col>=0 and col<len(grid[0]))  and grid[row][col]=='1':
                # mark as visited
                grid[row][col]='0'

                # explore four neighbors
                dfs(grid, row-1, col)
                dfs(grid, row+1, col)
                dfs(grid, row, col-1)
                dfs(grid, row, col+1)
        
        island_cnt = 0
        for row in range(len(grid)):
            for col in range(len(grid[0])):
                if grid[row][col] == '1':
                    dfs(grid, row, col)
                    island_cnt += 1
        
        return island_cnt
