#!/usr/bin/env bash
set -euo pipefail

BASE="http://localhost:8080"

echo "Generating healthy requests..."
for i in $(seq 1 30); do
  curl -fsS "${BASE}/products" >/dev/null
  curl -fsS "${BASE}/health" >/dev/null
done

echo "Generating controlled 404s..."
for i in $(seq 1 10); do
  curl -sS "${BASE}/orders/999999" >/dev/null
done

echo "Creating orders and Firestore audit events..."
for i in $(seq 1 5); do
  curl -fsS -X POST "${BASE}/orders" \
    -H "Content-Type: application/json" \
    -d '{"customer_id":1,"items":[{"product_id":1,"quantity":1}]}' >/dev/null
done

echo "Generating shipping dependency traffic..."
for i in $(seq 1 10); do
  curl -fsS "${BASE}/orders/1/shipping-quote" >/dev/null
done

echo "Done."
