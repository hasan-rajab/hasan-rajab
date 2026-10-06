#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/_common.sh"

INSTANCE_CONNECTION_NAME="$(gcloud sql instances describe "${SQL_INSTANCE}" \
  --format="value(connectionName)")"
INSTANCE_UNIX_SOCKET="/cloudsql/${INSTANCE_CONNECTION_NAME}"

JOB_NAME="cloudshift-seed"

gcloud run jobs deploy "${JOB_NAME}" \
  --image="${API_IMAGE}" \
  --region="${REGION}" \
  --service-account="${RUN_SA_EMAIL}" \
  --set-cloudsql-instances="${INSTANCE_CONNECTION_NAME}" \
  --set-env-vars="APP_ENV=cloud,DB_NAME=${DB_NAME},DB_USER=${DB_USER},INSTANCE_UNIX_SOCKET=${INSTANCE_UNIX_SOCKET},DB_POOL_SIZE=2,DB_MAX_OVERFLOW=0,DB_POOL_TIMEOUT=10" \
  --set-secrets="DB_PASSWORD=${DB_PASSWORD_SECRET}:latest" \
  --command=python \
  --args=-m,scripts.seed_database \
  --max-retries=0 \
  --task-timeout=300s

gcloud run jobs execute "${JOB_NAME}" \
  --region="${REGION}" \
  --wait

echo
echo "Cloud database seed job completed."
