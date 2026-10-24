# 98 Validate Binary Search Tree

# Given the root of a binary tree, determine if it is a valid binary search tree (BST).

# A valid BST is defined as follows:
# The left subtree of a node contains only nodes with keys strictly less than the node's key.
# The right subtree of a node contains only nodes with keys strictly greater than the node's key.
# Both the left and right subtrees must also be binary search trees.
 

# Example 1:
# Input: root = [2,1,3]
# Output: true

# Example 2:
# Input: root = [5,1,4,null,null,3,6]
# Output: false
# Explanation: The root node's value is 5 but its right child's value is 4.
 

# Constraints:
# The number of nodes in the tree is in the range [1, 104].
# -231 <= Node.val <= 231 - 1

class TreeNode:
    def __init__(self, val=0, left=None, right=None):
        self.val = val
        self.left = left
        self.right = right


class Solution:
    def isValidBST_inOrderTraversal_array(self, root: TreeNode | None) -> bool:
        answer = []
        def inOrderTraversal(node):
            if not node:
                return
            inOrderTraversal(node.left)
            answer.append(node.val)
            inOrderTraversal(node.right)
        inOrderTraversal(root)
        for i in range(len(answer)-1):
            if answer[i] >= answer[i+1]:
                return False
        return True

    def isValidBST_inOrderTraversal_prevIsValid(self, root: TreeNode | None) -> bool:
        prev = -float('inf')
        is_valid = True
        def inOrderTraversal(node):
            nonlocal prev, is_valid
            if not node:
                return
            inOrderTraversal(node.left)
            if node.val<=prev:
                is_valid = False
            prev = node.val
            inOrderTraversal(node.right)

        inOrderTraversal(root)
        return is_valid

    def isValidBST_inOrderTraversal_prev(self, root: TreeNode | None) -> bool:
        prev = -float('inf')
        def inOrderTraversal(node):
            nonlocal prev
            if not node:
                return True
            left_val = inOrderTraversal(node.left)
            cur_val = node.val > prev
            prev = node.val
            right_val = inOrderTraversal(node.right)
            return left_val and cur_val and right_val
        return inOrderTraversal(root)
    
    def isValidBST_rangeCheck(self, root: TreeNode | None) -> bool:
        def check(node, low, high):
            if not node:
                return True
            
            cur_ok = low < node.val < high
            left_ok = check(node.left, low, node.val)
            right_ok = check(node.right, node.val, high)

            return cur_ok and left_ok and right_ok

        return check(root, -float('inf'), float('inf'))


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
        [2, 1, 3],
        [5, 1, 4, None, None, 3, 6],
    ]

    for values in cases:
        root = build_tree(values)
        print(f"Input: root = {values}")
        print("isValidBST_inOrderTraversal_array:", sol.isValidBST_inOrderTraversal_array(root))
        print("isValidBST_inOrderTraversal_prevIsValid:", sol.isValidBST_inOrderTraversal_prevIsValid(root))
        print("isValidBST_inOrderTraversal_prev:", sol.isValidBST_inOrderTraversal_prev(root))
        print("isValidBST_rangeCheck:", sol.isValidBST_rangeCheck(root))
        print()


if __name__ == "__main__":
    run()

# Complexity summary
# Method          Idea                                            Time   Space
# --------------  ----------------------------------------------  -----  -----
# _array          Inorder into a list, check strictly increasing  O(n)   O(n)
# _prevIsValid    Inorder with prev, set a flag if order breaks   O(n)   O(h)
# _prev           Inorder with prev, return True/False back up    O(n)   O(h)
# _rangeCheck     Pass a (low, high) range down to each node      O(n)   O(h)
#
# h = height of the tree (space comes from the recursion call stack)
#     balanced tree: h ≈ log n   |   skewed tree (a straight line): h = n