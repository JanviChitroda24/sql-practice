-- **Q15**

-- You have two tables:

-- ```
-- subscriptions
-- ├── subscription_id   INT (PK)
-- ├── user_id           INT
-- ├── plan_type         VARCHAR(20)
-- ├── start_date        DATE
-- ├── end_date          DATE (nullable — NULL means still active)

-- payments
-- ├── payment_id        INT (PK)
-- ├── user_id           INT
-- ├── payment_date      DATE
-- ├── amount            DECIMAL(10,2)
-- ├── status            VARCHAR(20)
-- ```

-- Write a query that finds users whose subscription is currently active (end_date IS NULL) 
--     but have at least one failed payment (status = 'failed') in the last 60 days. 
-- For each such user, return user_id, plan_type, 
--     total_failed_payments (count in last 60 days), 
--     total_failed_amount (sum in last 60 days), and 
--     last_successful_payment_date (their most recent payment where status = 'success', across all time). Today's date is '2026-09-16'.

SELECT s.user_id, s.plan_type,
    SUM(CASE 
        WHEN p.status = 'failed' AND p.payment_date >= DATE_SUB('2026-09-16', INTERVAL 60 DAY)
        THEN 1
    END) AS total_failed_payments,
    SUM(CASE 
        WHEN p.status = 'failed' AND p.payment_date >= DATE_SUB('2026-09-16', INTERVAL 60 DAY)
        THEN p.amount
    END) AS total_failed_amount,
    MAX(CASE 
        WHEN p.status = 'success'
        THEN payment_date
    END) AS last_successful_payment_date
FROM subscriptions s JOIN payments p
    ON s.user_id = p.user_id
WHERE s.end_date IS NULL 
    AND EXISTS (
        SELECT 1
        FROM payments py
        WHERE s.user_id = py.user_id AND
            py.status = 'failed' AND
            py.payment_date >= DATE_SUB('2026-09-16', INTERVAL 60 DAY)
    )
GROUP BY s.user_id, plan_type;


-- OPTIMIZED
SELECT s.user_id, s.plan_type,
    SUM(CASE 
        WHEN p.status = 'failed' AND p.payment_date >= DATE_SUB('2026-09-16', INTERVAL 60 DAY)
        THEN 1
    END) AS total_failed_payments,
    SUM(CASE 
        WHEN p.status = 'failed' AND p.payment_date >= DATE_SUB('2026-09-16', INTERVAL 60 DAY)
        THEN p.amount
    END) AS total_failed_amount,
    MAX(CASE 
        WHEN p.status = 'success'
        THEN payment_date
    END) AS last_successful_payment_date
FROM subscriptions s JOIN payments p
    ON s.user_id = p.user_id
WHERE s.end_date IS NULL 
GROUP BY s.user_id, plan_type
HAVING total_failed_payments>0;


