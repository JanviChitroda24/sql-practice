# SQL Problem-Solving Checklist — Complete Guide with Examples

---

## ✅ Step 1: Read the Output First

**What to do:** Before writing anything, look at the expected output and ask: "What is ONE row?"

**Why:** This determines your GROUP BY and tells you which table is the "base" table.

**Example:**
```
Output:
| invoice_id | customer_name | price | contacts_cnt | trusted_contacts_cnt |

One row = one invoice → Invoices is the base table
```

```
Output:
| month | active_drivers | accepted_rides |

One row = one month → you need to generate months first
```

**Mistake to avoid:** Jumping straight into JOINs without knowing what shape the output should be.

---

## ✅ Step 2: Identify Tables Needed

**What to do:** For each output column, trace it back to its source table.

**Why:** If different output columns come from different tables using different keys/dates, you might need UNION ALL instead of JOIN.

**Example — Monthly Transactions II (LC 1205):**
```
Output columns:
- approved_count    → from Transactions, grouped by trans_date month
- chargeback_count  → from Chargebacks, grouped by charge_date month

Different date columns determine the month → can't do one GROUP BY
→ UNION ALL two streams, then aggregate
```

**Example — Combine Two Tables (LC 175):**
```
Output columns:
- firstName, lastName → from Person
- city, state         → from Address

Same key (personId) → simple LEFT JOIN
```

**Rule:** If output columns come from different grouping keys, think UNION ALL. If same key, think JOIN.

---

## ✅ Step 3: Check Join Types — The Multiplication Rule

**What to do:** For every JOIN you write, ask: "Is the column I'm joining TO unique?"

- **Unique (primary key / unique column)** → one-to-one → safe
- **Not unique** → one-to-many → rows WILL multiply

**Why:** One-to-many joins are fine alone. But TWO one-to-many joins on the same base table cause a cross product that inflates aggregates.

### Safe: One one-to-many join

```
Users (PK: user_id)
  JOIN Orders (user_id is NOT unique — multiple orders per user)

User 1 has 3 orders → 3 rows after join. Fine — one row per order.
```

### Dangerous: Two one-to-many joins

```
Users (PK: user_id)
  JOIN Orders (user_id NOT unique — 2 orders)
  JOIN Payments (user_id NOT unique — 2 payments)

Result: 2 × 2 = 4 rows for user 1
SUM(order_amount) is DOUBLED because each order appears with every payment
```

**Example — Bank Account Summary (LC 1555):**
```sql
-- ❌ WRONG: Double one-to-many join
FROM Users u
LEFT JOIN Transaction pby ON u.user_id = pby.paid_by    -- multiple rows
LEFT JOIN Transaction pto ON u.user_id = pto.paid_to    -- multiple rows
-- Amounts get multiplied!

-- ✅ CORRECT: Pre-aggregate each in separate CTEs
WITH paid AS (
    SELECT paid_by AS user_id, SUM(amount) AS total_paid
    FROM Transaction GROUP BY paid_by
),
received AS (
    SELECT paid_to AS user_id, SUM(amount) AS total_received
    FROM Transaction GROUP BY paid_to
)
SELECT u.user_id, credit - COALESCE(p.total_paid,0) + COALESCE(r.total_received,0)
FROM Users u
LEFT JOIN paid p ON u.user_id = p.user_id        -- one row per user now
LEFT JOIN received r ON u.user_id = r.user_id    -- one row per user now
```

### Quick test before writing a JOIN:
```
Ask: "Can the column I'm joining TO have duplicate values?"
  YES → one-to-many → be careful
  NO  → one-to-one → safe

Ask: "Am I doing TWO one-to-many joins on the same base?"
  YES → pre-aggregate each in separate CTEs
  NO  → proceed normally
```

---

## ✅ Step 4: LEFT JOIN + WHERE Trap

**What to do:** After writing a LEFT JOIN, check if your WHERE clause references the RIGHT table.

