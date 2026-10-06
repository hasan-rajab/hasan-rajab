# CloudShift Observability Runbook

## Signals

### Logs

CloudShift emits one serialized JSON object per application log line.

Important fields:

- `severity`
- `message`
- `timestamp`
- `service`
- `environment`
- `event`
- `request_id`
- `http_method`
- `http_path`
- `http_status`
- `latency_ms`
- `order_id`
- `dependency`

Example local query:

```bash
docker logs cloudshift-p6-api | grep '"severity":"ERROR"'
```

Example event query:

```bash
docker logs cloudshift-p6-api | grep '"event":"shipping_quote_success"'
```

In a live Cloud Run deployment, the same stdout JSON format is intended to map into structured Cloud Logging entries.

## Metrics

Useful PromQL:

### Request rate

```promql
sum(rate(cloudshift_requests_total[1m]))
```

### 5xx rate

```promql
sum(rate(cloudshift_errors_total{status_class="5xx"}[5m]))
```

### API P95 latency

```promql
histogram_quantile(
  0.95,
  sum by (le,path) (
    rate(cloudshift_request_duration_seconds_bucket[5m])
  )
)
```

### Shipping P95

```promql
histogram_quantile(
  0.95,
  sum by (le) (
    rate(cloudshift_dependency_duration_seconds_bucket{dependency="shipping"}[5m])
  )
)
```

### Firestore audit writes

```promql
sum(cloudshift_audit_events_total)
```

## Suggested alert conditions for a live deployment

These are architecture recommendations, not active local alerts:

- 5xx ratio > 5% for 5 minutes
- API P95 > 2 seconds for 10 minutes
- shipping timeout rate > 1% for 5 minutes
- Firestore audit write failures > 0 for 5 minutes
- Cloud SQL connection utilization approaching configured pool/instance limit

## Audit store

PostgreSQL remains the system of record for transactional order/customer data.

Firestore stores append-oriented operational audit records:

```text
audit_events/{event_id}
```

Event examples:

- `ORDER_CREATED`
- `SHIPPING_QUOTE_SUCCEEDED`
- `SHIPPING_TIMEOUT`
- `SHIPPING_AUTH_FAILURE`
- `SHIPPING_REQUEST_FAILURE`

This avoids forcing document-oriented audit data into the relational transaction model.
