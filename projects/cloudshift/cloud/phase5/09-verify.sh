#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/_common.sh"

API_URL="$(gcloud run services describe "${API_SERVICE}" \
  --region="${REGION}" \
  --format="value(status.url)")"

SHIPPING_URL="$(gcloud run services describe "${SHIPPING_SERVICE}" \
  --region="${REGION}" \
  --format="value(status.url)")"

FRONTEND_URL="$(gcloud run services describe "${FRONTEND_SERVICE}" \
  --region="${REGION}" \
  --format="value(status.url)")"

echo "=== Cloud Run services ==="
gcloud run services list \
  --region="${REGION}" \
  --format="table(metadata.name,status.url,status.latestReadyRevisionName)"
echo

echo "=== API health ==="
curl -fsS "${API_URL}/health"
echo
echo

echo "=== Products ==="
curl -fsS "${API_URL}/products"
echo
echo

echo "=== Customer ==="
curl -fsS "${API_URL}/customers/1"
echo
echo

echo "=== Create cloud order ==="
curl -fsS -X POST "${API_URL}/orders" \
  -H "Content-Type: application/json" \
  -d '{"customer_id":1,"items":[{"product_id":1,"quantity":1}]}'
echo
echo

echo "=== Missing order HTTP status ==="
curl -sS -o /dev/null -w "HTTP %{http_code}\n" \
  "${API_URL}/orders/999999"
echo

echo "=== Shipping quote ==="
curl -fsS "${API_URL}/orders/1/shipping-quote"
echo
echo

echo "=== Metrics marker ==="
curl -fsS "${API_URL}/metrics" | grep -m1 cloudshift_requests_total
echo

echo "=== URLs ==="
echo "Frontend: ${FRONTEND_URL}"
echo "API:      ${API_URL}"
echo "Shipping: ${SHIPPING_URL}"
