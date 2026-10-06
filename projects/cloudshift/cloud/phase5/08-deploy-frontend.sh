#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/_common.sh"

API_URL="$(gcloud run services describe "${API_SERVICE}" \
  --region="${REGION}" \
  --format="value(status.url)")"

gcloud run deploy "${FRONTEND_SERVICE}" \
  --image="${FRONTEND_IMAGE}" \
  --region="${REGION}" \
  --platform=managed \
  --allow-unauthenticated \
  --set-env-vars="API_URL=${API_URL}" \
  --min=0 \
  --max=2 \
  --memory=256Mi \
  --cpu=1 \
  --port=8080

FRONTEND_URL="$(gcloud run services describe "${FRONTEND_SERVICE}" \
  --region="${REGION}" \
  --format="value(status.url)")"

echo
echo "Frontend URL: ${FRONTEND_URL}"
echo
echo "Restricting API CORS to the deployed frontend..."

gcloud run services update "${API_SERVICE}" \
  --region="${REGION}" \
  --update-env-vars="CORS_ORIGINS=${FRONTEND_URL}"

echo
echo "Frontend: ${FRONTEND_URL}"
echo "API:      ${API_URL}"
