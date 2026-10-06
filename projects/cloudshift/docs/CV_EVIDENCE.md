# CloudShift — CV evidence and reproduction

This public source snapshot contains the FastAPI/PostgreSQL application, Firestore-emulator audit implementation, scenario scripts and historical logs supporting the IBM CV.

Source snapshot: `ffc7731db9703298e5cf19d119d346e03fd45a16`. The Phase 7 summary is dated 11 August 2026. Publishing these records is not a fresh rerun or independent certification.

## What the numbers mean

The CV's **27.79 ms → 12.38 ms** values are rounded PostgreSQL **Execution Time** measurements from one before/after `EXPLAIN (ANALYZE, BUFFERS)` pair. They are not HTTP latency, averages of repeated query plans, or a guarantee of future speed.

| Measurement | Before index | After index |
| --- | ---: | ---: |
| PostgreSQL execution time | 27.790 ms | 12.377 ms |
| Result rows | 25,000 | 25,000 |
| Client-side average across 20 query fetches | 142.26 ms | 66.38 ms |
| Client-side P95 across 20 query fetches | 246.62 ms | 86.67 ms |

The index is `(customer_id, created_at DESC)`. The raw plans show sequential scan plus sort before, and index scan after. Earlier project documents report a different measurement pair, 25.068 ms → 13.933 ms; those are an earlier run and must not be mixed with the Phase 7 figures used in the CV.

### Raw before output

```text
Query Plan
----------
Sort  (cost=3767.14..3830.22 rows=25235 width=24) (actual time=21.007..25.709 rows=25000 loops=1)
  Sort Key: created_at DESC
  Sort Method: quicksort  Memory: 2006kB
  Buffers: shared hit=675
  ->  Seq Scan on orders  (cost=0.00..1922.06 rows=25235 width=24) (actual time=0.021..12.458 rows=25000 loops=1)
        Filter: (customer_id = '3'::smallint)
        Rows Removed by Filter: 75005
        Buffers: shared hit=672
Planning:
  Buffers: shared hit=57
Planning Time: 2.084 ms
Execution Time: 27.790 ms

Customer Order Query Benchmark
------------------------------
Customer ID:     3
Rows returned:   25,000
Runs:            20
Average:         142.26 ms
Median:          128.39 ms
P95:             246.62 ms
Fastest:         86.61 ms
Slowest:         248.80 ms
```

### Raw after output

```text
Query Plan
----------
Index Scan using idx_orders_customer_created_at on orders  (cost=0.42..3037.43 rows=25258 width=24) (actual time=0.078..11.024 rows=25000 loops=1)
  Index Cond: (customer_id = '3'::smallint)
  Buffers: shared hit=24867 read=97
Planning:
  Buffers: shared hit=80 read=1
Planning Time: 2.859 ms
Execution Time: 12.377 ms

Customer Order Query Benchmark
------------------------------
Customer ID:     3
Rows returned:   25,000
Runs:            20
Average:         66.38 ms
Median:          62.06 ms
P95:             86.67 ms
Fastest:         48.31 ms
Slowest:         98.18 ms
```

Original files: [before](../cloud/phase7/evidence/05-db-broken-query.txt), [after](../cloud/phase7/evidence/05-db-fixed-query.txt). Benchmark code: [analyze_customer_orders.py](../scripts/analyze_customer_orders.py). Data generation: [bulk_seed.py](../scripts/bulk_seed.py). Schema: [models.py](../app/models.py). Index change: [fix.sql](../scenarios/05-database-bottleneck/fix.sql).

## Seven documented troubleshooting scenarios

