#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/_common.sh"

API_URL="$(gcloud run services describe "${API_SERVICE}" \
  --region="${REGION}" \
  --format="value(status.url)")"

python3 scripts/http_load_test.py \
  --url "${API_URL}/products" \
  --requests 1000 \
  --concurrency 50 \
  --timeout 10
