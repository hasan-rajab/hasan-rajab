#!/usr/bin/env bash
set -euo pipefail
D="$(cd "$(dirname "$0")" && pwd)"
source "${D}/../../_common.sh"

COUNT="$(docker compose -f "$BASE" exec -T db psql -U cloudshift -d cloudshift -Atc 'SELECT COUNT(*) FROM orders;')"
if [[ "$COUNT" -lt 100000 ]]; then
  docker compose -f "$BASE" exec -T api python -m scripts.bulk_seed --customers 500 --orders 100000
fi

docker compose -f "$BASE" exec -T db psql -U cloudshift -d cloudshift \
  < scenarios/05-database-bottleneck/rollback.sql

docker compose -f "$BASE" exec -T api python -m scripts.analyze_customer_orders \
  --customer-id 3 --runs 20 | tee "cloud/phase7/evidence/05-db-broken-query.txt"
"${P7}/capture.sh" "05-db-broken"

docker compose -f "$BASE" exec -T db psql -U cloudshift -d cloudshift \
  < scenarios/05-database-bottleneck/fix.sql

docker compose -f "$BASE" exec -T api python -m scripts.analyze_customer_orders \
  --customer-id 3 --runs 20 | tee "cloud/phase7/evidence/05-db-fixed-query.txt"
"${P7}/capture.sh" "05-db-fixed"
