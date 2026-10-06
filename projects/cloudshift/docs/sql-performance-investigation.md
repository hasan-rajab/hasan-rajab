# SQL Performance Investigation

## Objective

Create a large enough local dataset to reproduce a realistic database lookup bottleneck before migrating to Cloud SQL.

This phase intentionally leaves `orders.customer_id` without an application-defined index. The investigation should establish whether PostgreSQL uses a sequential scan and how query latency changes as the `orders` table grows.

## 1. Generate the dataset

```bash
docker compose exec api python -m scripts.bulk_seed   --customers 500   --orders 100000
```

The script prints a `Heavy customer ID`. Record it here:

- Heavy customer ID:

## 2. Verify database scale

```bash
docker compose exec api python -m scripts.db_stats
```

Record:

- Customers:
- Orders:
- Order items:
- Database size:

## 3. Inspect indexes

```bash
docker compose exec db psql -U cloudshift -d cloudshift
```

Then:

```sql
\d orders
```

and:

```sql
SELECT
    indexname,
    indexdef
FROM pg_indexes
WHERE tablename = 'orders';
```

## 4. Run EXPLAIN ANALYZE + latency benchmark

Replace `<ID>` with the heavy customer ID:

```bash
docker compose exec api python -m scripts.analyze_customer_orders   --customer-id <ID>   --runs 20
```

Look specifically for:

- `Seq Scan on orders`
- rows scanned
- rows returned
- sort operation
- planning time
- execution time

## 5. Record the pre-index result

- Query plan:
- Rows returned:
- Average:
- Median:
- P95:
- Fastest:
- Slowest:

## Do not add the index yet

The pre-index evidence is needed for the troubleshooting scenario. We will create the fix only after capturing the slow plan and latency.
