-- We have a retail client with order events landing in a bronze table:

-- ```
-- orders_raw(order_id, customer_id, status, amount, event_ts, _ingested_at)
-- ```

-- An order can have multiple status events over its lifecycle. 
-- The upstream ingestion occasionally reprocesses files.

-- Write the query that produces the silver table: 
--     one row per order with its current status, amount, and the timestamp of that latest event.

-----------------------------
WITH orders_rank AS (
    SELECT order_id, customer_id, status, amount, event_ts, _ingested_at,
        ROW_NUMBER() OVER(PARTITION BY order_id ORDER BY event_ts DESC, _ingested_at DESC) AS order_rnk
    FROM orders_raw
)
SELECT order_id, customer_id, status, amount, event_ts, _ingested_at
FROM orders_rank
WHERE order_rnk=1;

-- Since we are asked to find latest status of an order, we need to partition by order and order by event_ts 
-- to get latest order status 
-- and since there are multiple reprocesses so we wil lhave depulictes and we also order by ingested timestamp
-- ROW_NUMBER is what removes the duplicates, 
--     as it always returns exactly one row per order_id, even when rows are identical.


