# CloudShift Migration Story

## Customer Problem

GulfSupply Co. operates a legacy internal application that cannot reliably support increasing traffic.

The objective is not a full application rewrite. The migration strategy preserves the working application while reducing infrastructure coupling and improving operational resilience.

## Stage 1 — Assess

Baseline architecture:

```text
Frontend → FastAPI → PostgreSQL
```

Risks identified:

- single-host failure domain
- limited scalability
- coupled database/runtime
- weak observability
- manual configuration
- no repeatable troubleshooting evidence

## Stage 2 — Containerize

The application was separated into:

- frontend container
- FastAPI API container
- PostgreSQL container
- downstream shipping service

Docker Compose produced a reproducible local environment.

## Stage 3 — Establish Baseline

Performance test:

```text
1,000 requests
50 concurrency
0% failure rate
P95 1090.02 ms
78.83 requests/second
```

This created a measured reference point before architectural changes.

## Stage 4 — Troubleshoot Before Migration

Seven incidents were implemented and resolved before cloud migration planning.

This avoids migrating unknown operational weaknesses into the target environment.

## Stage 5 — Cloud Runtime Readiness

The API container was adapted to:

- use the runtime `$PORT`
- listen on `0.0.0.0`
- externalize state
- use externalized configuration
- support Cloud SQL Unix-socket design
- use secret-manager-compatible environment injection

A local Cloud Run-style runtime simulation processed 1,000 requests with zero failures.

## Stage 6 — Add NoSQL and Observability

Firestore-emulator audit storage was added without replacing PostgreSQL.

The system also gained:

- structured JSON logging
- Prometheus
- Grafana
- dependency metrics
- Firestore write metrics

## Stage 7 — Validate Troubleshooting Operationally

All seven incidents were re-run against the observability layer.

Broken-state and fixed-state evidence was persisted for each case.

## Target Production Migration

When a funded GCP environment is available:

```text
Container Images → Artifact Registry
FastAPI → Cloud Run
Frontend → Cloud Run
PostgreSQL → Cloud SQL
Audit Documents → Firestore
Secrets → Secret Manager
Logs/Metrics → Cloud Logging / Monitoring
```

## Deployment Status

The architecture and runtime are deployment-ready, but this portfolio repository intentionally does **not** claim a live Cloud Run or Cloud SQL deployment.

This distinction keeps the project technically honest while still demonstrating the complete migration design and validation workflow.
