#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/_common.sh"
curl -fsS "$PROM/-/healthy" >/dev/null
curl -fsS "$GRAFANA/api/health" >/dev/null
wait_api
curl -fsS "$API/audit-events?limit=1" >/dev/null
echo "Phase 7 preflight passed."
