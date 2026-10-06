# Phase 7 — Cloud-Style Troubleshooting Validation

Phase 7 re-runs all seven CloudShift incidents against the Phase 6 observability stack.

## Start

Phase 6 must already be running.

```bash
bash cloud/phase7/00-preflight.sh
```

Run all seven scenarios sequentially:

```bash
bash cloud/phase7/run-all.sh
```

Evidence is captured automatically in:

```text
cloud/phase7/evidence/
```

At the end, `run-all.sh` also creates:

```text
cloud/phase7/PHASE7_RESULTS.md
```

Keep Grafana open while the incidents run:

```text
http://localhost:3001
```

Dashboard:

```text
CloudShift → CloudShift Operations
```

## What Phase 7 proves

Phase 4 demonstrated low-level troubleshooting with Docker, Linux, HTTP and SQL.

Phase 7 demonstrates operational troubleshooting using:

- structured JSON logs
- service health and availability
- Prometheus metrics
- Grafana dashboards
- Firestore audit events
- query-plan analysis
- repeatable load testing
- before/after evidence

## Scenario sequence

1. Bad environment variable
2. API timeout
3. Incorrect HTTP status
4. Container configuration
5. Database query bottleneck
6. API authentication failure
7. Connection-pool saturation

Each script restores a healthy state before the next scenario.
