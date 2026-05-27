# 206. Reverse Linked List
# https://leetcode.com/problems/reverse-linked-list/description/

# Given the head of a singly linked list, reverse the list, and return the reversed list.

 

# Example 1:
# Input: head = [1,2,3,4,5]
# Output: [5,4,3,2,1]


# Example 2:
# Input: head = [1,2]
# Output: [2,1]

# Example 3:
# Input: head = []
# Output: []
 
# Constraints:
# The number of nodes in the list is the range [0, 5000].
# -5000 <= Node.val <= 5000
 

# Follow up: 
# A linked list can be reversed either iteratively or recursively. Could you implement both?

"""
## Basics of Linked List
`head` is just the first node. 
    That's all. 
    The function receives the first node, and from there you follow `.next` to traverse.

```
head = Node(1)
head.val = 1
head.next = Node(2)
head.next.val = 2
head.next.next = Node(3)
head.next.next.next = None  ← end of list
```

**How to traverse:**

```python
curr = head
while curr is not None:
    print(curr.val)   # do something with current node
    curr = curr.next  # move to next node
```

That's it. `curr = curr.next` is how you move forward. When `curr` becomes `None`, you've reached the end.

**Now for reversing**, you need three variables:

- `prev` — what's behind you
- `curr` — where you are
- `nxt` — save what's ahead before you break the link

Each step inside the loop:
```
nxt = curr.next      # save next before breaking link
curr.next = prev     # reverse the pointer
prev = curr          # move prev forward
curr = nxt           # move curr forward
```

Try coding it. Start with `prev = None`, `curr = head`, loop while `curr is not None`, do those four lines, return `prev`.
"""

# Definition of singly-linked list
# class LinkNode:
#     def ListNode(self, val=0, next=None):
#         self.val = val
#         self.next = next
    
class Solution:
    def reverseList(self, head: Optional[ListNode]) -> Optional[ListNode]:
        prev = None
        curr = head
        while curr is not None:
            nxt = curr.next
            curr.next = prev
            prev = curr
            curr = nxt
        return prev
    

# To lock this in, don't think of it as "reverse linked list code." Think of it as one core idea:

# **To reverse a link, you need to save what's ahead before you break the connection.**

# That's the entire problem. Everything else follows:
# - You need `nxt` because you're about to destroy `curr.next`
# - You need `prev` because that's where you're pointing `curr.next` to
# - You move both forward after each reversal

# **For tweaked versions**, ByteDance might ask:
# - Reverse only a portion (nodes 2 to 4)
# - Reverse in groups of k
# - Check if a linked list is a palindrome (hint: reverse the second half and compare)

# All of them use the same four-line core. The tweak is just *where* you start and stop the reversal.
