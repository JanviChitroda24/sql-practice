**Python Data Structures — Lookup & Usage Reference**

---

**List**
- Stores elements in order, allows duplicates
- Backed by a dynamic array internally
- Access by index is O(1) — jump directly to position
- Membership check (`x in list`) is O(n) — scans every element
- Adding to end is O(1), adding/removing from middle is O(n) — shifts elements

```python
l = []
l.append('a')       # add to end — O(1)
l.pop()              # remove from end — O(1)
l.pop(0)             # remove from start — O(n)
l[2]                 # access by index — O(1)
'a' in l             # membership check — O(n)
l.remove('a')        # remove first occurrence by value — O(n)
len(l)               # size — O(1)
l.sort()             # sort in place — O(n log n)
l.insert(i, 'a')     # insert at index — O(n)
```

Use when: you need order, index access, duplicates, or iteration in sequence.

---

**Set**
- Stores unique elements only, no order guaranteed
- Backed by a hash table internally
- Membership check (`x in set`) is O(1) — hashes and jumps directly
- Cannot access by index — no `s[0]`
- Automatically handles duplicates — adding a duplicate does nothing

```python
s = set()
s.add('a')           # add element — O(1)
s.remove('a')        # remove element, error if missing — O(1)
s.discard('a')       # remove element, no error if missing — O(1)
'a' in s             # membership check — O(1)
len(s)               # size — O(1)
s.clear()            # remove all elements
s1 & s2              # intersection
s1 | s2              # union
s1 - s2              # difference
```

Use when: you only need to check "is this present?" — no duplicates, no order, no indices needed.

---

**Dictionary**
- Stores key-value pairs, keys must be unique
- Backed by a hash table internally (like set, but with values attached)
- Key lookup (`key in dict`) is O(1)
- Cannot access by position — only by key
- Keys must be immutable (strings, numbers, tuples) — no lists as keys

```python
d = {}
d['a'] = 1           # add or update key-value — O(1)
d['a']               # get value by key, error if missing — O(1)
d.get('a', 0)        # get value, return default if missing — O(1)
'a' in d             # check if KEY exists — O(1)
del d['a']           # remove key-value pair — O(1)
d.keys()             # all keys
d.values()           # all values
d.items()            # all (key, value) pairs
len(d)               # number of keys — O(1)
```

Use when: you need to associate values with keys — element to index, character to count, name to score.

---

**Quick Decision Rule:**
- Just checking existence → **set**
- Need a value for each key → **dict**
- Need order or index access → **list**
- Checking existence AND need a value → **dict**
- Need fast lookup AND fast ordered access → use both (dict + list, or sorted structure)

---

**Common Interview Patterns:**
- Frequency counting → `dict` (character: count)
- Complement lookup (Two Sum) → `dict` (value: index)
- Sliding window duplicates → `set` (track current window)
- Visited nodes in BFS/DFS → `set`
- Index-based access in arrays → `list`