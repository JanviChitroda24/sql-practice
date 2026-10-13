# 206. Reverse Linked List
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
 

# Follow up: A linked list can be reversed either iteratively or recursively. Could you implement both?

from typing import Optional


class ListNode:
    def __init__(self, val=0, next=None):
        self.val = val
        self.next = next


class Solution:

    def reverseList(self, head: Optional[ListNode]) -> Optional[ListNode]:
        # in reversing the linkedlist we need 3 variables - prev, cur and nxt
        # we just need to flip cur's next value to prev and update the prev to cur value while iterating

        # initially the cur value will be the head
        cur = head
        # head has no prev vlaue so we initialize prev to None
        prev = None 

        # we will iterate over the linkedlist until we move past the last element
        # use use cur and move until cur becomes None
        while cur != None:
            # we store the cur's next value before flipping
            nxt=cur.next
            
            #flip 
            cur.next = prev
            prev = cur

            # move to the next element
            cur = nxt

        # the new head value if prev, since its the last node we flipped 
        head = prev 
        return head


def build_list(values):
    dummy = ListNode()
    cur = dummy
    for val in values:
        cur.next = ListNode(val)
        cur = cur.next
    return dummy.next


def to_list(head):
    values = []
    while head is not None:
        values.append(head.val)
        head = head.next
    return values


def run():
    sol = Solution()
    cases = [
        [1, 2, 3, 4, 5],
        [1, 2],
        [],
    ]

    for values in cases:
        print(f"Input: head = {values}")
        print("Output:", to_list(sol.reverseList(build_list(values))))
        print()


if __name__ == "__main__":
    run()