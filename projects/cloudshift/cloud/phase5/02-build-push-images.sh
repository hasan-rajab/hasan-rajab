#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/_common.sh"

echo "Building API image..."
docker build --platform linux/amd64 -t "${API_IMAGE}" .

echo "Building shipping image..."
docker build --platform linux/amd64 -t "${SHIPPING_IMAGE}" ./mock_shipping

echo "Building frontend image..."
docker build --platform linux/amd64 \
  -f frontend/Dockerfile.cloud \
  -t "${FRONTEND_IMAGE}" \
  ./frontend

echo "Pushing images..."
docker push "${API_IMAGE}"
docker push "${SHIPPING_IMAGE}"
docker push "${FRONTEND_IMAGE}"

echo
echo "Images pushed:"
echo "${API_IMAGE}"
echo "${SHIPPING_IMAGE}"
echo "${FRONTEND_IMAGE}"
