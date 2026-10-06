#!/usr/bin/env bash
set -euo pipefail
D="$(cd "$(dirname "$0")" && pwd)"
"${D}/00-preflight.sh"
for S in \
  01-bad-environment-variable \
  02-api-timeout \
  03-incorrect-http-status \
  04-container-configuration \
  05-database-bottleneck \
  06-api-authentication-failure \
  07-connection-pool-saturation
do
  echo
  echo "============================================================"
  echo "Running $S"
  echo "============================================================"
  "${D}/scenarios/${S}/run.sh"
done
"${D}/build-summary.sh"
echo "All Phase 7 scenarios completed."
