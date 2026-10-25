# 226 Invert Binary Tree

# Given the root of a binary tree, invert the tree, and return its root.

# Example 1:
# Input: root = [4,2,7,1,3,6,9]
# Output: [4,7,2,9,6,3,1]

# Example 2:
# Input: root = [2,1,3]
# Output: [2,3,1]
# Example 3:

# Input: root = []
# Output: []

# Constraints:
# The number of nodes in the tree is in the range [0, 100].
# -100 <= Node.val <= 100

class TreeNode:
    def __init__(self, val=0, left=None, right=None):
        self.val = val
        self.left = left
        self.right = right

class Solution:
    def invertTree_helperFunction(self, root: TreeNode | None) -> TreeNode | None:
        def traversal(node):
            if not node:
                return 
            t = node.left 
            node.left = node.right
            node.right = t
            traversal(node.left)
            traversal(node.right)
        traversal(root)
        return root
    
    def invertTree_noFunction(self, root: TreeNode | None) -> TreeNode | None:
        if not root:
            return None
        root.left, root.right = root.right, root.left
        self.invertTree_noFunction(root.left)
        self.invertTree_noFunction(root.right)
        return root


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


def to_list(root):
    if root is None:
        return []

    result = []
    queue = [root]
    while queue:
        node = queue.pop(0)
        if node is None:
            result.append(None)
            continue
        result.append(node.val)
        queue.append(node.left)
        queue.append(node.right)

    while result and result[-1] is None:
        result.pop()
    return result


def run():
    sol = Solution()
    cases = [
        [4, 2, 7, 1, 3, 6, 9],
        [2, 1, 3],
        [],
    ]

    for values in cases:
        print(f"Input: root = {values}")
        print("invertTree_helperFunction:", to_list(sol.invertTree_helperFunction(build_tree(values))))
        print("invertTree_noFunction:", to_list(sol.invertTree_noFunction(build_tree(values))))
        print()


if __name__ == "__main__":
    run()