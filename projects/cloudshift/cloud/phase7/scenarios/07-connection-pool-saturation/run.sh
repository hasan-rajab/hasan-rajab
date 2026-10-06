#!/usr/bin/env bash
set -euo pipefail
D="$(cd "$(dirname "$0")" && pwd)"
source "${D}/../../_common.sh"
docker compose -f "$BASE" -f "${D}/broken.compose.yml" up -d --force-recreate api
wait_api
python3 scripts/http_load_test.py --url "$API/diagnostics/db-work" \
  --requests 200 --concurrency 50 --timeout 5 \
  | tee "cloud/phase7/evidence/07-pool-broken-load.txt"
sleep 10
"${P7}/capture.sh" "07-pool-broken"

docker compose -f "$BASE" -f scenarios/07-traffic-connection-pool/fixed.compose.yml \
  up -d --force-recreate api
wait_api
python3 scripts/http_load_test.py --url "$API/diagnostics/db-work" \
  --requests 200 --concurrency 50 --timeout 5 \
  | tee "cloud/phase7/evidence/07-pool-fixed-load.txt"
sleep 10
"${P7}/capture.sh" "07-pool-fixed"
"${P7}/recover_base.sh"
