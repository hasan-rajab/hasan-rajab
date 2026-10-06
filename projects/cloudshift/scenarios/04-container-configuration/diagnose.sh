#!/usr/bin/env sh
set -u

echo "=== Container state ==="
docker compose ps -a
echo

echo "=== Host connectivity ==="
curl -sS -o /tmp/s04_host.out -w "HTTP %{http_code} total=%{time_total}s\n" \
  http://localhost:8000/health || true
cat /tmp/s04_host.out 2>/dev/null || true
echo

echo "=== Process command ==="
docker inspect cloudshift-api --format '{{json .Config.Cmd}}' || true
echo

echo "=== API logs ==="
docker compose logs --tail=50 api || true
echo

echo "=== Internal loopback connectivity ==="
docker exec cloudshift-api python -c \
'import urllib.request; print("internal_http_status=", urllib.request.urlopen("http://127.0.0.1:8000/health").status)' \
2>/dev/null || true
