#!/usr/bin/env sh
set -u

echo "=== 1. Container state ==="
docker compose ps -a
echo

echo "=== 2. API logs (last 80 lines) ==="
docker compose logs --tail=80 api || true
echo

echo "=== 3. API DB environment ==="
docker inspect cloudshift-api \
  --format '{{range .Config.Env}}{{println .}}{{end}}' \
  2>/dev/null | grep '^DB_' || true
echo

echo "=== 4. PostgreSQL database actually available ==="
docker compose exec -T db \
  psql -U cloudshift -d cloudshift \
  -c "SELECT current_database();" || true
