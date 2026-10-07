# 104. Maximum Depth of Binary Tree

# Given the root of a binary tree, return its maximum depth.
# A binary tree's maximum depth is the number of nodes along the longest path from the root node down to the farthest leaf node.

 
# Example 1:

# Input: root = [3,9,20,null,null,15,7]
# Output: 3
# Example 2:

# Input: root = [1,null,2]
# Output: 2
 

# Constraints:
# The number of nodes in the tree is in the range [0, 104].
# -100 <= Node.val <= 100

class TreeNode:
    def __init__(self, val=0, left=None, right=None):
        self.val = val
        self.left = left
        self.right = right


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


class Solution:
    def maxDepth(self, root: TreeNode | None) -> int:
        if root is None:
            return 0
        
        left_depth = self.maxDepth(root.left)
        right_depth = self.maxDepth(root.right)

        actual_dept = 1 + max(left_depth, right_depth)

        return actual_dept


def run():
    sol = Solution()

    print(sol.maxDepth(build_tree([3, 9, 20, None, None, 15, 7])))
    print(sol.maxDepth(build_tree([1, None, 2])))
    print(sol.maxDepth(build_tree([])))


if __name__ == "__main__":
    run()
