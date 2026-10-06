# Scenario 02 — API Timeout

## Customer Report

> "Order data works, but shipping quotes repeatedly fail. Other API endpoints appear healthy."

## Healthy architecture

```text
Client -> CloudShift FastAPI -> Mock Shipping Service
          timeout: 1.0 s       response: ~0.15 s
```

## Broken state

The shipping service is deliberately slowed to 4 seconds while CloudShift keeps a 1-second downstream timeout:

```text
CloudShift timeout = 1.0 s
Shipping response  = 4.0 s
Result             = HTTP 504
```

## 1. Rebuild with the new shipping service

```bash
docker compose up --build -d
```

Confirm an existing order ID, for example:

```bash
curl http://localhost:8000/orders/1
```

## 2. Healthy baseline

```bash
curl -i http://localhost:8000/orders/1/shipping-quote
```

Expected: `HTTP 200` and roughly 0.15 seconds of downstream latency.

## 3. Introduce the timeout incident

```bash
docker compose   -f docker-compose.yml   -f scenarios/02-api-timeout/broken.compose.yml   up -d --force-recreate api shipping
```

## 4. Diagnose

```bash
sh scenarios/02-api-timeout/diagnose.sh 1
```

Expected evidence:

- direct shipping request takes about 4 seconds
- CloudShift returns `HTTP 504` after roughly 1 second
- `SHIPPING_TIMEOUT_SECONDS=1.0`
- `SHIPPING_DELAY_SECONDS=4.0`
- API logs contain `shipping_quote_timeout`

This proves the API itself is responsive and the failure is caused by a slow downstream dependency exceeding its timeout budget.

## 5. Root cause

The shipping dependency degraded to ~4 seconds response time. CloudShift correctly stops waiting after its configured 1-second timeout and translates the dependency timeout into HTTP `504 Gateway Timeout`.

## 6. Fix

Restore normal dependency response time:

```bash
docker compose   -f docker-compose.yml   -f scenarios/02-api-timeout/fixed.compose.yml   up -d --force-recreate api shipping
```

## 7. Verify

```bash
curl -i http://localhost:8000/orders/1/shipping-quote
```

Then:

```bash
sh scenarios/02-api-timeout/diagnose.sh 1
```

Expected:

- direct dependency ~0.15 s
- CloudShift endpoint HTTP 200
- no new timeout event

## Customer Explanation

The order service itself remained healthy. Shipping quote failures were caused by a downstream shipping dependency taking longer than the application's configured timeout. We isolated the dependency by comparing direct request timing with CloudShift request timing, confirmed the timeout configuration in the running containers, and restored service after correcting the downstream latency.

## Prevention

- Monitor downstream latency separately from API latency.
- Set explicit connection/read timeouts.
- Return controlled 504 responses instead of hanging indefinitely.
- Add alerts for dependency timeout rates.
- Consider retries only for safe/idempotent operations and use bounded backoff.
- Define latency budgets for external dependencies.
