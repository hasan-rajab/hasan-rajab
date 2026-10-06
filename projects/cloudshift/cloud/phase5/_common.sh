#!/usr/bin/env bash
set -euo pipefail

PHASE5_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${PHASE5_DIR}/../.." && pwd)"
ENV_FILE="${PHASE5_DIR}/phase5.env"

if [[ ! -f "${ENV_FILE}" ]]; then
  echo "Missing ${ENV_FILE}"
  echo "Create it first:"
  echo "  cp cloud/phase5/phase5.env.example cloud/phase5/phase5.env"
  echo "Then edit PROJECT_ID."
  exit 1
fi

# shellcheck disable=SC1090
source "${ENV_FILE}"

: "${PROJECT_ID:?PROJECT_ID is required}"
: "${REGION:?REGION is required}"
: "${REPOSITORY:?REPOSITORY is required}"

AR_HOST="${REGION}-docker.pkg.dev"
API_IMAGE="${AR_HOST}/${PROJECT_ID}/${REPOSITORY}/api:v1"
SHIPPING_IMAGE="${AR_HOST}/${PROJECT_ID}/${REPOSITORY}/shipping:v1"
FRONTEND_IMAGE="${AR_HOST}/${PROJECT_ID}/${REPOSITORY}/frontend:v1"
RUN_SA_EMAIL="${RUN_SERVICE_ACCOUNT}@${PROJECT_ID}.iam.gserviceaccount.com"

cd "${ROOT_DIR}"
