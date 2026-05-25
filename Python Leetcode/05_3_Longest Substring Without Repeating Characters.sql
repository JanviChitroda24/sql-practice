-- 3. Longest Substring Without Repeating Characters
-- https://leetcode.com/problems/longest-substring-without-repeating-characters/description/

-- Given a string s, find the length of the longest substring without duplicate characters.

 

-- Example 1:
-- Input: s = "abcabcbb"
-- Output: 3
-- Explanation: The answer is "abc", with the length of 3. Note that "bca" and "cab" are also correct answers.

-- Example 2:
-- Input: s = "bbbbb"
-- Output: 1
-- Explanation: The answer is "b", with the length of 1.

-- Example 3:
-- Input: s = "pwwkew"
-- Output: 3
-- Explanation: The answer is "wke", with the length of 3.
-- Notice that the answer must be a substring, "pwke" is a subsequence and not a substring.
 

-- Constraints:

-- 0 <= s.length <= 5 * 104
-- s consists of English letters, digits, symbols and spaces.


class Solution:
    def lengthOfLongestSubstring(self, s: str) -> int:
        lss = set()
        i = 0 
        n = len(s)
        left = 0
        right = 0
        max_len = 0
        while i < n:
            if s[i] not in lss:
                lss.add(s[i])
            else:
                while s[left] != s[i]:
                    lss.remove(s[left])
                    left+=1
                left+=1
                lss.add(s[i])
            max_len = max(max_len, right - left + 1)
            i+=1
            right += 1
        return max_len

-- solution 2 without i
class Solution:
    def lengthOfLongestSubstring(self, s: str) -> int:
        lss = set()
        n = len(s)
        left = 0
        right = 0
        max_len = 0
        while right < n:
            if s[right] not in lss:
                lss.add(s[right])
            else:
                while s[left] != s[right]:
                    lss.remove(s[left])
                    left+=1
                lss.remove(s[left])
                left+=1
                lss.add(s[right])
            max_len = max(max_len, right - left + 1)
            right += 1
        return max_len

-- Sure. Trace your code with `"abba"`:

-- ```
-- right=0: 'a' not in set → add 'a', set={a}
-- right=1: 'b' not in set → add 'b', set={a,b}
-- right=2: 'b' IS in set → enter else
--          while s[left] != s[right]: s[0]='a' != 'b'
--            remove 'a', left=1. set={b}
--          Now s[left]='b' == s[right]='b', while stops
--          left=2
--          lss.add('b') ← 'b' is STILL in the set, never removed
-- ```

-- See? You removed `a` but never removed the old `b`. You're adding `b` again but since it's a set, nothing happens. The set still has `{b}` and it works out.

-- But the *correct* logic should be: remove everything from left up to AND including the duplicate, then add the new character. Your code skips removing the duplicate itself.

-- It works because sets ignore duplicate adds. But if this were a dict tracking counts instead of a set, this bug would cause wrong answers.

-- That's all I meant. Your solution is correct for this problem. Just understand *why* it works so you don't carry the pattern into a problem where it breaks.

-- Let's move on. Ready for LRU Cache?