#!/usr/bin/env sh
set -eu

BASE_URL="${BASE_URL:-http://localhost:8000}"

echo "1/5 Health"
curl -fsS "$BASE_URL/health"
echo

echo "2/5 Products"
curl -fsS "$BASE_URL/products"
echo

echo "3/5 Customer"
curl -fsS "$BASE_URL/customers/1"
echo

echo "4/5 Missing order must return 404"
status="$(curl -s -o /dev/null -w "%{http_code}" "$BASE_URL/orders/999999")"
test "$status" = "404"
echo "HTTP $status"

echo "5/5 Metrics"
curl -fsS "$BASE_URL/metrics" | grep -q "cloudshift_requests_total"
echo "Metrics present"

echo "Smoke tests passed."
