# # 102 Binary Tree Level Order Traversal

# Given the root of a binary tree, return the level order traversal of its nodes' values. 
# (i.e., from left to right, level by level).


# Example 1:
# Input: root = [3,9,20,null,null,15,7]
# Output: [[3],[9,20],[15,7]]


# Example 2:
# Input: root = [1]
# Output: [[1]]

# Example 3:
# Input: root = []
# Output: []
 

# Constraints:
# The number of nodes in the tree is in the range [0, 2000].
# -1000 <= Node.val <= 1000

class TreeNode:
    def __init__(self, val=0, left=None, right=None):
        self.val = val
        self.left = left
        self.right = right

class Solution:
    def levelOrder(self, root: TreeNode | None) -> list[list[int]]:
        if root is None:
            return []

        queue = [root]
        answer = []

        while queue:
            level_size = len(queue)
            level_vals = []

            for _ in range(level_size):
                node = queue.pop(0)
                level_vals.append(node.val)

                if node.left:
                    queue.append(node.left)
                if node.right:
                    queue.append(node.right)
                
            answer.append(level_vals)

        return answer

# pop(0) --> shifts the whole list every time. So, list.pop(0) is O(n)
# On a wide tree (Full == balanced tree), where a level can hold about n/2 nodes, that makes BFS O(n²).
# deque.popleft() is O(1), so BFS stays O(n).

# Create a deque:
#     from collections import deque
#     queue = deque([root])

# Action               list            list cost   deque            deque cost
# -------------------  --------------  ----------  ---------------  ----------
# Add to back          append(x)       O(1)        append(x)        O(1)
# Remove from back     pop()           O(1)        pop()            O(1)
# Add to front         insert(0, x)    O(n)        appendleft(x)    O(1)
# Remove from front    pop(0)          O(n)        popleft()        O(1)
# Peek front / back    q[0] / q[-1]    O(1)        q[0] / q[-1]     O(1)
# Index the middle     q[i]            O(1)        q[i]             O(n)
# Size / empty check   len(q) / if q:  O(1)        len(q) / if q:   O(1)

# Why list.pop(0) is O(n):
#     A list stores elements side by side in one block of memory,
#     like seats in a row. Index i is "go to the start, then move i seats."
#     Remove the first element, and every other element must shift
#     one seat left to keep the row gapless. n elements -> n shifts.
#
# Why deque.popleft() is O(1):
#     A deque is a chain of small blocks linked together, with a marker
#     pointing at the front and another at the back.
#     popleft() just takes the front element and moves the front marker
#     forward by one. Nothing else moves.
#
# The tradeoff:
#     Because a deque is a chain, reaching the middle (q[i]) means
#     walking along the chain -> O(n). A list jumps straight there -> O(1).
#
#     list  = fast at the ends? only the back.   fast in the middle? yes.
#     deque = fast at the ends? both.            fast in the middle? no.

from collections import deque

class Solution2:
    def levelOrder2(self, root: TreeNode | None) -> list[list[int]]:
        if root is None:
            return []
        
        queue = deque([root])
        answer = []

        while queue:
            level_size = len(queue)
            level_vals = []

            for _ in range(level_size):
                node = queue.popleft()
                level_vals.append(node.val)
                
                if node.left:
                    queue.append(node.left)
                if node.right:
                    queue.append(node.right)
            
            answer.append(level_vals)

        return answer


def build_tree(values):
    if not values:
        return None

    root = TreeNode(values[0])
    queue = [root]
    i = 1

    while queue and i < len(values):
        node = queue.pop(0)
        if i < len(values) and values[i] is not None:
            node.left = TreeNode(values[i])
            queue.append(node.left)
        i += 1
        if i < len(values) and values[i] is not None:
            node.right = TreeNode(values[i])
            queue.append(node.right)
        i += 1

    return root


def run():
    sol = Solution()
    sol2 = Solution2()
    cases = [
        [3, 9, 20, None, None, 15, 7],
        [1],
        [],
    ]

    for values in cases:
        print(f"Input: root = {values}")
        print("levelOrder:", sol.levelOrder(build_tree(values)))
        print("levelOrder2:", sol2.levelOrder2(build_tree(values)))
        print()


if __name__ == "__main__":
    run()
