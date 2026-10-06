#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/_common.sh"

echo "Enabling required APIs..."
gcloud services enable \
  run.googleapis.com \
  sqladmin.googleapis.com \
  artifactregistry.googleapis.com \
  secretmanager.googleapis.com \
  iam.googleapis.com

if ! gcloud artifacts repositories describe "${REPOSITORY}" \
  --location="${REGION}" >/dev/null 2>&1; then
  gcloud artifacts repositories create "${REPOSITORY}" \
    --repository-format=docker \
    --location="${REGION}" \
    --description="CloudShift container images"
else
  echo "Artifact Registry repository already exists."
fi

gcloud auth configure-docker "${AR_HOST}" --quiet

if ! gcloud iam service-accounts describe "${RUN_SA_EMAIL}" >/dev/null 2>&1; then
  gcloud iam service-accounts create "${RUN_SERVICE_ACCOUNT}" \
    --display-name="CloudShift Cloud Run service account"
else
  echo "Service account already exists."
fi

gcloud projects add-iam-policy-binding "${PROJECT_ID}" \
  --member="serviceAccount:${RUN_SA_EMAIL}" \
  --role="roles/cloudsql.client" \
  --quiet >/dev/null

echo
echo "Bootstrap complete."
echo "Repository: ${AR_HOST}/${PROJECT_ID}/${REPOSITORY}"
echo "Runtime identity: ${RUN_SA_EMAIL}"
