#!/usr/bin/env bash
set -euo pipefail
DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT="$(cd "${DIR}/../.." && pwd)"
cd "${ROOT}"
docker compose -f cloud/phase5-zero-cost/docker-compose.cloud-sim.yml up --build -d
docker compose -f cloud/phase5-zero-cost/docker-compose.cloud-sim.yml ps
