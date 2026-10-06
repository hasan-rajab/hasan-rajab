#!/usr/bin/env bash
set -euo pipefail

DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT="$(cd "${DIR}/../.." && pwd)"
cd "${ROOT}"

docker compose -f cloud/phase6/docker-compose.phase6.yml up --build -d
docker compose -f cloud/phase6/docker-compose.phase6.yml ps
