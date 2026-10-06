#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/_common.sh"

echo "This removes CloudShift Cloud Run services/job and the Cloud SQL instance."
echo "Artifact Registry images and Secret Manager secrets are left intact."
read -r -p "Type DELETE-CLOUDSHIFT to continue: " confirmation

if [[ "${confirmation}" != "DELETE-CLOUDSHIFT" ]]; then
  echo "Cancelled."
  exit 0
fi

gcloud run services delete "${FRONTEND_SERVICE}" --region="${REGION}" --quiet || true
gcloud run services delete "${API_SERVICE}" --region="${REGION}" --quiet || true
gcloud run services delete "${SHIPPING_SERVICE}" --region="${REGION}" --quiet || true
gcloud run jobs delete cloudshift-seed --region="${REGION}" --quiet || true
gcloud sql instances delete "${SQL_INSTANCE}" --quiet || true

echo "Compute/database resources removed."
