# CloudShift — Migration Readiness Report

## Runtime Compatibility Validation

Run:

```bash
bash cloud/phase5-zero-cost/03-verify-cloud-contract.sh
```

Record:

- `$PORT=8080`:
- `/health`:
- `/products`:
- `/customers/1`:
- missing order status:
- shipping dependency:
- `/metrics`:
- frontend:

## Cloud-Simulation Load Test

Run:

```bash
bash cloud/phase5-zero-cost/04-cloud-sim-baseline.sh
```

Record:

- Requests:
- Concurrency:
- Successful:
- Failed:
- Average:
- P95:
- P99:
- Throughput:

## Migration Risks

- Cloud SQL connection limits vs Cloud Run concurrency
- cold starts
- configuration/secret mistakes
- incorrect container listening configuration
- schema migration execution
- downstream dependency failures
- CORS/public ingress
- regional latency

## Go-Live Checklist

- [ ] funded/credit-backed Google Cloud project available
- [ ] Cloud Run / Cloud SQL APIs enabled
- [ ] Artifact Registry created
- [ ] images pushed
- [ ] Cloud SQL provisioned
- [ ] service account created
- [ ] secrets configured
- [ ] API deployed
- [ ] DB migration executed
- [ ] frontend deployed
- [ ] smoke tests passed
- [ ] cloud load test recorded
- [ ] logs/metrics reviewed
- [ ] rollback plan tested
