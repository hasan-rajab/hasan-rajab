#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/_common.sh"

gcloud run deploy "${SHIPPING_SERVICE}" \
  --image="${SHIPPING_IMAGE}" \
  --region="${REGION}" \
  --platform=managed \
  --service-account="${RUN_SA_EMAIL}" \
  --allow-unauthenticated \
  --set-env-vars="SHIPPING_DELAY_SECONDS=0.15" \
  --set-secrets="SHIPPING_REQUIRED_TOKEN=${SHIPPING_TOKEN_SECRET}:latest" \
  --min=0 \
  --max=2 \
  --memory=256Mi \
  --cpu=1 \
  --port=9000

SHIPPING_URL="$(gcloud run services describe "${SHIPPING_SERVICE}" \
  --region="${REGION}" \
  --format="value(status.url)")"

echo
echo "Shipping URL: ${SHIPPING_URL}"
