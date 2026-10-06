#!/usr/bin/env bash
set -euo pipefail

DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT="$(cd "${DIR}/../.." && pwd)"
cd "${ROOT}"

docker compose -f cloud/phase6/docker-compose.phase6.yml down

if [[ -f /tmp/cloudshift-firestore-emulator.pid ]]; then
  PID="$(cat /tmp/cloudshift-firestore-emulator.pid)"
  kill "${PID}" 2>/dev/null || true
  rm -f /tmp/cloudshift-firestore-emulator.pid
fi

curl -sS -d '' http://127.0.0.1:8085/shutdown >/dev/null 2>&1 || true

echo "Phase 6 local services stopped."