**Why:** WHERE filters happen AFTER the join. NULL rows from the LEFT JOIN get filtered out, turning it into an inner join.

### ❌ WRONG:
```sql
FROM months m
LEFT JOIN Rides r ON m.month_no = MONTH(r.requested_at)
WHERE YEAR(r.requested_at) = 2020
-- Months with no rides have r.requested_at = NULL
-- NULL = 2020 is FALSE → row filtered out!
```

### ✅ CORRECT:
```sql
FROM months m
LEFT JOIN Rides r ON m.month_no = MONTH(r.requested_at)
                 AND YEAR(r.requested_at) = 2020
-- Condition in ON clause: non-matching rows still kept with NULLs
```

**Rule:** Conditions on the RIGHT table go in the ON clause, not WHERE.

---

## ✅ Step 5: Bi-directional Relationship Check

**What to do:** If a relationship table enforces ordering (like user1_id < user2_id), check BOTH directions when matching pairs.

**Why:** Pair (2,1) won't match row (1,2) if you only check one direction.

### ❌ WRONG:
```sql
-- Friendship stores (1,2) but not (2,1)
LEFT JOIN Friendship f
    ON uf.user1 = f.user1_id AND uf.user2 = f.user2_id
-- Pair (2,1) slips through as "not friends" — WRONG!
```

### ✅ CORRECT — Option A: Check both directions
```sql
LEFT JOIN Friendship f
    ON (uf.user1 = f.user1_id AND uf.user2 = f.user2_id)
    OR (uf.user1 = f.user2_id AND uf.user2 = f.user1_id)
```

### ✅ CORRECT — Option B: UNION ALL to normalize
```sql
WITH bi_friends AS (
    SELECT user1_id AS user_id, user2_id AS frnd_id FROM Friendship
    UNION ALL
    SELECT user2_id AS user_id, user1_id AS frnd_id FROM Friendship
)
-- Now every friendship appears from both sides
```

**When to use which:**
- Option A: when filtering OUT existing relationships (like "not friends")
- Option B: when you need to traverse relationships (like "find all friends' likes")

---

## ✅ Step 6: Handle NULLs After LEFT JOIN

**What to do:** After any LEFT JOIN, handle NULLs in two places:

### 6a: Arithmetic — use COALESCE
```sql
-- ❌ WRONG:
credit - paid_amount + received_amount
-- If paid_amount is NULL: 100 - NULL + 200 = NULL (entire result lost!)

-- ✅ CORRECT:
credit - COALESCE(paid_amount, 0) + COALESCE(received_amount, 0)
```

### 6b: Counting — use COUNT(column), not COUNT(*)
```sql
-- Users LEFT JOIN Orders:
-- | user_id | order_id |
-- | 1       | 101      |
-- | 1       | 102      |
-- | 2       | NULL     |  ← Bob has no orders

COUNT(*)        = 3  -- ❌ Counts Bob's NULL row as 1
COUNT(order_id) = 2  -- ✅ Skips NULL, correct count
```

**Rule:** After LEFT JOIN, always count a column from the RIGHT table to get correct zeros.

### 6c: SUM with LEFT JOIN
```sql
-- If all values are NULL, SUM returns NULL, not 0
SUM(amount) → could be NULL

-- Wrap in COALESCE:
COALESCE(SUM(amount), 0)
```

---

## ✅ Step 7: Deduplicate Source Data

**What to do:** If the problem says "no primary key" or "may contain duplicates," deduplicate FIRST.

**Why:** Duplicate rows inflate counts and sums.

### Example — Leetcodify Friends (LC 1917):
```sql
-- Listens table has no primary key — user could listen to same song twice on same day

-- ❌ WRONG: Use raw table
FROM Listens l1 JOIN Listens l2 ...
-- Duplicate listens inflate the shared song count

-- ✅ CORRECT: Deduplicate first
WITH dedup AS (
    SELECT DISTINCT user_id, song_id, day FROM Listens
)
FROM dedup l1 JOIN dedup l2 ...
```

