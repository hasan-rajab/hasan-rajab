# Scenario 03 — Incorrect HTTP Status Handling

## Customer Report

> "Our client application thinks missing orders are successful responses."

## Break

```bash
docker compose -f docker-compose.yml   -f scenarios/03-incorrect-http-status/broken.compose.yml   up -d --force-recreate api
```

Test:

```bash
curl -i http://localhost:8000/orders/999999
```

Broken behavior:

```text
HTTP/1.1 200 OK
{"error":"Order not found","order_id":999999}
```

## Diagnosis

The JSON body contains an error, but HTTP semantics say `200 OK`. Clients, monitoring systems, retries, and API gateways may therefore classify the request as successful.

Check logs:

```bash
docker compose logs --tail=50 api | grep bad_http_status_mode
```

## Fix

```bash
docker compose -f docker-compose.yml   -f scenarios/03-incorrect-http-status/fixed.compose.yml   up -d --force-recreate api
```

Verify:

```bash
curl -i http://localhost:8000/orders/999999
```

Expected:

```text
HTTP/1.1 404 Not Found
```

Then run:

```bash
bash scripts/smoke_test.sh
```
