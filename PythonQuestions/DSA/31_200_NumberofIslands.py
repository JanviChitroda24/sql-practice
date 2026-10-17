# 200 Number of Islands

# Given an m x n 2D binary grid grid which represents a map of '1's (land) and '0's (water), 
#     return the number of islands.

# An island is surrounded by water and is formed by connecting adjacent lands horizontally or vertically. 
# You may assume all four edges of the grid are all surrounded by water.

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

from collections import deque
from typing import List


class Solution:
    def numIslands(self, grid: List[List[str]]) -> int:
        m = len(grid)
        n = len(grid[0])
        visited = [[0]*n for _ in range(m)]
        island_cnt = 0 
        for i in range(m):
            for j in range(n):
                if grid[i][j] == '1' and visited[i][j] == 0:
                    island_cnt += 1
                    visited[i][j] = 1
                    queue= deque([[i,j]])
                    while queue:
                        r,c = queue.popleft()
                        if r-1>=0 and grid[r-1][c] == '1' and visited[r-1][c] == 0:
                            queue.append([r-1,c])
                            visited[r-1][c] = 1
                        if r+1<m and grid[r+1][c] == '1' and visited[r+1][c] == 0:
                            queue.append([r+1,c])
                            visited[r+1][c] = 1
                        if c-1>=0 and  grid[r][c-1] == '1' and visited[r][c-1] == 0:
                            queue.append([r,c-1])
                            visited[r][c-1] = 1
                        if c+1<n and grid[r][c+1] == '1' and visited[r][c+1] == 0:
                            queue.append([r,c+1])
                            visited[r][c+1] = 1
                
        return island_cnt


def run():
    sol = Solution()
    cases = [
        [
            ["1", "1", "1", "1", "0"],
            ["1", "1", "0", "1", "0"],
            ["1", "1", "0", "0", "0"],
            ["0", "0", "0", "0", "0"],
        ],
        [
            ["1", "1", "0", "0", "0"],
            ["1", "1", "0", "0", "0"],
            ["0", "0", "1", "0", "0"],
            ["0", "0", "0", "1", "1"],
        ],
    ]

    for grid in cases:
        print("Input:")
        for row in grid:
            print(row)
        print("Output:", sol.numIslands(grid))
        print()


if __name__ == "__main__":
    run()