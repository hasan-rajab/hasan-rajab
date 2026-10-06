#!/usr/bin/env sh
set -u
ORDER_ID="${1:-1}"

echo "=== CloudShift call ==="
curl -sS -i "http://localhost:8000/orders/${ORDER_ID}/shipping-quote" || true
echo
echo

echo "=== Direct shipping call with wrong token ==="
curl -sS -i \
  -H 'Authorization: Bearer wrong-demo-token' \
  "http://localhost:9000/quote/${ORDER_ID}" || true
echo
echo

echo "=== API token configuration ==="
docker inspect cloudshift-api \
  --format '{{range .Config.Env}}{{println .}}{{end}}' \
  | grep '^SHIPPING_API_TOKEN=' || true
echo

echo "=== Relevant API logs ==="
docker compose logs --tail=100 api \
  | grep 'shipping_upstream_auth_failure' || true
