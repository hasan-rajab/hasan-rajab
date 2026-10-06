#!/usr/bin/env bash
set -euo pipefail
D="$(cd "$(dirname "$0")" && pwd)"
source "${D}/../../_common.sh"
docker compose -f "$BASE" -f "${D}/broken.compose.yml" up -d --force-recreate api
wait_api_down || true
sleep 12
"${P7}/capture.sh" "04-container-broken"
docker exec cloudshift-p6-api python -c 'import urllib.request; print("internal=",urllib.request.urlopen("http://127.0.0.1:8080/health").status)' || true
docker inspect cloudshift-p6-api --format '{{json .Config.Cmd}}' || true
"${P7}/recover_base.sh"
sleep 10
"${P7}/capture.sh" "04-container-fixed"
