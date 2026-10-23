# 141 Linked List Cycle

# Given head, the head of a linked list, determine if the linked list has a cycle in it.
# There is a cycle in a linked list if there is some node in the list 
#     that can be reached again by continuously following the next pointer. 
#     Internally, pos is used to denote the index of the node that tail's next pointer is connected to. 
#     Note that pos is not passed as a parameter.

# Return true if there is a cycle in the linked list. Otherwise, return false.

 

# Example 1:
# Input: head = [3,2,0,-4], pos = 1
# Output: true
# Explanation: There is a cycle in the linked list, where the tail connects to the 1st node (0-indexed).

# Example 2:
# Input: head = [1,2], pos = 0
# Output: true
# Explanation: There is a cycle in the linked list, where the tail connects to the 0th node.

# Example 3:
# Input: head = [1], pos = -1
# Output: false
# Explanation: There is no cycle in the linked list.
 

# Constraints:
# The number of the nodes in the list is in the range [0, 104].
# -105 <= Node.val <= 105
# pos is -1 or a valid index in the linked-list.
 

# Follow up: Can you solve it using O(1) (i.e. constant) memory?

from typing import Optional


class ListNode:
    def __init__(self, val=0, next=None):
        self.val = val
        self.next = next


class Solution:
    # using a set to check whether the item already exist in the set the visited node
    # time complexity = o(n)
    # space complxity = o(n)
    def hasCycle1(self, head: Optional[ListNode]) -> bool:
        cur = head 
        seen = set()
        while cur:
            if cur in seen:
                return True
            seen.add(cur)
            cur = cur.next
        return False

    # using two pointers fast and slow 
    def hasCycle2(self, head: Optional[ListNode]) -> bool:
        fast = slow = head
        while True:
            if fast and fast.next:
                fast = fast.next.next
                slow = slow.next
                if fast == slow:
                    return True
            else:
                return False


def build_list(values, pos):
    if not values:
        return None

    nodes = [ListNode(val) for val in values]
    for i in range(len(nodes) - 1):
        nodes[i].next = nodes[i + 1]
    if pos != -1:
        nodes[-1].next = nodes[pos]
    return nodes[0]


def run():
    sol = Solution()
    cases = [
        ([3, 2, 0, -4], 1),
        ([1, 2], 0),
        ([1], -1),
    ]

    for values, pos in cases:
        print(f"Input: head = {values}, pos = {pos}")
        print("hasCycle1:", sol.hasCycle1(build_list(values, pos)))
        print("hasCycle2:", sol.hasCycle2(build_list(values, pos)))
        print()


if __name__ == "__main__":
    run()