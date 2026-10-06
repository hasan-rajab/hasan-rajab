#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/_common.sh"

if ! gcloud sql instances describe "${SQL_INSTANCE}" >/dev/null 2>&1; then
  echo "Creating Cloud SQL PostgreSQL 16 Enterprise shared-core development instance..."
  gcloud sql instances create "${SQL_INSTANCE}" \
    --database-version=POSTGRES_16 \
    --edition=ENTERPRISE \
    --tier=db-f1-micro \
    --region="${REGION}" \
    --storage-type=SSD \
    --storage-size=10GB
else
  echo "Cloud SQL instance already exists."
fi

if ! gcloud sql databases describe "${DB_NAME}" \
  --instance="${SQL_INSTANCE}" >/dev/null 2>&1; then
  gcloud sql databases create "${DB_NAME}" \
    --instance="${SQL_INSTANCE}"
else
  echo "Database already exists."
fi

echo
echo "Cloud SQL connection name:"
gcloud sql instances describe "${SQL_INSTANCE}" \
  --format="value(connectionName)"
