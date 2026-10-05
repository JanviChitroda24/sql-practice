-- A client has a customer dimension table, 
--     and every day they send a full snapshot of all their active customers:

-- dim_customer(customer_id, name, email, city, is_active, updated_at)
-- customer_feed(customer_id, name, email, city, feed_date)

-- Write the load that keeps dim_customer in sync with the feed. 
--     If a customer's name, email, or city changed, update them. 
--     If a customer is new, add them. 
--     If a customer is missing from today's feed, mark them inactive. 
--     We need to keep their history, so don't delete them.

--databricks version
MERGE INTO dim_customer AS target
USING customer_feed AS source
ON target.customer_id = source.customer_id
WHEN MATCHED AND (
                (NOT (source.name  <=> target.name)
                OR NOT (source.email <=> target.email)
                OR NOT (source.city  <=> target.city)
                OR target.is_active = false))
    THEN UPDATE SET 
                target.name = source.name,
                target.email = source.email,
                target.city = source.city,
                target.is_active = true,
                target.updated_at = current_timestamp()
WHEN NOT MATCHED 
    THEN 
        INSERT (customer_id, name, email, city, is_active, updated_at) 
        VALUES (source.customer_id, source.name, source.email, source.city, True, current_timestamp())
WHEN NOT MATCHED BY SOURCE AND target.is_active = true
    THEN UPDATE SET
        target.is_active = false,
        target.updated_at = current_timestamp();

-- mysql version
INSERT INTO dim_customer (customer_id, name, email, city, is_active, updated_at)
SELECT customer_id, name, email, city, true, NOW() FROM customer_feed
ON DUPLICATE KEY UPDATE
  name = VALUES(name), email = VALUES(email), city = VALUES(city),
  is_active = true, updated_at = NOW();