# 572. Subtree of Another Tree

# Given the roots of two binary trees root and subRoot, return true if there is a subtree of root with the same structure and node values of subRoot and false otherwise.

# A subtree of a binary tree tree is a tree that consists of a node in tree and all of this node's descendants. The tree tree could also be considered as a subtree of itself.

 

# Example 1:


# Input: root = [3,4,5,1,2], subRoot = [4,1,2]
# Output: true
# Example 2:


# Input: root = [3,4,5,1,2,null,null,null,null,0], subRoot = [4,1,2]
# Output: false

class TreeNode:
    def __init__(self, val=0, left=None, right=None):
        self.val = val
        self.left = left
        self.right = right


class Solution:
    def isSubtree_01(self, root: TreeNode | None, subRoot: TreeNode | None) -> bool:
        def subroot_traversal(node, subroot):
            if (not node) and (not subroot):
                return True
            if (not node) or (not subroot):
                return False
            if node.val != subroot.val:
                return False
            return subroot_traversal(node.left, subroot.left) and subroot_traversal(node.right, subroot.right)

        def root_traversal(node, subroot):
            if not node or not subroot:
                return False
            if node.val == subroot.val:
                answer = subroot_traversal(node, subroot)
                if answer:
                    return answer
            return root_traversal(node.left, subroot) or root_traversal(node.right, subroot)

        return root_traversal(root, subRoot)

    def isSubtree_02(self, root: TreeNode | None, subRoot: TreeNode | None) -> bool:
        def subroot_traversal(node, subroot):
            if (not node) and (not subroot):
                return True
            if (not node) or (not subroot):
                return False
            if node.val != subroot.val:
                return False
            return subroot_traversal(node.left, subroot.left) and subroot_traversal(node.right, subroot.right)
       
        def root_traversal(node, subroot):
            if not node or not subroot:
                return False
            if subroot_traversal(node, subroot):
                return True
            return root_traversal(node.left, subroot) or root_traversal(node.right, subroot)
        
        return root_traversal(root, subRoot)

    def isSubtree_03(self, root: TreeNode | None, subRoot: TreeNode | None) -> bool:
        
        def seralize(node):
            if not node:
                return "#"
            return f'^{node.val},{seralize(node.left)},{seralize(node.right)}'

        return seralize(subRoot) in seralize(root)


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
        ([3, 4, 5, 1, 2], [4, 1, 2]),
        ([3, 4, 5, 1, 2, None, None, None, None, 0], [4, 1, 2]),
    ]

    for root_vals, sub_vals in cases:
        root = build_tree(root_vals)
        sub_root = build_tree(sub_vals)
        print(f"Input: root = {root_vals}, subRoot = {sub_vals}")
        print("isSubtree_01:", sol.isSubtree_01(root, sub_root))
        print("isSubtree_02:", sol.isSubtree_02(root, sub_root))
        print("isSubtree_03:", sol.isSubtree_03(root, sub_root))
        print()


if __name__ == "__main__":
    run()


# The recursive approach is O(m · n) because every time a comparison fails partway, 
#     it starts over at the next node and re-compares nodes it already looked at. 
# Serializing turns the problem into a substring search, 
#     and a substring search doesn’t have to restart like that. 
#     A linear-time algorithm keeps track of how much of the pattern it has already matched, 
#     so when there’s a mismatch it reuses that work instead of going back in the text, 
#     and every character is read a constant number of times. That’s O(m + n). 
# In Python, in is an optimized C search that’s fast in practice; 
#     if I needed a strict worst-case guarantee, I’d use a linear-time algorithm like KMP