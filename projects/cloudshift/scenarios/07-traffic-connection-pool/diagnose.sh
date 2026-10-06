#!/usr/bin/env sh
set -u

echo "=== API DB pool configuration ==="
docker inspect cloudshift-api \
  --format '{{range .Config.Env}}{{println .}}{{end}}' \
  | grep -E '^DB_(POOL_SIZE|MAX_OVERFLOW|POOL_TIMEOUT|TEST_DELAY_SECONDS)=' || true
echo

echo "=== Load test ==="
docker compose exec -T api python -m scripts.http_load_test \
  --url http://localhost:8000/diagnostics/db-work \
  --requests 200 \
  --concurrency 50 \
  --timeout 5
echo

echo "=== Pool timeout logs ==="
docker compose logs --tail=200 api | grep db_pool_timeout || true
