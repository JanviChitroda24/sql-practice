# 100 Same Tree

# Given the roots of two binary trees p and q, write a function to check if they are the same or not.
# Two binary trees are considered the same if they are structurally identical, 
#     and the nodes have the same value.

 

# Example 1:
# Input: p = [1,2,3], q = [1,2,3]
# Output: true

# Example 2:
# Input: p = [1,2], q = [1,null,2]
# Output: false

# Example 3:
# Input: p = [1,2,1], q = [1,1,2]
# Output: false
 

# Constraints:
# The number of nodes in both trees is in the range [0, 100].
# -104 <= Node.val <= 104


class TreeNode:
    def __init__(self, val=0, left=None, right=None):
        self.val = val
        self.left = left
        self.right = right
class Solution:
    def isSameTree1(self, p: TreeNode | None, q: TreeNode | None) -> bool:
        is_same = True
        def traversal(node1, node2):
            nonlocal is_same
            if (not node1) and (not node2):
                return
            elif (not node1) or (not node2):
                is_same = False
                return
            if node1.val != node2.val:
                is_same= False
                return
            traversal(node1.left, node2.left)
            traversal(node1.right, node2.right)
        traversal(p,q)
        return is_same





    def isSameTree2(self, p: TreeNode | None, q: TreeNode | None) -> bool:
        if (not p) and (not q):
            return True
        elif (not p) or (not q):
            return False
        node_ok = True
        if p.val != q.val:
            node_ok = False
            return False
        left_ok = self.isSameTree2(p.left, q.left)
        right_ok = self.isSameTree2(p.right, q.right)
        return node_ok and left_ok and right_ok


    def isSameTree3(self, p: TreeNode | None, q: TreeNode | None) -> bool:
        if (not p) and (not q):
            return True
        elif (not p) or (not q):
            return False
        return (
            p.val==q.val
            and self.isSameTree3(p.left, q.left)
            and self.isSameTree3(p.right, q.right)
        )


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
    cases = [
        ([1, 2, 3], [1, 2, 3]),
        ([1, 2], [1, None, 2]),
        ([1, 2, 1], [1, 1, 2]),
    ]

    for p, q in cases:
        print(f"Input: p = {p}, q = {q}")
        print("isSameTree1:", sol.isSameTree1(build_tree(p), build_tree(q)))
        print("isSameTree2:", sol.isSameTree2(build_tree(p), build_tree(q)))
        print("isSameTree3:", sol.isSameTree3(build_tree(p), build_tree(q)))
        print()


if __name__ == "__main__":
    run()

# Complexity summary
# Method        Approach                                             Time   Space
# ------------  ---------------------------------------------------  -----  -----
# isSameTree1   DFS helper + shared flag (nonlocal), returns nothing O(n)   O(h)
# isSameTree2   DFS returning bools, stores left_ok / right_ok       O(n)   O(h)
# isSameTree3   DFS returning bools, combined with short-circuit and O(n)   O(h)
#
# n = number of nodes (smaller tree), h = height of the tree
#     balanced tree: h ≈ log n   |   skewed tree: h = n
#
# Early stopping:
#   1 - stops below a mismatch, but still visits the rest of the tree
#   2 - stops at a value mismatch, but always checks the right side even if left failed
#   3 - stops at the very first mismatch anywhere (best)

# isSameTree1: 
#     “I walk both trees together with a DFS, 
#     and if I ever find a missing node or a value mismatch, 
#     I set a shared flag to False and return it at the end.”

# isSameTree2: 
#     “Each call compares one pair of nodes and returns whether its subtrees match, 
#     so the parent combines its own check with its left and right results.”

# isSameTree3: 
#     “Two trees are the same if both are empty, 
#     or if their roots match and both pairs of subtrees are the same. 
#     Using and lets it stop at the first mismatch. O(n) time, O(h) space.”