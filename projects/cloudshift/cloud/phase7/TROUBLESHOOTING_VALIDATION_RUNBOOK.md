# CloudShift — Phase 7 Troubleshooting Validation Runbook

## Operational model

```text
Incident
   |
   +--> Service / container state
   |
   +--> Structured JSON logs
   |
   +--> Prometheus metrics
   |
   +--> Grafana dashboard
   |
   +--> Firestore audit events
   |
   +--> SQL / HTTP diagnostic evidence
   |
   v
Root cause
   |
   v
Fix
   |
   v
Same verification workload
```

## Production mapping

| Local validation signal | Google Cloud equivalent |
|---|---|
| Docker service state | Cloud Run revision/service health |
| JSON stdout logs | Cloud Logging structured entries |
| Prometheus | Managed Service for Prometheus / Cloud Monitoring |
| Grafana | Cloud Monitoring dashboard or Grafana |
| Firestore emulator | Firestore |
| PostgreSQL EXPLAIN ANALYZE | Cloud SQL PostgreSQL query analysis |
| config override | Cloud Run revision configuration |
| load generator | post-migration validation test |

## Completion criteria

Phase 7 is complete when:

- all seven scenario scripts finish
- broken-state evidence files exist
- fixed-state evidence files exist
- the API is healthy after the final scenario
- Prometheus is healthy
- Grafana is healthy
- `PHASE7_RESULTS.md` is generated
