#!/usr/bin/env bash
set -euo pipefail
BASE="http://localhost:8080"

echo "=== Cloud Run-style PORT contract ==="
docker inspect cloudshift-cloudsim-api \
  --format '{{range .Config.Env}}{{println .}}{{end}}' | grep '^PORT='

echo
echo "=== API health ==="
curl -fsS "${BASE}/health"; echo

echo
echo "=== Products ==="
curl -fsS "${BASE}/products"; echo

echo
echo "=== Customer ==="
curl -fsS "${BASE}/customers/1"; echo

echo
echo "=== Missing order semantics ==="
curl -sS -o /dev/null -w "HTTP %{http_code}\n" "${BASE}/orders/999999"

echo
echo "=== Shipping dependency ==="
curl -fsS "${BASE}/orders/1/shipping-quote"; echo

echo
echo "=== Metrics ==="
curl -fsS "${BASE}/metrics" | grep -m1 cloudshift_requests_total

echo
echo "=== Frontend ==="
curl -sS -o /dev/null -w "HTTP %{http_code}\n" http://localhost:3000

echo
echo "Cloud-simulation verification passed."
