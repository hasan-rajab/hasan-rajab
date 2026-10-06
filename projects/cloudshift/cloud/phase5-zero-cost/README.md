# Phase 5 — Zero-Cost Migration Readiness

This path performs no billable Google Cloud deployment.

It validates CloudShift against Cloud Run-style container requirements and produces the complete GCP migration blueprint.

## Run

```bash
bash cloud/phase5-zero-cost/01-start-cloud-sim.sh
```

```bash
bash cloud/phase5-zero-cost/02-seed.sh
```

```bash
bash cloud/phase5-zero-cost/03-verify-cloud-contract.sh
```

```bash
bash cloud/phase5-zero-cost/04-cloud-sim-baseline.sh
```

Then fill in:

```text
cloud/phase5-zero-cost/MIGRATION_READINESS_REPORT.md
```

And review:

```text
cloud/phase5-zero-cost/GCP_DEPLOYMENT_BLUEPRINT.md
```

Cleanup:

```bash
bash cloud/phase5-zero-cost/cleanup.sh
```

## What this proves

- containerization
- Cloud Run runtime compatibility
- environment-driven configuration
- database separation
- dependency architecture
- health/metrics
- load testing
- GCP migration planning
- security/IAM design
- observability planning

## What it does not prove

It does not prove a live Cloud Run/Cloud SQL deployment. Keep portfolio claims accurate until a live deployment is actually executed.
