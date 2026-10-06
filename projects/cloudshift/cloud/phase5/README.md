# Phase 5 — Google Cloud Migration

## Target architecture

```text
Browser
  |
  v
Cloud Run: cloudshift-frontend
  |
  v
Cloud Run: cloudshift-api
  |                     |
  |                     v
  |             Cloud Run: cloudshift-shipping
  |
  v
Cloud SQL for PostgreSQL

Container images:
Artifact Registry

Credentials:
Secret Manager

Database initialization:
Cloud Run Job
```

## Region

This lab defaults to:

```text
me-central1 (Doha)
```

Keep Cloud Run, Cloud SQL, and Artifact Registry in the same region for the lab.

## 0. Create the environment file

```bash
cp cloud/phase5/phase5.env.example cloud/phase5/phase5.env
```

Edit:

```text
PROJECT_ID=your-real-google-cloud-project-id
```

The project must exist and have billing enabled.

## 1. Install/authenticate gcloud if needed

Check:

```bash
gcloud version
```

Then:

```bash
gcloud init
```

## 2. Preflight

```bash
bash cloud/phase5/00-preflight.sh
```

## 3. Bootstrap GCP

```bash
bash cloud/phase5/01-bootstrap-gcp.sh
```

This enables:

- Cloud Run API
- Cloud SQL Admin API
- Artifact Registry API
- Secret Manager API
- IAM API

It also creates:

- Artifact Registry repository
- runtime service account
- Cloud SQL Client IAM binding

## 4. Build and push images

```bash
bash cloud/phase5/02-build-push-images.sh
```

Images:

```text
api:v1
shipping:v1
frontend:v1
```

## 5. Create Cloud SQL

```bash
bash cloud/phase5/03-create-cloudsql.sh
```

For this portfolio lab the script uses a low-cost shared-core development instance:

```text
PostgreSQL 16
Cloud SQL Enterprise
db-f1-micro
10 GB SSD
me-central1
```

Do not represent this as production sizing.

## 6. Secrets

```bash
bash cloud/phase5/04-create-secrets.sh
```

Creates:

- random database password
- random shipping API token
- Secret Manager secrets
- Cloud SQL application user
- Secret Manager IAM access for the Cloud Run runtime identity

No real secret is committed to Git.

## 7. Deploy shipping dependency

```bash
bash cloud/phase5/05-deploy-shipping.sh
```

## 8. Deploy API

```bash
bash cloud/phase5/06-deploy-api.sh
```

The deployment:

- uses the Artifact Registry API image
- attaches the Cloud SQL instance
- uses `/cloudsql/...` Unix socket connectivity
- gets DB password from Secret Manager
- gets shipping token from Secret Manager
- uses Cloud Run's injected `PORT`
- caps scaling for the lab

## 9. Seed Cloud SQL

```bash
bash cloud/phase5/07-seed-cloudsql.sh
```

This uses a one-off Cloud Run Job rather than exposing a public administrative seed endpoint.

## 10. Deploy frontend

```bash
bash cloud/phase5/08-deploy-frontend.sh
```

The frontend gets the deployed API URL at runtime. The script then updates the API CORS configuration from temporary `*` to the exact frontend origin.

## 11. Verify

```bash
bash cloud/phase5/09-verify.sh
```

Verify:

- `/health`
- products
- customer lookup
- order creation
- HTTP 404 semantics
- shipping dependency
- metrics
- frontend URL

## 12. Cloud performance baseline

```bash
bash cloud/phase5/10-cloud-baseline.sh
```

Compare it with the recorded local result:

```text
Requests:       1000
Concurrency:    50
Successful:     1000
Failed:         0
Error rate:     0.00%
Average:        615.01 ms
Median:         589.25 ms
P95:            1090.02 ms
P99:            1449.36 ms
Throughput:     78.83 req/s
```

Do not claim one platform is "faster" from one laptop-generated test alone. Record the environment, region, cold-start behavior, and network path when interpreting the results.

## Run the full deployment sequence

After `phase5.env` contains the correct project ID:

```bash
bash cloud/phase5/run-phase5.sh
```

The cloud baseline is deliberately separate so you can confirm the deployment first.

## Cost control

Cloud SQL is a continuously provisioned resource and can incur charges.

When you finish the lab and no longer need the deployment:

```bash
bash cloud/phase5/cleanup.sh
```

The cleanup script asks for an explicit confirmation and removes:

- three Cloud Run services
- seed Cloud Run Job
- Cloud SQL instance

It leaves Artifact Registry images and secrets so the project history remains available. Delete those separately if you want a fully empty project.
