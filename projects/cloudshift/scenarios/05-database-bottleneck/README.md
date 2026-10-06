# Scenario 05 — Database Query Bottleneck

## Measured Environment

- Customers: 502
- Orders: 100,002
- Order items: 100,002
- Database size: 22 MB
- Heavy customer ID: 3
- Rows returned: 25,000

## Recreate the Broken State

```bash
docker compose exec -T db   psql -U cloudshift -d cloudshift   < scenarios/05-database-bottleneck/rollback.sql
```

Then:

```bash
docker compose exec api python -m scripts.analyze_customer_orders   --customer-id 3 --runs 20
```

Measured pre-fix evidence from the original investigation:

```text
Seq Scan on orders
Rows Removed by Filter: 75002
PostgreSQL execution: 25.068 ms
Average: 70.86 ms
P95: 99.81 ms
```

## Root Cause

The query filtered by `customer_id` and sorted by `created_at DESC`, but no index supported that access pattern.

## Fix

```bash
docker compose exec -T db   psql -U cloudshift -d cloudshift   < scenarios/05-database-bottleneck/fix.sql
```

Verify with the exact same benchmark.

Measured post-fix result:

```text
Index Scan using idx_orders_customer_created_at
PostgreSQL execution: 13.933 ms
Average: 64.00 ms
P95: 83.71 ms
```

Database execution time improved by about 44%.

## Additional Finding

The endpoint still returns 25,000 rows. Indexing fixes the access path, but API pagination is the next optimization layer.
