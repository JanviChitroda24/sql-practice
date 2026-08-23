# # https://leetcode.com/problems/group-anagrams/description/

# 49. Group Anagrams
# Solved
# Medium
# Topics
# premium lock icon
# Companies
# Given an array of strings strs, group the anagrams together. You can return the answer in any order.

 

# Example 1:

# Input: strs = ["eat","tea","tan","ate","nat","bat"]

# Output: [["bat"],["nat","tan"],["ate","eat","tea"]]

# Explanation:

# There is no string in strs that can be rearranged to form "bat".
# The strings "nat" and "tan" are anagrams as they can be rearranged to form each other.
# The strings "ate", "eat", and "tea" are anagrams as they can be rearranged to form each other.
# Example 2:

# Input: strs = [""]

# Output: [[""]]

# Example 3:

# Input: strs = ["a"]

# Output: [["a"]]

 

# Constraints:

# 1 <= strs.length <= 104
# 0 <= strs[i].length <= 100
# strs[i] consists of lowercase English letters.

class Solution(object):
    def groupAnagrams(self, strs):
        d = dict()
        for s in strs:
            ans = ''.join(sorted(s))
            if ans in d:
                d[ans].append(s)
            else:
                d[ans] = [s]
        return list(d.values())


def run():
    sol = Solution()

    print(sol.groupAnagrams(["eat", "tea", "tan", "ate", "nat", "bat"]))
    print(sol.groupAnagrams([""]))
    print(sol.groupAnagrams(["a"]))


if __name__ == "__main__":
    run()
 

# time complexity, it's O(n · k log k) where n is the number of strings and k is the max string length
# python PreparationQuestions/05_GroupAnagrams.py