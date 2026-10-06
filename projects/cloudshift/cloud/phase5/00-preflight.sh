#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/_common.sh"

for cmd in gcloud docker curl openssl; do
  if ! command -v "${cmd}" >/dev/null 2>&1; then
    echo "Missing required command: ${cmd}"
    exit 1
  fi
done

echo "gcloud:"
gcloud version | head -n 1
echo
echo "docker:"
docker --version
echo

gcloud config set project "${PROJECT_ID}"
gcloud config set run/region "${REGION}"

echo
echo "Active account:"
gcloud auth list --filter=status:ACTIVE --format="value(account)"
echo
echo "Project:"
gcloud config get-value project
echo
echo "Region:"
gcloud config get-value run/region
