#!/usr/bin/env bash
set -euo pipefail
D="$(cd "$(dirname "$0")" && pwd)"
source "${D}/../../_common.sh"
docker compose -f "$BASE" -f "${D}/broken.compose.yml" up -d --force-recreate api shipping
wait_api
for i in $(seq 1 12); do curl -sS -o /dev/null "$API/orders/1/shipping-quote" || true; done
sleep 10
"${P7}/capture.sh" "06-auth-broken"
prom 'sum(cloudshift_dependency_requests_total{dependency="shipping",outcome="auth_failure"})'
"${P7}/recover_base.sh"
for i in $(seq 1 5); do curl -fsS "$API/orders/1/shipping-quote" >/dev/null; done
sleep 10
"${P7}/capture.sh" "06-auth-fixed"
