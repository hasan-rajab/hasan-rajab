#!/usr/bin/env bash
set -euo pipefail
D="$(cd "$(dirname "$0")" && pwd)"
source "${D}/../../_common.sh"
docker compose -f "$BASE" -f "${D}/broken.compose.yml" up -d --force-recreate api
wait_api
for i in $(seq 1 15); do curl -sS -o /dev/null "$API/orders/999999"; done
sleep 10
"${P7}/capture.sh" "03-http-status-broken"
curl -i "$API/orders/999999"
"${P7}/recover_base.sh"
curl -i "$API/orders/999999"
"${P7}/capture.sh" "03-http-status-fixed"
