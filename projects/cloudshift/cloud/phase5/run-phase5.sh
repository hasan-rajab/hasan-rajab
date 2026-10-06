#!/usr/bin/env bash
set -euo pipefail

DIR="$(cd "$(dirname "$0")" && pwd)"

"${DIR}/00-preflight.sh"
"${DIR}/01-bootstrap-gcp.sh"
"${DIR}/02-build-push-images.sh"
"${DIR}/03-create-cloudsql.sh"
"${DIR}/04-create-secrets.sh"
"${DIR}/05-deploy-shipping.sh"
"${DIR}/06-deploy-api.sh"
"${DIR}/07-seed-cloudsql.sh"
"${DIR}/08-deploy-frontend.sh"
"${DIR}/09-verify.sh"

echo
echo "Phase 5 deployment complete."
echo "Run the cloud baseline separately:"
echo "  sh cloud/phase5/10-cloud-baseline.sh"
