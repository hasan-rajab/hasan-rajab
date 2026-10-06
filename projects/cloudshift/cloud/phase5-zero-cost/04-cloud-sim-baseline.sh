#!/usr/bin/env bash
set -euo pipefail
DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT="$(cd "${DIR}/../.." && pwd)"
cd "${ROOT}"
python3 scripts/http_load_test.py \
  --url http://localhost:8080/products \
  --requests 1000 \
  --concurrency 50 \
  --timeout 10
