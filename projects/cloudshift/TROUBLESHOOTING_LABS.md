# CloudShift — Complete Troubleshooting Labs

Run all scenarios from the repository root:

```bash
cd ~/Downloads/cloudshift
```

## One-Time Setup

```bash
docker compose up --build -d
docker compose ps
```

Seed the base data if needed:

```bash
docker compose exec api python -m scripts.seed_database
```

Confirm:

```bash
bash scripts/smoke_test.sh
```

> Use the scenarios in this exact order. Each scenario includes a recovery step before moving to the next.

---

# Scenario 01 — Bad Environment Variable

## Break

```bash
docker compose -f docker-compose.yml   -f scenarios/01-bad-environment-variable/broken.compose.yml   up -d --force-recreate api
```

## Diagnose

```bash
sh scenarios/01-bad-environment-variable/diagnose.sh
```

Expected root cause:

```text
API DB_NAME=cloudshift_production
Actual database=cloudshift
```

## Fix

```bash
docker compose -f docker-compose.yml   -f scenarios/01-bad-environment-variable/fixed.compose.yml   up -d --force-recreate api
```

## Verify

```bash
curl -i http://localhost:8000/health
bash scripts/smoke_test.sh
```

---

# Scenario 02 — API Timeout

## Break

```bash
docker compose -f docker-compose.yml   -f scenarios/02-api-timeout/broken.compose.yml   up -d --force-recreate api shipping
```

## Diagnose

```bash
sh scenarios/02-api-timeout/diagnose.sh 1
```

Expected:

```text
Shipping direct ~4s
CloudShift timeout ~1s
CloudShift -> HTTP 504
```

## Fix

```bash
docker compose -f docker-compose.yml   -f scenarios/02-api-timeout/fixed.compose.yml   up -d --force-recreate api shipping
```

## Verify

```bash
curl -i http://localhost:8000/orders/1/shipping-quote
```

---

# Scenario 03 — Incorrect HTTP Status Handling

## Break

```bash
docker compose -f docker-compose.yml   -f scenarios/03-incorrect-http-status/broken.compose.yml   up -d --force-recreate api
```

## Diagnose

```bash
curl -i http://localhost:8000/orders/999999
docker compose logs --tail=50 api | grep bad_http_status_mode
```

Broken result:

```text
HTTP 200
{"error":"Order not found", ...}
```

## Fix

```bash
docker compose -f docker-compose.yml   -f scenarios/03-incorrect-http-status/fixed.compose.yml   up -d --force-recreate api
```

## Verify

```bash
curl -i http://localhost:8000/orders/999999
```

Expected `HTTP 404`.

---

# Scenario 04 — Container Configuration

## Break

```bash
docker compose -f docker-compose.yml   -f scenarios/04-container-configuration/broken.compose.yml   up -d --force-recreate api
```

## Diagnose

```bash
sh scenarios/04-container-configuration/diagnose.sh
```

Expected:

```text
Container: running
Internal loopback request: HTTP 200
Host request: fails
Process: --host 127.0.0.1
```

## Fix

```bash
docker compose -f docker-compose.yml   -f scenarios/04-container-configuration/fixed.compose.yml   up -d --force-recreate api
```

## Verify

```bash
curl -i http://localhost:8000/health
```

---

# Scenario 05 — Database Query Bottleneck

If the large dataset does not exist yet:

```bash
docker compose exec api python -m scripts.bulk_seed   --customers 500 --orders 100000
```

## Break

Remove the performance index:

```bash
docker compose exec -T db   psql -U cloudshift -d cloudshift   < scenarios/05-database-bottleneck/rollback.sql
```

## Diagnose

```bash
docker compose exec api python -m scripts.analyze_customer_orders   --customer-id 3 --runs 20
```

Look for `Seq Scan on orders`.

## Fix

```bash
docker compose exec -T db   psql -U cloudshift -d cloudshift   < scenarios/05-database-bottleneck/fix.sql
```

## Verify

```bash
docker compose exec api python -m scripts.analyze_customer_orders   --customer-id 3 --runs 20
```

Look for `Index Scan using idx_orders_customer_created_at`.

Historical measured result:

```text
DB execution: 25.068 ms -> 13.933 ms
Average:      70.86 ms  -> 64.00 ms
P95:          99.81 ms  -> 83.71 ms
```

---

# Scenario 06 — API Authentication Failure

## Break

```bash
docker compose -f docker-compose.yml   -f scenarios/06-api-authentication-failure/broken.compose.yml   up -d --force-recreate api shipping
```

## Diagnose

```bash
sh scenarios/06-api-authentication-failure/diagnose.sh 1
```

Expected:

```text
Upstream shipping -> HTTP 401
CloudShift log -> shipping_upstream_auth_failure
API token -> wrong-demo-token
```

## Fix

```bash
docker compose -f docker-compose.yml   -f scenarios/06-api-authentication-failure/fixed.compose.yml   up -d --force-recreate api shipping
```

## Verify

```bash
curl -i http://localhost:8000/orders/1/shipping-quote
```

Expected `HTTP 200`.

---

# Scenario 07 — Traffic Spike / DB Connection Pool Saturation

## Break

```bash
docker compose -f docker-compose.yml   -f scenarios/07-traffic-connection-pool/broken.compose.yml   up -d --force-recreate api
```

## Diagnose

```bash
sh scenarios/07-traffic-connection-pool/diagnose.sh
```

Record:

- success count
- 503 count
- average
- P95
- P99
- throughput
- `db_pool_timeout` logs

## Fix

```bash
docker compose -f docker-compose.yml   -f scenarios/07-traffic-connection-pool/fixed.compose.yml   up -d --force-recreate api
```

## Verify

Run the same command again:

```bash
sh scenarios/07-traffic-connection-pool/diagnose.sh
```

Compare the exact same workload.

---

# Final Recovery

Return all services to the normal healthy configuration:

```bash
docker compose up -d --force-recreate api shipping
```

Then:

```bash
bash scripts/smoke_test.sh
curl -i http://localhost:8000/orders/1/shipping-quote
docker compose ps
```

At this point the local troubleshooting phase is complete.

## Portfolio Scoreboard

| # | Scenario | Primary skill |
|---|---|---|
| 01 | Bad environment variable | Configuration + DB connectivity |
| 02 | API timeout | Dependency latency + HTTP 504 |
| 03 | Incorrect HTTP status | REST/HTTP semantics |
| 04 | Container configuration | Docker networking/runtime |
| 05 | Database bottleneck | SQL + indexing + EXPLAIN ANALYZE |
| 06 | API authentication failure | Headers/tokens + 401 diagnosis |
| 07 | Traffic/pool saturation | Concurrency + capacity + DB pooling |

After completing these seven, the next project phase is Google Cloud migration.
