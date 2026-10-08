# 230. Kth Smallest Element in a BST

# Given the root of a binary search tree, and an integer k, return the kth smallest value (1-indexed) of all the values of the nodes in the tree.

 

# Example 1:


# Input: root = [3,1,4,null,2], k = 1
# Output: 1
# Example 2:


# Input: root = [5,3,6,2,4,null,null,1], k = 3
# Output: 3
 

# Constraints:

# The number of nodes in the tree is n.
# 1 <= k <= n <= 104
# 0 <= Node.val <= 104
 

# Follow up: If the BST is modified often (i.e., we can do insert and delete operations) and you need to find the kth smallest frequently, how would you optimize?

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


def find_node(root, val):
    if root is None:
        return None
    if root.val == val:
        return root
    if val < root.val:
        return find_node(root.left, val)
    return find_node(root.right, val)


class Solution:
    def lowestCommonAncestor(self, root: 'TreeNode', p: 'TreeNode', q: 'TreeNode') -> 'TreeNode':
        curr = root
        while curr:
            if p.val<curr.val and q.val<curr.val:
                curr = curr.left
            elif p.val>curr.val and q.val>curr.val:
                curr = curr.right
            else:
                return curr

    def lowestCommonAncestorRecursion(self, root: 'TreeNode', p: 'TreeNode', q: 'TreeNode') -> 'TreeNode':
        if p.val<root.val and q.val<root.val:
            return self.lowestCommonAncestorRecursion(root.left,p,q)
        elif p.val>root.val and q.val>root.val:
            return self.lowestCommonAncestorRecursion(root.right,p,q)
        else:
            return root


def run():
    sol = Solution()
    root = build_tree([6, 2, 8, 0, 4, 7, 9, None, None, 3, 5])

    # Example 1: LCA of 2 and 8 is 6
    ans1 = sol.lowestCommonAncestor(root, find_node(root, 2), find_node(root, 8))
    print(ans1.val)

    # Example 2: LCA of 2 and 4 is 2
    ans2 = sol.lowestCommonAncestor(root, find_node(root, 2), find_node(root, 4))
    print(ans2.val)

    # Example 3: root = [2,1], p = 2, q = 1
    root3 = build_tree([2, 1])
    ans3 = sol.lowestCommonAncestor(root3, find_node(root3, 2), find_node(root3, 1))
    print(ans3.val)

    # Recursive versions of the same cases
    print(sol.lowestCommonAncestorRecursion(root, find_node(root, 2), find_node(root, 8)).val)
    print(sol.lowestCommonAncestorRecursion(root, find_node(root, 2), find_node(root, 4)).val)
    print(sol.lowestCommonAncestorRecursion(root3, find_node(root3, 2), find_node(root3, 1)).val)


if __name__ == "__main__":
    run()
