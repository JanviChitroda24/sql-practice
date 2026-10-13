# 56. Merge Intervals

# Given an array of intervals where intervals[i] = [starti, endi], 
#     merge all overlapping intervals, 
#     and return an array of the non-overlapping intervals that cover all the intervals in the input.

 

# Example 1:

# Input: intervals = [[1,3],[2,6],[8,10],[15,18]]
# Output: [[1,6],[8,10],[15,18]]
# Explanation: Since intervals [1,3] and [2,6] overlap, merge them into [1,6].
# Example 2:

# Input: intervals = [[1,4],[4,5]]
# Output: [[1,5]]
# Explanation: Intervals [1,4] and [4,5] are considered overlapping.
# Example 3:

# Input: intervals = [[4,7],[1,4]]
# Output: [[1,7]]
# Explanation: Intervals [1,4] and [4,7] are considered overlapping.
 

# Constraints:

# 1 <= intervals.length <= 104
# intervals[i].length == 2
# 0 <= starti <= endi <= 104

from typing import List


class Solution:
    def merge(self, intervals: List[List[int]]) -> List[List[int]]:
        ints = sorted(intervals)
        output_list = [ints[0]]
        for ind in range(1, len(ints)):
            last_start, last_end = output_list[-1]
            cur_start, cur_end = ints[ind]
            if last_end>=cur_start:
                output_list[-1][1] = max(last_end, cur_end)
            else:
                output_list.append(ints[ind])
        return output_list


def run():
    sol = Solution()
    cases = [
        [[1, 3], [2, 6], [8, 10], [15, 18]],
        [[1, 4], [4, 5]],
        [[4, 7], [1, 4]],
    ]

    for intervals in cases:
        print(f"Input: intervals = {intervals}")
        print("Output:", sol.merge(intervals))
        print()


if __name__ == "__main__":
    run()