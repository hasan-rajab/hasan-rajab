# Scenario 01 — Bad Environment Variable

## Customer Report

> "The application was redeployed after a configuration change. The frontend is reachable, but the API is unavailable and employees cannot access orders."

## Intended Failure

The API is configured with the wrong PostgreSQL database name:

```text
DB_NAME=cloudshift_production
```

The PostgreSQL service actually contains:

```text
DB_NAME=cloudshift
```

The application therefore cannot establish its startup database connection.

## Skills Demonstrated

- Docker / Docker Compose
- Linux shell diagnostics
- environment-variable inspection
- PostgreSQL connectivity
- application log analysis
- root-cause analysis
- configuration remediation
- post-fix validation

---

## 1. Confirm the Healthy Baseline

Before breaking anything:

```bash
curl -i http://localhost:8000/health
```

Expected:

```text
HTTP/1.1 200 OK
```

Run:

```bash
bash scripts/smoke_test.sh
```

Expected:

```text
Smoke tests passed.
```

---

## 2. Introduce the Failure

Run from the repository root:

```bash
docker compose   -f docker-compose.yml   -f scenarios/01-bad-environment-variable/broken.compose.yml   up -d --force-recreate api
```

The API now receives the incorrect `DB_NAME`.

Do not fix it yet.

---

## 3. Observe the Symptom

Check container state:

```bash
docker compose ps -a
```

Then try:

```bash
curl -i http://localhost:8000/health
```

Depending on container timing, the request should fail because the FastAPI service cannot complete startup.

Inspect the API logs:

```bash
docker compose logs --tail=100 api
```

Look for PostgreSQL/database connection errors mentioning the configured database.

---

## 4. Inspect the Deployed Configuration

Inspect the actual environment used by the API container:

```bash
docker inspect cloudshift-api   --format '{{range .Config.Env}}{{println .}}{{end}}'   | grep '^DB_'
```

Expected relevant value:

```text
DB_NAME=cloudshift_production
```

Do not assume the intended value is correct merely because it appears in documentation. Compare it with the actual database.

---

## 5. Verify the Database Side

Run:

```bash
docker compose exec -T db   psql -U cloudshift -d cloudshift   -c "SELECT current_database();"
```

Expected:

```text
current_database
------------------
cloudshift
```

This establishes the mismatch:

```text
API configuration        PostgreSQL
-----------------        ----------
cloudshift_production    cloudshift
```

---

## 6. Root Cause

The deployment supplied an incorrect `DB_NAME` environment variable.

The application attempted to connect to:

```text
cloudshift_production
```

while PostgreSQL exposed:

```text
cloudshift
```

This is a configuration failure, not an application-code or database-server failure.

---

## 7. Apply the Fix

Recreate the API with the correct configuration:

```bash
docker compose   -f docker-compose.yml   -f scenarios/01-bad-environment-variable/fixed.compose.yml   up -d --force-recreate api
```

Alternatively, the base `docker-compose.yml` already contains the correct value:

```bash
docker compose up -d --force-recreate api
```

---

## 8. Verify Recovery

Check state:

```bash
docker compose ps
```

Check health:

```bash
curl -i http://localhost:8000/health
```

Expected:

```text
HTTP/1.1 200 OK
```

Expected JSON:

```json
{
  "status": "healthy",
  "database": "connected",
  "version": "1.0.0",
  "environment": "local"
}
```

Finally:

```bash
bash scripts/smoke_test.sh
```

Expected:

```text
Smoke tests passed.
```

---

## Troubleshooting Logic

```text
Customer reports API unavailable
          ↓
Reproduce with curl
          ↓
Check container state
          ↓
Read application startup logs
          ↓
Inspect deployed DB_* variables
          ↓
Confirm actual PostgreSQL database
          ↓
Configuration mismatch identified
          ↓
Correct DB_NAME
          ↓
Recreate service
          ↓
Health + smoke tests pass
```

## Customer Explanation

The API outage was caused by a deployment configuration mismatch. The application was instructed to connect to a PostgreSQL database name that did not exist on the database server. We verified that the database service itself was healthy, corrected the application environment variable, recreated the API service, and confirmed recovery using health and smoke tests.

## Prevention

- Keep environment-specific configuration under version-controlled deployment templates.
- Validate required configuration during CI/CD before deployment.
- Use separate health/readiness checks for critical dependencies.
- Avoid manually editing production environment variables without review.
- Use managed secret/configuration systems in cloud environments.
- Alert on failed deployments and unhealthy revisions.
