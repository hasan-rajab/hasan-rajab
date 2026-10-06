#!/usr/bin/env bash
set -euo pipefail
D="$(cd "$(dirname "$0")" && pwd)"
source "${D}/../../_common.sh"
docker compose -f "$BASE" -f "${D}/broken.compose.yml" up -d --force-recreate api
wait_api_down || true
sleep 3
"${P7}/capture.sh" "01-bad-env-broken"
docker inspect cloudshift-p6-api --format '{{range .Config.Env}}{{println .}}{{end}}' | grep '^DB_' || true
docker compose -f "$BASE" exec -T db psql -U cloudshift -d cloudshift -c "SELECT current_database();" || true
"${P7}/recover_base.sh"
"${P7}/capture.sh" "01-bad-env-fixed"
