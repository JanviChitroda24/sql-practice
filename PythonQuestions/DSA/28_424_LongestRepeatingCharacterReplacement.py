# # 11. 424 Longest Repeating Character Replacement

# You are given a string s and an integer k. 
# You can choose any character of the string and change it to any other uppercase English character. 
# You can perform this operation at most k times.

# Return the length of the longest substring containing the same letter 
#     you can get after performing the above operations.

 

# Example 1:

# Input: s = "ABAB", k = 2
# Output: 4
# Explanation: Replace the two 'A's with two 'B's or vice versa.

# Example 2:
# Input: s = "AABABBA", k = 1
# Output: 4
# Explanation: Replace the one 'A' in the middle with 'B' and form "AABBBBA".
# The substring "BBBB" has the longest repeating letters, which is 4.
# There may exists other ways to achieve this answer too.
 

# Constraints:
# 1 <= s.length <= 105
# s consists of only uppercase English letters.
# 0 <= k <= s.length

class Solution:
    # Shrink until valid (variable-size window): 
    def characterReplacement(self, s: str, k: int) -> int:
        left = 0 
        right = 0 
        n = len(s)
        max_subarray = 0
        max_freq = 0
        freq_cnt = {}

        while right<n:
            window_size = right-left+1

            if s[right] in freq_cnt:
                freq_cnt[s[right]] += 1
            else:
                freq_cnt[s[right]] = 1

            max_freq = max(freq_cnt.values())
            
            if window_size - max_freq <= k:
                max_subarray = max(max_subarray, window_size)
                right += 1
            else:
                freq_cnt[s[left]]-=1
                freq_cnt[s[right]]-=1
                left+=1
        
        return max_subarray

    def characterReplacement_02(self, s: str, k: int) -> int:
        left = 0 
        right = 0 
        max_subarray = 0 
        freq_cnt = {}
        n = len(s)
        max_freq = 0

        while right<n:
            window_size = right-left+1

            if s[right] in freq_cnt:
                freq_cnt[s[right]] += 1
            else:
                freq_cnt[s[right]] = 1
            
            # Only the newly added character’s count can increase, so comparing it to the old max catches every new maximum.
            max_freq = max(max_freq, freq_cnt[s[right]])

            if window_size-max_freq <= k:
                max_subarray = max(max_subarray, window_size)
            else:
                freq_cnt[s[left]] -= 1
                left += 1

            # The window grows only when a letter hits a new record count; otherwise it slides, so its size is always the best answer so far.
            right+=1

        return max_subarray


# Grow or slide (window never gets smaller): 
#     use max_freq = max(max_freq, freq_cnt[s[right]]). 
#     The window doesn’t have to be truly valid at every step, because you only care about its size, 
#     and its size is always the best answer so far. 
#     A stale max_freq is fine here.

# Shrink until valid (variable-size window): 
#     use max(freq_cnt.values()). 
#     Here the point is that every window you record is actually valid, 
#     so you need the true current max. 
#     A stale, too-high max_freq would stop the shrinking early and leave an invalid window.

def run():
    sol = Solution()
    cases = [
        ("ABAB", 2),
        ("AABABBA", 1),
    ]

    for s, k in cases:
        print(f"Input: s = {s!r}, k = {k}")
        print("characterReplacement:", sol.characterReplacement(s, k))
        print("characterReplacement_02:", sol.characterReplacement_02(s, k))
        print()


if __name__ == "__main__":
    run()