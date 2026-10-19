# # 155. Min Stack

# Design a stack that supports push, pop, top, and retrieving the minimum element in constant time.

# Implement the MinStack class:

# MinStack() initializes the stack object.
# void push(int value) pushes the element value onto the stack.
# void pop() removes the element on the top of the stack.
# int top() gets the top element of the stack.
# int getMin() retrieves the minimum element in the stack.
# You must implement a solution with O(1) time complexity for each function.

 

# Example 1:

# Input
# ["MinStack","push","push","push","getMin","pop","top","getMin"]
# [[],[-2],[0],[-3],[],[],[],[]]

# Output
# [null,null,null,null,-3,null,0,-2]

# Explanation
# MinStack minStack = new MinStack();
# minStack.push(-2);
# minStack.push(0);
# minStack.push(-3);
# minStack.getMin(); // return -3
# minStack.pop();
# minStack.top();    // return 0
# minStack.getMin(); // return -2

class MinStack:

    def __init__(self):
        self.stack = []

    def push(self, value: int) -> None:
        if self.stack:
            cur_min = self.stack[-1][1]
            if cur_min < value:
                self.stack.append([value, cur_min])
            else:
                self.stack.append([value, value])
        else:
            self.stack.append([value, value])

    def pop(self) -> None:
        self.stack.pop()

    def top(self) -> int:
        return self.stack[-1][0]

    def getMin(self) -> int:
        return self.stack[-1][1]

def check(name, actual, expected):
    if actual == expected:
        print(f"[PASS] {name}")
    else:
        print(f"[FAIL] {name}: got {actual}, expected {expected}")


def run():
    print("--- example ---")
    stack = MinStack()
    stack.push(-2)
    stack.push(0)
    stack.push(-3)
    check("getMin after push -3", stack.getMin(), -3)
    stack.pop()
    check("top after pop", stack.top(), 0)
    check("getMin after pop", stack.getMin(), -2)

    print("--- new minimum, then pop back ---")
    stack = MinStack()
    stack.push(5)
    stack.push(3)
    stack.push(7)
    check("min is 3", stack.getMin(), 3)
    stack.push(1)
    check("min becomes 1", stack.getMin(), 1)
    check("top is 1", stack.top(), 1)
    stack.pop()
    check("min returns to 3", stack.getMin(), 3)
    check("top is 7", stack.top(), 7)


if __name__ == "__main__":
    run()