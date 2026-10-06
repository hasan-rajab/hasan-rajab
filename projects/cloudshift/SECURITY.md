# Security and secrets boundary

CloudShift is a portfolio/customer-engineering lab. The checked-in Docker Compose and `.env.example` values are **local demo credentials**, not reusable secrets and not a production security configuration.

## Repository rule

- Real `.env` files are ignored by Git.
- Cloud phase environment files such as `cloud/phase5/phase5.env` are ignored and must remain local.
- API keys, cloud credentials, service-account keys, private keys, and production passwords must never be committed.
- Before exposing the stack outside a trusted local machine, replace every development password/token and use a managed identity/secrets mechanism.

## Google Cloud reference path

The GCP deployment scripts do not embed a live application secret in source. The deployment path generates runtime credentials and stores them in Google Cloud Secret Manager. Repository configuration contains only the code needed to create/read those managed secrets.

## Demo values

Values such as `cloudshift_dev` and the Compose shipping token are intentionally recognizable local-development defaults. They exist only to make the lab reproducible. They must not be used as evidence of production credential practice or copied into a shared environment.

## Scope

CloudShift demonstrates migration design, troubleshooting, observability, performance investigation, and operational verification. It is not a claim of a hardened production deployment. A real deployment would additionally require organization-specific IAM, workload identity, private networking, secret rotation, vulnerability management, TLS policy, audit retention, backups, patching, and incident-response controls.

If a real credential is ever discovered in repository history, treat it as compromised: revoke/rotate it first, then remove it from the repository and history as appropriate.
