# Scenario 04 — Container Configuration

## Customer Report

> "The container process starts and logs look normal, but the service is unreachable from outside the container."

## Break

```bash
docker compose -f docker-compose.yml   -f scenarios/04-container-configuration/broken.compose.yml   up -d --force-recreate api
```

The process binds to `127.0.0.1` inside the container.

Diagnose:

```bash
sh scenarios/04-container-configuration/diagnose.sh
```

Expected evidence:

- container is running
- process starts successfully
- internal `127.0.0.1:8000` request succeeds
- host request to published port fails
- command shows `--host 127.0.0.1`

## Root Cause

The application listens only on the container loopback interface, so Docker's external network interface cannot reach it.

## Fix

```bash
docker compose -f docker-compose.yml   -f scenarios/04-container-configuration/fixed.compose.yml   up -d --force-recreate api
```

Verify:

```bash
curl -i http://localhost:8000/health
```

Expected `HTTP 200`.

This maps directly to managed container platforms such as Cloud Run, where the application must listen on the expected port and on an externally reachable interface.
