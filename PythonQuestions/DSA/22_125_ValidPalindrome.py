# 125. Valid Palindrome

# A phrase is a palindrome if, 
#     after converting all uppercase letters into lowercase letters 
#     and removing all non-alphanumeric characters, it reads the same forward and backward. 
#     Alphanumeric characters include letters and numbers.

# Given a string s, return true if it is a palindrome, or false otherwise.

 
# Example 1:

# Input: s = "A man, a plan, a canal: Panama"
# Output: true
# Explanation: "amanaplanacanalpanama" is a palindrome.
# Example 2:

# Input: s = "race a car"
# Output: false
# Explanation: "raceacar" is not a palindrome.
# Example 3:

# Input: s = " "
# Output: true
# Explanation: s is an empty string "" after removing non-alphanumeric characters.
# Since an empty string reads the same forward and backward, it is a palindrome.
 

# Constraints:

# 1 <= s.length <= 2 * 105
# s consists only of printable ASCII characters.

class Solution:
    # using 2 points left and right and have apce complexity of o(1) and time complexity of o(n)
    # most important conditon is left<right you dont even need to check left<n or right>0
    def isPalindrome_01(self, s: str) -> bool:
        left = 0
        right = len(s)-1
        n = len(s)
        while left<right and left<n and right>0:
            while left<right and (not s[left].isalnum()):
                left+=1
            while left<right and (not s[right].isalnum()):
                right-=1   
            if (s[left].lower()!=s[right].lower()): 
                return False
            left+=1
            right-=1
        return True

    # time complexity o(n) and space complexity o(n)
    # here instead of creating a new reversey array we compare the elements 1st and last using (n+1)//2
    # here i have used built function isalnum() to check whether the character is alphanumeric or not
    def isPalindrome_02(self, s: str) -> bool:
        s = s.lower()
        alpha_s = ''
        for char in s:
            if char.isalnum():
                alpha_s += char
        n = len(alpha_s)
        for ind in range((n+1)//2):
            if alpha_s[ind] != alpha_s[n-ind-1]:
                return False
        return True

    # time complexity o(n) and space complexity o(n)
    # here we are comparing string and reversed string 
    # also instead o using builtin isalnum() we convert the character to ascii value using ord() and do range check
    def isPalindrome_03(self, s: str) -> bool:
        s = s.lower()
        alpha_s = ''
        for char in s:
            ascii_val = ord(char)
            if ascii_val in range(97,123) or ascii_val in range(48,58):
                alpha_s += char
        if alpha_s == alpha_s[::-1]:
            return True
        return False


def run():
    sol = Solution()
    cases = [
        "A man, a plan, a canal: Panama",
        "race a car",
        " ",
    ]

    for s in cases:
        print(f"Input: s = {s!r}")
        print("isPalindrome_01:", sol.isPalindrome_01(s))
        print("isPalindrome_02:", sol.isPalindrome_02(s))
        print("isPalindrome_03:", sol.isPalindrome_03(s))
        print()


if __name__ == "__main__":
    run()