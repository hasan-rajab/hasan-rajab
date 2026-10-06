#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"
command -v docker >/dev/null
docker compose version
mkdir -p reproduction-output
if [[ ! -f .env ]]; then cp .env.example .env; fi
docker compose up --build -d db shipping api
ready=false
for _ in $(seq 1 60); do
  if docker compose exec -T api python -c 'import requests; requests.get("http://127.0.0.1:8000/health", timeout=3).raise_for_status()' >/dev/null 2>&1; then ready=true; break; fi
  sleep 1
done
if [[ "$ready" != true ]]; then docker compose logs --tail=50 api; exit 1; fi
docker compose exec -T api python -m scripts.seed_database
COUNT="$(docker compose exec -T db psql -U cloudshift -d cloudshift -Atc 'SELECT COUNT(*) FROM orders;')"
if [[ "$COUNT" -lt 100000 ]]; then
  docker compose exec -T api python -m scripts.bulk_seed --customers 500 --orders 100000
fi
CUSTOMER_ID="$(docker compose exec -T db psql -U cloudshift -d cloudshift -Atc "SELECT id FROM customers WHERE email = 'loaduser1@example.com';")"
if [[ -z "$CUSTOMER_ID" ]]; then echo "Synthetic heavy customer is missing; use the documented dedicated lab."; exit 1; fi
{
  date -u
  docker compose exec -T db psql -U cloudshift -d cloudshift -Atc 'SELECT version();'
  docker compose exec -T db psql -U cloudshift -d cloudshift -Atc 'SELECT COUNT(*) FROM orders;'
  echo "Heavy customer: $CUSTOMER_ID"
} > reproduction-output/environment.txt
docker compose exec -T db psql -v ON_ERROR_STOP=1 -U cloudshift -d cloudshift < scenarios/05-database-bottleneck/rollback.sql
docker compose exec -T api python -m scripts.analyze_customer_orders --customer-id "$CUSTOMER_ID" --runs 20 | tee reproduction-output/before.txt
docker compose exec -T db psql -v ON_ERROR_STOP=1 -U cloudshift -d cloudshift < scenarios/05-database-bottleneck/fix.sql
docker compose exec -T api python -m scripts.analyze_customer_orders --customer-id "$CUSTOMER_ID" --runs 20 | tee reproduction-output/after.txt
grep -Eq 'Rows returned: +25,000' reproduction-output/before.txt
grep -Eq 'Rows returned: +25,000' reproduction-output/after.txt
echo "Before/after query outputs captured. Exact timings and planner choices may vary."
echo "Historical CV record: cloud/phase7/evidence/05-db-{broken,fixed}-query.txt"
