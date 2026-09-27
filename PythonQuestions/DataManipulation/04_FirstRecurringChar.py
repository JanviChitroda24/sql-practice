# Given a string, write a function that returns the first recurring character, 
# or None if there isn't one.

# Example 1
s = "abcdb"
# Output: "b" — 'b' appears at index 1 and again at index 4, first to repeat

# Example 2
# s = "abcade"
# Output: "a" — 'a' repeats at index 3, 'e' never repeats, so 'a' is first recurring

# Example 3
# s = "abcdef"
# Output: None — no character repeats

# Example 4
# s = "aabb"
# Output: "a" — 'a' recurs at index 1 before 'b' recurs at index 3

print(s)

# using dictionary
d = {}
op = None
for ch in s:
    if d.get(ch):
        op = ch
        break
    else:
        d[ch]=1
print(op)

# alternative use set (more effienct)
seen = set()
op = None 
for ch in s:
    if ch in seen:
        op = ch
        break
    else:
        seen.add(ch)
print(op)