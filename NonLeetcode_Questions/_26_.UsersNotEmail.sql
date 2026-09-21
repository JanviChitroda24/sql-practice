-- You have a table called emails:

-- emails
-- ├── email_id        INT (PK)
-- ├── sender_id       INT
-- ├── recipient_id    INT
-- ├── sent_date       DATE
-- ├── subject         VARCHAR(255)

-- Write a query using a CROSS JOIN to find all possible pairs of users who have never emailed each other 
-- (neither direction). Assume you have a users table with user_id INT (PK). 
-- Return user_a, user_b where user_a < user_b to avoid duplicates. 
-- Exclude pairs where a user is paired with themselves.

WITH users_cross_join AS (
    SELECT u1.user_id AS user_a, u2.user_id AS user_b
    FROM users u1 CROSS JOIN users u2
    WHERE u1.user_id < u2.user_id
)
SELECT user_a, user_b
FROM users_cross_join
WHERE NOT EXISTS (
    SELECT 1
    FROM emails e
    WHERE (user_a=e.sender_id AND user_b=e.recipient_id) OR 
        (user_b=e.sender_id AND user_a=e.recipient_id)
)
