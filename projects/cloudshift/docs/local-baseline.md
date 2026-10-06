# Local Legacy Baseline

## Environment

- Runtime: Docker Desktop on local Mac
- API: FastAPI
- Database: PostgreSQL
- Frontend: Nginx static frontend
- Deployment: Docker Compose
- Test endpoint: `GET /products`

## Smoke Test Result

All smoke tests passed:

- `/health`: healthy
- `/products`: reachable
- `/customers/1`: reachable
- missing order: HTTP 404
- `/metrics`: Prometheus metrics present

## Baseline Test — 1,000 Requests / 50 Concurrency

Command:

```bash
docker compose exec api python scripts/load_test.py   --requests 1000   --concurrency 50
```

Measured result:

| Metric | Result |
|---|---:|
| Requests | 1000 |
| Concurrency | 50 |
| Successful | 1000 |
| Failed | 0 |
| Error rate | 0.00% |
| Average latency | 615.01 ms |
| Median latency | 589.25 ms |
| P95 latency | 1090.02 ms |
| P99 latency | 1449.36 ms |
| Wall time | 12.69 s |
| Throughput | 78.83 req/s |

These values are the pre-migration local baseline and should be retained for later comparison with Google Cloud Run + Cloud SQL.
