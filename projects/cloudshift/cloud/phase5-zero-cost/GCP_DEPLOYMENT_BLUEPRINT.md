# CloudShift — Google Cloud Deployment Blueprint

This document describes the target Google Cloud migration without creating billable resources.

## Target architecture

```text
Internet
   |
   v
Cloud Run: Frontend
   |
   v
Cloud Run: FastAPI
   |                    |
   v                    v
Cloud SQL PostgreSQL    Cloud Run: Shipping dependency

Secret Manager
   +-- DB password
   +-- shipping token

Artifact Registry
   +-- frontend image
   +-- API image
   +-- shipping image

Cloud Logging / Monitoring
   +-- request logs
   +-- application logs
   +-- latency/error metrics
```

## Local-to-GCP mapping

| Local component | Target GCP component |
|---|---|
| Nginx frontend container | Cloud Run service |
| FastAPI container | Cloud Run service |
| PostgreSQL container | Cloud SQL for PostgreSQL |
| Mock shipping container | Cloud Run service |
| Docker images | Artifact Registry |
| `.env` credentials | Secret Manager |
| Docker logs | Cloud Logging |
| App/load metrics | Cloud Monitoring + validation |

## Cloud Run readiness already validated locally

The API container:

- listens on `0.0.0.0`
- reads the runtime port from `$PORT`
- is stateless
- keeps persistent relational data outside the container
- uses environment-driven configuration
- exposes `/health`
- exposes `/metrics`
- uses explicit downstream timeouts
- supports database connection pooling
- returns correct HTTP status codes

## Cloud SQL migration design

A live deployment would:

1. Provision PostgreSQL in the same region as Cloud Run.
2. Create the `cloudshift` database and application user.
3. Attach Cloud SQL to the FastAPI Cloud Run service.
4. Store the DB password in Secret Manager.
5. Connect using the Cloud SQL integration / Unix socket.
6. Run schema initialization and seed/migration as a one-off Cloud Run Job.
7. Re-run smoke tests and load tests against the deployed API.

## Security design

- dedicated Cloud Run service account
- least-privilege Cloud SQL Client access
- Secret Manager access only for required secrets
- no secrets committed to Git
- explicit CORS origin
- sensitive configuration outside container images

## Observability design

Track:

- request count
- HTTP 4xx/5xx
- P50/P95/P99 latency
- instance count
- CPU/memory
- database connection utilization
- database query latency
- downstream latency
- timeout/auth failures

## Existing local baseline

```text
Requests:       1000
Concurrency:    50
Successful:     1000
Failed:         0
Error rate:     0.00%
Average:        615.01 ms
Median:         589.25 ms
P95:            1090.02 ms
P99:            1449.36 ms
Throughput:     78.83 req/s
```

## Accurate portfolio wording

Until a live Google Cloud deployment is completed, use:

> Designed and validated a deployment-ready Google Cloud migration architecture for a containerized FastAPI/PostgreSQL workload, including Cloud Run runtime compatibility, Cloud SQL connectivity design, IAM, secret management, observability, and migration validation procedures.

Do not claim that Cloud Run or Cloud SQL were deployed unless they actually were.
