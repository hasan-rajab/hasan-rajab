# Scenario 06 — API Authentication Failure

## Customer Report

> "Shipping quote requests started failing after a credential/configuration change."

## Break

```bash
docker compose -f docker-compose.yml   -f scenarios/06-api-authentication-failure/broken.compose.yml   up -d --force-recreate api shipping
```

Diagnose:

```bash
sh scenarios/06-api-authentication-failure/diagnose.sh 1
```

Expected evidence:

- direct shipping request with wrong token returns `401`
- CloudShift logs `shipping_upstream_auth_failure ... status=401`
- API is using `SHIPPING_API_TOKEN=wrong-demo-token`

CloudShift deliberately maps the upstream authentication failure to a controlled `502` for its own client rather than exposing dependency internals.

## Root Cause

The application sends an invalid Bearer token to the downstream shipping API.

## Fix

```bash
docker compose -f docker-compose.yml   -f scenarios/06-api-authentication-failure/fixed.compose.yml   up -d --force-recreate api shipping
```

Verify:

```bash
curl -i http://localhost:8000/orders/1/shipping-quote
```

Expected `HTTP 200`.

The token values in this lab are fictional demo credentials only.
