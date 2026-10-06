#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/_common.sh"
docker compose -f "$BASE" up -d --force-recreate api shipping
wait_api
echo "Healthy Phase 6 base restored."