**Also remember:** MySQL doesn't support COUNT(DISTINCT) in window functions. So if you need distinct counts with OVER(), deduplicate the data first or use GROUP BY + HAVING instead.

---

## ✅ Step 8: Generate Missing Periods

**What to do:** If the output needs every month/day even when there's no data, generate a sequence first.

**Why:** Months with no data won't appear if you only GROUP BY existing data.

### Pattern:
```sql
-- Generate months 1-12
WITH RECURSIVE months AS (
    SELECT 1 AS month_no
    UNION ALL
    SELECT month_no + 1 FROM months WHERE month_no < 12
)
-- LEFT JOIN your data onto it
SELECT m.month_no, COALESCE(SUM(amount), 0)
FROM months m LEFT JOIN data d ON m.month_no = MONTH(d.date)
GROUP BY m.month_no
```

**Important:** If your window functions need to look ahead (rolling averages), generate MORE rows than your output needs, then filter at the end.

```sql
-- Need output for months 1-10, but rolling 3-month window
-- Month 10's window needs months 11 and 12
-- Generate 1-12, filter to 1-10 at the end
WHERE month_no <= 10  -- in final SELECT
```

---

## ✅ Step 9: Window Functions vs GROUP BY

**What to do:** Choose the right aggregation approach.

### Use GROUP BY + HAVING when:
- You need to FILTER on the aggregate (HAVING COUNT >= 3)
- You want one row per group in the output
- You're counting distinct values (COUNT(DISTINCT) works in GROUP BY but NOT in window functions in MySQL)

### Use Window Functions when:
- You need the aggregate AND the individual row data together
- Rolling windows (ROWS BETWEEN)
- Ranking (ROW_NUMBER, DENSE_RANK)
- Running totals

### ❌ Common mistake: Window function producing duplicates
```sql
-- Window functions add values to rows but DON'T collapse them
SELECT user_id, page_id,
    COUNT(*) OVER(PARTITION BY user_id, page_id) AS cnt
-- If 3 rows match → you get 3 rows, each showing cnt=3
-- Need DISTINCT to collapse, or better yet, use GROUP BY
```

---

## ✅ Step 10: Final Checks

Before submitting, verify:
- [ ] ORDER BY if the problem requires it
- [ ] Column aliases match expected output names
- [ ] No trailing commas before FROM
- [ ] No typos in table/column names
- [ ] ROUND() if decimals are specified
- [ ] DISTINCT if duplicates are possible

---

## Quick Decision Flowchart

Follow steps in order (1 → 10). Each step maps to the section above.

```
Step 1: Read output first — what is ONE row?
  → (one invoice? one user? one month?)

Step 2: Trace each output column to its source table
  → Different grouping keys? → UNION ALL, then aggregate
  → Same key? → JOIN

Step 3: For every JOIN — is the join column unique?
  → Two+ one-to-many joins on same base? → Pre-aggregate in separate CTEs

Step 4: Using LEFT JOIN?
  → Move right-table conditions to ON clause (not WHERE)

Step 5: Relationship table with ordering (e.g. user1 < user2)?
  → Check both directions (OR in JOIN or UNION ALL)

Step 6: LEFT JOIN in query?
  → COALESCE for arithmetic
  → COUNT(column) not COUNT(*)

Step 7: Source table has no primary key / may have duplicates?
  → Deduplicate first (DISTINCT or GROUP BY)

Step 8: Output needs every month/day even with no data?
  → Generate sequence (recursive CTE), LEFT JOIN data

Step 9: Need to filter on an aggregate?
  → GROUP BY + HAVING (not window function)

Step 10: Final checks before submitting
  → ORDER BY, column names, ROUND(), DISTINCT, etc.
```
