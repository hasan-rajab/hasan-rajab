#!/usr/bin/env sh
set -u
ORDER_ID="${1:-1}"

echo "=== Container state ==="
docker compose ps -a
echo

echo "=== Direct shipping service timing ==="
curl -sS -o /tmp/ship.out -w "HTTP %{http_code} total=%{time_total}s\n" \
  "http://localhost:9000/quote/${ORDER_ID}" || true
cat /tmp/ship.out 2>/dev/null || true
echo
echo

echo "=== CloudShift shipping endpoint timing ==="
curl -sS -o /tmp/api.out -w "HTTP %{http_code} total=%{time_total}s\n" \
  "http://localhost:8000/orders/${ORDER_ID}/shipping-quote" || true
cat /tmp/api.out 2>/dev/null || true
echo
echo

echo "=== API shipping config ==="
docker inspect cloudshift-api \
  --format '{{range .Config.Env}}{{println .}}{{end}}' \
  2>/dev/null | grep '^SHIPPING_' || true
echo

echo "=== Shipping service config ==="
docker inspect cloudshift-shipping \
  --format '{{range .Config.Env}}{{println .}}{{end}}' \
  2>/dev/null | grep '^SHIPPING_DELAY_SECONDS=' || true
echo

echo "=== Relevant API logs ==="
docker compose logs --tail=100 api 2>/dev/null \
  | grep -E 'shipping_quote_(timeout|failure|success)' || true