| Scenario | Broken-state evidence | Fixed-state evidence |
| --- | --- | --- |
| Database configuration | [startup/database error](../cloud/phase7/evidence/01-bad-env-broken.txt) | [healthy API/database](../cloud/phase7/evidence/01-bad-env-fixed.txt) |
| Downstream timeout | [shipping timeout/504](../cloud/phase7/evidence/02-timeout-broken.txt) | [shipping success/200](../cloud/phase7/evidence/02-timeout-fixed.txt) |
| Incorrect HTTP status | [missing order reported as 200](../cloud/phase7/evidence/03-http-status-broken.txt) | [missing order reported as 404](../cloud/phase7/evidence/03-http-status-fixed.txt) |
| Container binding | [API unreachable](../cloud/phase7/evidence/04-container-broken.txt) | [API reachable](../cloud/phase7/evidence/04-container-fixed.txt) |
| Query bottleneck | [sequential scan and sort](../cloud/phase7/evidence/05-db-broken-query.txt) | [composite index scan](../cloud/phase7/evidence/05-db-fixed-query.txt) |
| Dependency authentication | [upstream 401 / API 502](../cloud/phase7/evidence/06-auth-broken.txt) | [shipping success/200](../cloud/phase7/evidence/06-auth-fixed.txt) |
| Connection-pool saturation | [6 successes, 194 failures](../cloud/phase7/evidence/07-pool-broken-load.txt) | [200 successes, 0 failures](../cloud/phase7/evidence/07-pool-fixed-load.txt) |

The last pair uses 200 requests at concurrency 50. It demonstrates recovery of this synthetic workload, not unlimited capacity. Source: [Phase 7 summary](../cloud/phase7/PHASE7_RESULTS.md) and [scenario runner](../cloud/phase7/run-all.sh).

## Reproduce the SQL investigation locally

Requirements: Git, Docker Engine/Desktop with Compose v2; free ports 5432, 8000 and 9000. Use a dedicated local CloudShift lab, since the scenario deliberately removes and recreates the demonstration index.

```bash
git clone https://github.com/hasan-rajab/hasan-rajab.git
cd hasan-rajab/projects/cloudshift
bash scripts/reproduce_cv_sql.sh
```

The helper starts the existing local application, seeds a synthetic 100,000-order workload if needed, records the PostgreSQL version and row count, captures the query before/after indexing, and checks that both results return 25,000 rows. New outputs go into `reproduction-output/`; the historical logs remain unchanged.

Expect the same query, result count and indexing intervention. Exact timing and even the planner's choice can vary with CPU, memory, cache, PostgreSQL version and other load. Report your actual output; do not force a fixed timing or plan.

## Reproduce all seven scenarios and Firestore

The full observability exercise additionally needs Google Cloud CLI's Firestore emulator and Java 21+. These are local emulation requirements; no live Cloud Run/Cloud SQL deployment is claimed.

From the same source directory:

```bash
bash cloud/phase6/00-firestore-preflight.sh
bash cloud/phase6/01-start-firestore.sh
bash cloud/phase6/02-start-stack.sh
bash cloud/phase6/03-seed.sh
bash cloud/phase6/04-generate-observability-data.sh
bash cloud/phase6/05-verify.sh
bash cloud/phase7/run-all.sh
```

Unlike the SQL helper, the original Phase 7 runner writes fresh results over its evidence paths. Preserve the historical snapshot before rerunning it. See the [observability runbook](../cloud/phase6/OBSERVABILITY_RUNBOOK.md) and [troubleshooting validation runbook](../cloud/phase7/TROUBLESHOOTING_VALIDATION_RUNBOOK.md).

## SQL and NoSQL implementation

- PostgreSQL connection/session configuration: [database.py](../app/database.py).
- Relational tables and relationships: [models.py](../app/models.py).
- Firestore audit documents, write/read code: [audit.py](../app/audit.py).
- Emulator/observability configuration: [docker-compose.phase6.yml](../cloud/phase6/docker-compose.phase6.yml).
- Recorded Firestore audit events: the scenario evidence above.

All customers, orders and audit events are fictional lab data. Example credentials are non-secret local-development defaults. Google Cloud is a migration target/reference architecture; the demonstrated environment is local.
