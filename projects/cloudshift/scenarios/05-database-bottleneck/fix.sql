-- Scenario 05 fix:
-- Optimize customer order-history lookups that filter by customer_id
-- and sort newest-first by created_at.

CREATE INDEX IF NOT EXISTS idx_orders_customer_created_at
ON orders (customer_id, created_at DESC);

ANALYZE orders;
