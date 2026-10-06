# Phase 6 — Firestore + Observability Report

## Architecture

```text
                           CloudShift API
                       /        |         \
                      /         |          \
                     v          v           v
              PostgreSQL   Firestore     Shipping API
             transactions  audit events   dependency
                     \          |           /
                      \         |          /
                       +---- Observability ----+
                            JSON logs
                            Prometheus
                            Grafana
```

## Firestore Validation

Record:

- emulator started:
- `/audit-events` returned records:
- `ORDER_CREATED` events:
- shipping events:
- Firestore write failures:

## Structured Logging Validation

Record one representative JSON request log:

```json
PASTE LOG
```

Record one dependency log:

```json
PASTE LOG
```

## Metrics Validation

- Prometheus healthy:
- Grafana healthy:
- request metrics present:
- error metrics present:
- dependency metrics present:
- Firestore metrics present:

## Dashboard

- Grafana URL: `http://localhost:3001`
- Dashboard: `CloudShift / CloudShift Operations`

Record observations:

- request rate:
- P95 API latency:
- shipping P95:
- error rate:
- audit event count:

## Production Mapping

| Local Phase 6 | Live Google Cloud target |
|---|---|
| Firestore emulator | Firestore |
| JSON stdout logs | Cloud Logging structured logs |
| Prometheus | Managed Service for Prometheus / Cloud Monitoring |
| Grafana dashboard | Cloud Monitoring dashboard or Grafana |
| local alerts/runbook | Cloud Monitoring alert policies |

## Result

Phase 6 is complete when:

- Firestore audit events are created and queryable
- structured JSON logs are emitted
- Prometheus successfully scrapes `/metrics`
- Grafana dashboard loads
- generated traffic is visible through logs and metrics
