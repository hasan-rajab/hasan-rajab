#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/_common.sh"
LABEL="${1:?label required}"
OUT="cloud/phase7/evidence/${LABEL}.txt"
{
echo "CloudShift Phase 7 Evidence — ${LABEL}"
echo "Captured: $(date -u +"%Y-%m-%dT%H:%M:%SZ")"
echo
echo "=== Containers ==="; docker compose -f "$BASE" ps -a || true
echo
echo "=== API health ==="; curl -sS -i --max-time 3 "$API/health" || true
echo
echo "=== Prometheus target ==="; prom 'up{job="cloudshift-api"}'
echo
echo "=== 5xx rate ==="; prom 'sum(rate(cloudshift_errors_total{status_class="5xx"}[5m]))'
echo
echo "=== API P95 ==="; prom 'histogram_quantile(0.95,sum by (le) (rate(cloudshift_request_duration_seconds_bucket[5m])))'
echo
echo "=== Shipping timeout total ==="; prom 'sum(cloudshift_dependency_requests_total{dependency="shipping",outcome="timeout"})'
echo
echo "=== Shipping auth failure total ==="; prom 'sum(cloudshift_dependency_requests_total{dependency="shipping",outcome="auth_failure"})'
echo
echo "=== Audit events ==="; curl -sS --max-time 3 "$API/audit-events?limit=10" || true
echo
echo "=== Structured logs ==="; docker logs cloudshift-p6-api --tail=60 2>&1 || true
} > "$OUT"
echo "Evidence written: $OUT"
