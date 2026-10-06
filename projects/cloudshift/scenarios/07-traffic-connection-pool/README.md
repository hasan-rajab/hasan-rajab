# Scenario 07 — Traffic Spike / Database Connection Pool Saturation

## Customer Report

> "The API works under normal traffic, but during a traffic spike some database-backed requests return 503."

## Break

```bash
docker compose -f docker-compose.yml   -f scenarios/07-traffic-connection-pool/broken.compose.yml   up -d --force-recreate api
```

Broken configuration:

```text
DB_POOL_SIZE=2
DB_MAX_OVERFLOW=0
DB_POOL_TIMEOUT=0.2
DB_TEST_DELAY_SECONDS=0.5
```

Run:

```bash
sh scenarios/07-traffic-connection-pool/diagnose.sh
```

The test sends 200 requests at concurrency 50 to a controlled DB-backed diagnostic endpoint. With only two connections and a 0.2-second pool wait budget, some requests should return `503 Database connection pool exhausted`.

## Root Cause

Request concurrency exceeds the database connection capacity available to the application. The service remains up, but requests queue for database connections and exceed the pool timeout.

## Fix

```bash
docker compose -f docker-compose.yml   -f scenarios/07-traffic-connection-pool/fixed.compose.yml   up -d --force-recreate api
```

Re-run:

```bash
sh scenarios/07-traffic-connection-pool/diagnose.sh
```

Compare success rate, status distribution, P95/P99 latency, and throughput.

## Cloud Migration Relevance

When this project moves to Cloud Run + Cloud SQL, connection-pool sizing must be considered together with Cloud Run instance concurrency and maximum instance count. Scaling the application without controlling database connections can move the bottleneck into the database.
