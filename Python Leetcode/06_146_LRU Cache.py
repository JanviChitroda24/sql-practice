# 146. LRU Cache
# http://leetcode.com/problems/lru-cache/description/

"""
 **LRU Cache = a dictionary with a size limit.**

A regular dictionary can grow forever. An LRU Cache has a fixed capacity. When it's full and you need to add something new, you must remove something old. The question is: **which one do you remove?**

Answer: the one that was **used least recently** — the item nobody has `get` or `put` for the longest time.

**Example with capacity 3:**

```
put(A, 1)     → cache: [A]
put(B, 2)     → cache: [B, A]
put(C, 3)     → cache: [C, B, A]          ← full

get(A)        → cache: [A, C, B]          ← A moves to front, it was just used

put(D, 4)     → cache is full, who to remove?
                 B is at the back — least recently used
                 remove B
                 cache: [D, A, C]
```

**Rules:**
- Front = most recently used
- Back = least recently used
- `get(key)` → moves that key to front
- `put(key, value)` → adds to front, if full removes from back
- Both must be O(1)

**What you need to build:**
1. `__init__(capacity)` — set up the cache
2. `get(key)` — return value if exists (and move to front), else return -1
3. `put(key, value)` — add or update (move to front), evict from back if full
"""

# Design a data structure that follows the constraints of a Least Recently Used (LRU) cache.

# Implement the LRUCache class:

# LRUCache(int capacity) Initialize the LRU cache with positive size capacity.
# int get(int key) Return the value of the key if the key exists, otherwise return -1.
# void put(int key, int value) Update the value of the key if the key exists. Otherwise, add the key-value pair to the cache. If the number of keys exceeds the capacity from this operation, evict the least recently used key.
# The functions get and put must each run in O(1) average time complexity.

 

# Example 1:

# Input
# ["LRUCache", "put", "put", "get", "put", "get", "put", "get", "get", "get"]
# [[2], [1, 1], [2, 2], [1], [3, 3], [2], [4, 4], [1], [3], [4]]
# Output
# [null, null, null, 1, null, -1, null, -1, 3, 4]

# Explanation
# LRUCache lRUCache = new LRUCache(2);
# lRUCache.put(1, 1); // cache is {1=1}
# lRUCache.put(2, 2); // cache is {1=1, 2=2}
# lRUCache.get(1);    // return 1
# lRUCache.put(3, 3); // LRU key was 2, evicts key 2, cache is {1=1, 3=3}
# lRUCache.get(2);    // returns -1 (not found)
# lRUCache.put(4, 4); // LRU key was 1, evicts key 1, cache is {4=4, 3=3}
# lRUCache.get(1);    // return -1 (not found)
# lRUCache.get(3);    // return 3
# lRUCache.get(4);    // return 4
 

# Constraints:

# 1 <= capacity <= 3000
# 0 <= key <= 104
# 0 <= value <= 105
# At most 2 * 105 calls will be made to get and put.

class Node:
    def __init__(self, key=0, val=0):
        self.key = key
        self.val = val
        self.next = None
        self.prev = None

class LRUCache:

    def __init__(self, capacity: int):
        self.capacity = capacity
        self.cache = {} # cache is internal. Nobody outside creates it or passes it in

        self.head = Node(0)
        self.tail = Node(0)

        self.head.next = self.tail
        self.tail.prev = self.head

    
    def _remove(self, node):
        node.prev.next = node.next
        node.next.prev = node.prev

    def _add(self, node):
        node.next = self.head.next
        node.prev = self.head
        self.head.next.prev = node
        self.head.next = node

    def get(self, key: int) -> int:
        if key not in self.cache: 
            return -1
        else:
            node = self.cache[key]
            _remove(node)
            _add(node)
            return node.val

    def put(self, key: int, value: int) -> None:
        


# Your LRUCache object will be instantiated and called as such:
# obj = LRUCache(capacity)
# param_1 = obj.get(key)
# obj.put(key,value)