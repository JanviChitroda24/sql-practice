# 230. Kth Smallest Element in a BST

# Given the root of a binary search tree, and an integer k, 
# return the kth smallest value (1-indexed) of all the values of the nodes in the tree.

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
 

# Follow up: 
#     If the BST is modified often (i.e., we can do insert and delete operations) 
#     and you need to find the kth smallest frequently, how would you optimize?

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
    def kthSmallest(self, root: TreeNode | None, k: int) -> int:
        curr = root
        stack = []
        while curr or stack:

            # we first go the the left most element while adding nodes to stack
            while curr:
                stack.append(curr)
                curr = curr.left
            
            # we check the smallest value in the stack
            curr = stack.pop()

            # reduce by one since we want the kth value
            k-=1
            if k == 0:
                return curr.val
            
            # then we iterated to the right and get the trail for the smallest rightmost value
            curr = curr.right

        return None

    def kthSmallestRecursion(self, root: TreeNode | None, k: int) -> int:
        self.result = None
        self.k = k

        def inorder(node):
            #exit condition
            if node is None or self.result is not None:
                return
            # vist the leftmost to find smallest
            inorder(node.left)
            # check if nth smallest is k
            self.k -= 1
            if self.k == 0:
                self.result = node.val
                return
            # visit the right of the current smallest
            inorder(node.right)


        inorder(root)
        return self.result

def run():
    sol = Solution()

    print(sol.kthSmallest(build_tree([3, 1, 4, None, 2]), 1))
    print(sol.kthSmallest(build_tree([5, 3, 6, 2, 4, None, None, 1]), 3))

    print(sol.kthSmallestRecursion(build_tree([3, 1, 4, None, 2]), 1))
    print(sol.kthSmallestRecursion(build_tree([5, 3, 6, 2, 4, None, None, 1]), 3))


if __name__ == "__main__":
    run()
