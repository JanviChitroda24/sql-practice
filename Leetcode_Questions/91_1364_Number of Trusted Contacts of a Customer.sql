-- 1364. Number of Trusted Contacts of a Customer
-- https://leetcode.ca/all/1364.html

-- Table: Customers

-- +---------------+---------+
-- | Column Name   | Type    |
-- +---------------+---------+
-- | customer_id   | int     |
-- | customer_name | varchar |
-- | email         | varchar |
-- +---------------+---------+
-- customer_id is the primary key for this table.
-- Each row of this table contains the name and the email of a customer of an online shop.
 

-- Table: Contacts

-- +---------------+---------+
-- | Column Name   | Type    |
-- +---------------+---------+
-- | user_id       | id      |
-- | contact_name  | varchar |
-- | contact_email | varchar |
-- +---------------+---------+
-- (user_id, contact_email) is the primary key for this table.
-- Each row of this table contains the name and email of one contact of customer with user_id.
-- This table contains information about people each customer trust. The contact may or may not exist in the Customers table.

 

-- Table: Invoices

-- +--------------+---------+
-- | Column Name  | Type    |
-- +--------------+---------+
-- | invoice_id   | int     |
-- | price        | int     |
-- | user_id      | int     |
-- +--------------+---------+
-- invoice_id is the primary key for this table.
-- Each row of this table indicates that user_id has an invoice with invoice_id and a price.
 

-- Write an SQL query to find the following for each invoice_id:

-- customer_name: The name of the customer the invoice is related to.
-- price: The price of the invoice.
-- contacts_cnt: The number of contacts related to the customer.
-- trusted_contacts_cnt: The number of contacts related to the customer and at the same time they are customers to the shop. (i.e His/Her  email exists in the Customers table.)
-- Order the result table by invoice_id.

-- The query result format is in the following example:Programming

-- Customers table:
-- +-------------+---------------+--------------------+
-- | customer_id | customer_name | email              |
-- +-------------+---------------+--------------------+
-- | 1           | Alice         | alice@leetcode.com |
-- | 2           | Bob           | bob@leetcode.com   |
-- | 13          | John          | john@leetcode.com  |
-- | 6           | Alex          | alex@leetcode.com  |
-- +-------------+---------------+--------------------+
-- Contacts table:
-- +-------------+--------------+--------------------+
-- | user_id     | contact_name | contact_email      |
-- +-------------+--------------+--------------------+
-- | 1           | Bob          | bob@leetcode.com   |
-- | 1           | John         | john@leetcode.com  |
-- | 1           | Jal          | jal@leetcode.com   |
-- | 2           | Omar         | omar@leetcode.com  |
-- | 2           | Meir         | meir@leetcode.com  |
-- | 6           | Alice        | alice@leetcode.com |
-- +-------------+--------------+--------------------+
-- Invoices table:
-- +------------+-------+---------+
-- | invoice_id | price | user_id |
-- +------------+-------+---------+
-- | 77         | 100   | 1       |
-- | 88         | 200   | 1       |
-- | 99         | 300   | 2       |
-- | 66         | 400   | 2       |
-- | 55         | 500   | 13      |
-- | 44         | 60    | 6       |
-- +------------+-------+---------+
-- Result table:
-- +------------+---------------+-------+--------------+----------------------+
-- | invoice_id | customer_name | price | contacts_cnt | trusted_contacts_cnt |
-- +------------+---------------+-------+--------------+----------------------+
-- | 44         | Alex          | 60    | 1            | 1                    |
-- | 55         | John          | 500   | 0            | 0                    |
-- | 66         | Bob           | 400   | 2            | 0                    |
-- | 77         | Alice         | 100   | 3            | 2                    |
-- | 88         | Alice         | 200   | 3            | 2                    |
-- | 99         | Bob           | 300   | 2            | 0                    |
-- +------------+---------------+-------+--------------+----------------------+
-- Alice has three contacts, two of them are trusted contacts (Bob and John).
-- Bob has two contacts, none of them is a trusted contact.
-- Alex has one contact and it is a trusted contact (Alice).
-- John doesn't have any contacts.

WITH customer_contact AS (
    SELECT cnt.user_id, COUNT(cnt.contact_email) AS contacts_cnt,
        COUNT(
            CASE 
                WHEN cus.email IS NOT NULL
                THEN 1
                ELSE NULL
            END
        ) AS trusted_contacts_cnt
    FROM Contacts cnt LEFT JOIN Customers cus
        ON cnt.contact_email = cus.email
    GROUP BY cnt.user_id
)
SELECT i.invoice_id, c.customer_name, i.price, 
    COALESCE(cc.contacts_cnt,0) AS contacts_cnt, 
    COALESCE(cc.trusted_contacts_cnt,0) AS trusted_contacts_cnt
FROM Invoices i LEFT JOIN Customers c
        ON i.user_id =  c.customer_id
    LEFT JOIN customer_contact cc 
        ON i.user_id =  cc.user_id
ORDER BY i.invoice_id;

-- **SQL Problem-Solving Checklist**

-- **Before writing any query:**

-- 1. **Read the output** — what is one row? (one invoice? one user? one month?)
-- 2. **Identify the tables needed** — which tables have the data for each output column?
-- 3. **Check join types** — for each join, ask: "Is the column I'm joining TO unique?" If no → one-to-many → rows will multiply.
-- 4. **Count one-to-many joins** — if TWO or more one-to-many joins on the same base table → **pre-aggregate each in separate CTEs first**.
-- 5. **Check join direction** — do I need all rows from one side? → LEFT JOIN. Does the WHERE clause reference the right table? → move it to ON clause.
-- 6. **Check for bi-directional relationships** — does the relationship table enforce ordering (user1 < user2)? → check both directions.
-- 7. **Handle NULLs** — LEFT JOIN produces NULLs → COALESCE for arithmetic, COUNT(column) not COUNT(*).
-- 8. **Check for duplicates in source data** — "no primary key" → deduplicate first with GROUP BY.
-- 9. **Add ORDER BY** if the problem requires it.