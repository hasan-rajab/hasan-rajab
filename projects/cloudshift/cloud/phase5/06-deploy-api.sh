#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/_common.sh"

INSTANCE_CONNECTION_NAME="$(gcloud sql instances describe "${SQL_INSTANCE}" \
  --format="value(connectionName)")"

SHIPPING_URL="$(gcloud run services describe "${SHIPPING_SERVICE}" \
  --region="${REGION}" \
  --format="value(status.url)")"

INSTANCE_UNIX_SOCKET="/cloudsql/${INSTANCE_CONNECTION_NAME}"

gcloud run deploy "${API_SERVICE}" \
  --image="${API_IMAGE}" \
  --region="${REGION}" \
  --platform=managed \
  --service-account="${RUN_SA_EMAIL}" \
  --allow-unauthenticated \
  --add-cloudsql-instances="${INSTANCE_CONNECTION_NAME}" \
  --set-env-vars="APP_NAME=CloudShift,APP_ENV=cloud,CORS_ORIGINS=*,DB_NAME=${DB_NAME},DB_USER=${DB_USER},INSTANCE_UNIX_SOCKET=${INSTANCE_UNIX_SOCKET},DB_POOL_SIZE=5,DB_MAX_OVERFLOW=5,DB_POOL_TIMEOUT=10,DB_TEST_DELAY_SECONDS=0,SHIPPING_BASE_URL=${SHIPPING_URL},SHIPPING_TIMEOUT_SECONDS=2,SCENARIO_BAD_HTTP_STATUS=false" \
  --set-secrets="DB_PASSWORD=${DB_PASSWORD_SECRET}:latest,SHIPPING_API_TOKEN=${SHIPPING_TOKEN_SECRET}:latest" \
  --min=0 \
  --max=3 \
  --concurrency=40 \
  --memory=512Mi \
  --cpu=1 \
  --port=8080

API_URL="$(gcloud run services describe "${API_SERVICE}" \
  --region="${REGION}" \
  --format="value(status.url)")"

echo
echo "API URL: ${API_URL}"
echo
echo "Initial health check:"
curl -sS -i "${API_URL}/health" || true
