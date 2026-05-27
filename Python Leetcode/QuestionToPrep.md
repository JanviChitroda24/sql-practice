Here are your Top 10 LeetCode problems, ranked by probability of appearing in a DE interview:
Rank 1 — 3Sum (LC 15) — Medium
Why: Explicitly mentioned by multiple Glassdoor DE candidates. One said "threesum question from leetcode, but they tweaked it a bit." This is likely your highest-probability question. Tests sorting + two pointers. Practice the base version, then make sure you can handle variants (3Sum Closest, 3Sum Smaller).
Rank 2 — Two Sum (LC 1) — Easy
Why: The foundation that 3Sum builds on. Your prep guide lists it, Glassdoor mentions "coding sums," and it's ByteDance's warm-up question pattern. They often start easy then escalate. If you can't do this instantly in under 5 minutes, everything else slows down.
Rank 3 — Valid Triangle Number (LC 611) — Medium
Why: Explicitly confirmed asked in a ByteDance DE Round 1 interview (Medium article source). Sorting + two pointers — same pattern as 3Sum. This is the "they ask the same pattern but different skin" proof.
Rank 4 — Reverse Linked List (LC 206) — Easy
Why: Explicitly reported in a ByteDance DE interview. Also listed in your ByteDance_Interview_experience.pdf and your prep guide. Linked list questions are confirmed "frequently mentioned in past interviews" by InterviewQuery's DE guide. Know both iterative and recursive approaches.
Rank 5 — LRU Cache (LC 146) — Medium
Why: Listed as a "Top 7 ByteDance Interview Question" in the Jobright guide (your interview experience PDF). Tests hash map + doubly linked list — a design-oriented coding problem that's perfect for DE roles because it tests system thinking, not just algorithms. ByteDance interviewers use this to see if you understand O(1) design trade-offs.
Rank 6 — Longest Substring Without Repeating Characters (LC 3) — Medium
Why: Multiple sources list this as a ByteDance favorite. Your prep guide includes it. Glassdoor mentions "string" problems in OAs. Sliding window is a core pattern and this is the canonical problem for it. Also directly relevant to DE work (processing streams, finding patterns in data windows).
Rank 7 — Merge Intervals (LC 56) — Medium
Why: Your prep guide lists it, it's in every "ByteDance top questions" compilation, and it's highly DE-relevant (scheduling, pipeline time windows, overlapping data ranges). Sorting + interval logic. ByteDance loves problems that map to real engineering concepts.
Rank 8 — Top K Frequent Elements (LC 347) — Medium
Why: Your prep guide lists it under "Hash Maps & Sets." This maps directly to DE work (finding top N users, most frequent events, popular content). Uses hash map + heap or bucket sort. The Glassdoor "top 10 customers by video duration" question is essentially this pattern applied to SQL — they test the same concept in both Python and SQL.
Rank 9 — Binary Tree Level Order Traversal (LC 102) — Medium
Why: ByteDance interview experience PDF mentions binary tree problems explicitly. Glassdoor DE review mentioned "mirror image of binary tree." InterviewQuery's DE guide says "linked lists or binary trees have been frequently mentioned." BFS traversal is the foundation — if they ask any tree question, level order is the most likely one for a DE (it maps to processing data in layers/levels).
Rank 10 — Number of Islands (LC 200) — Medium
Why: Your prep guide lists it. Glassdoor mentions "graphs" in OA questions. This is the most canonical BFS/DFS problem and the gentlest graph question they could ask. If they want to test graph knowledge without going hard-mode, this is the one. Also: Glassdoor DE OA format mentioned "Graphs (Hard)" as the third problem — Number of Islands is the warm-up for that pattern.


Based on your ByteDance interview materials, here's your priority list:

**Tier 1 — Most frequently asked, prepare these first:**
- Two Sum (done ✓)
- 3Sum / 3Sum variants (done ✓)
- Reverse Linked List
- Merge Two Sorted Lists
- Longest Substring Without Repeating Characters (sliding window)
- LRU Cache (hash map + doubly linked list — asked multiple times)
- Number of Islands (BFS/DFS)

**Tier 2 — Commonly asked, do after Tier 1:**
- Merge Intervals
- Top K Frequent Elements
- Valid Parentheses
- Kth Largest Element in an Array
- Daily Temperatures (monotonic stack)
- Group Anagrams

**Tier 3 — Occasionally asked, good to know:**
- Search in Rotated Sorted Array (binary search)
- Binary Tree Level Order Traversal
- 3+ Consecutive Login Days (SQL-heavy but sometimes asked as coding)

**Patterns to internalize (not specific problems):**
- Hash map for complement/frequency counting
- Two pointers on sorted arrays
- Sliding window for substring problems
- Linked list pointer manipulation
- BFS/DFS for grid/tree traversal

Start with Tier 1 top to bottom. You already have two done. Want to start with Reverse Linked List or Longest Substring?