# Heap from scratch: push (bubble up) and pop (sink down)
#
# parent of i:    (i - 1) // 2
# children of i:  2*i + 1, 2*i + 2


def push(heap, x):
    """Add x to the heap, then bubble it up."""
    # your code here
    # first we insert elemt at the last and keep swapping with the parent until the element is less than parent
    heap.append(x)
    indx = len(heap)-1
    while indx > 0 and heap[indx] < heap[(indx-1)//2]:
        t = heap[indx]
        heap[indx] = heap[(indx-1)//2]
        heap[(indx-1)//2] = t
        indx = (indx-1)//2
    return heap
    


def pop(heap):
    """Remove and return the smallest item, then sink the new top down."""
    last_ele = heap.pop()
    if len(heap) == 0:
        return last_ele
    first_ele = heap[0]
    heap[0] = last_ele
    n = len(heap)
    indx = 0
    while 2*indx+1 < n and heap[indx] > min(heap[2*indx+1:2*indx+3]):
        child1_indx = 2*indx + 1
        child2_indx = 2*indx + 2
        swap_indx = child1_indx
        if child2_indx < n:
            min_val = min(heap[child1_indx], heap[child2_indx])

            if min_val == heap[child2_indx]:
                swap_indx = child2_indx

        t = heap[swap_indx]
        heap[swap_indx] = heap[indx]
        heap[indx] = t

        indx = swap_indx
    return first_ele


# ---------------- helpers & tests (no need to edit) ----------------

def is_valid_heap(heap):
    """True if every parent is <= its children."""
    n = len(heap)
    for i in range(n):
        for child in (2 * i + 1, 2 * i + 2):
            if child < n and heap[i] > heap[child]:
                return False
    return True


def check(name, actual, expected):
    status = "PASS" if actual == expected else "FAIL"
    print(f"[{status}] {name}")
    if status == "FAIL":
        print(f"         expected: {expected}")
        print(f"         got:      {actual}")


def run_push_tests():
    print("--- push ---")
    try:
        heap = [2, 5, 3, 8, 7, 6, 4, 12, 9, 10]
        push(heap, 1)
        check("push 1 (rises to top)", heap, [1, 2, 3, 8, 5, 6, 4, 12, 9, 10, 7])

        heap = [1, 2, 3, 8, 5, 6, 4, 12, 9, 10, 7]
        push(heap, 4)
        check("push 4 (stops partway)", heap, [1, 2, 3, 8, 5, 4, 4, 12, 9, 10, 7, 6])

        heap = []
        push(heap, 5)
        check("push into empty heap", heap, [5])

        heap = []
        for x in [6, 4, 8, 1, 3, 9, 0]:
            push(heap, x)
        check("push many, still valid", is_valid_heap(heap), True)
    except NotImplementedError:
        print("push not implemented yet")


def run_pop_tests():
    print("--- pop ---")
    try:
        heap = [1, 2, 3, 8, 5, 4, 4, 12, 9, 10, 7, 6]
        check("pop returns smallest", pop(heap), 1)
        check("heap after pop", heap, [2, 5, 3, 8, 6, 4, 4, 12, 9, 10, 7])

        heap = [7]
        check("pop single item", pop(heap), 7)
        check("heap empty after", heap, [])

        heap = [0, 1, 2, 3, 7, 6, 8, 5, 4, 9]
        out = [pop(heap) for _ in range(len(heap))]
        check("pop all comes out sorted", out, [0, 1, 2, 3, 4, 5, 6, 7, 8, 9])
    except NotImplementedError:
        print("pop not implemented yet")


if __name__ == "__main__":
    run_push_tests()
    run_pop_tests()