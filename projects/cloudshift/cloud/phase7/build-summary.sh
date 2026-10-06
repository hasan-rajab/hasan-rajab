#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/_common.sh"
OUT="cloud/phase7/PHASE7_RESULTS.md"
{
echo "# Phase 7 — Cloud-Style Troubleshooting Validation Results"
echo
echo "Generated: $(date -u +"%Y-%m-%dT%H:%M:%SZ")"
echo
echo "| # | Scenario | Primary operational evidence |"
echo "|---|---|---|"
echo "| 01 | Bad environment variable | target down + startup logs + healthy DB |"
echo "| 02 | API timeout | HTTP 504 + timeout metric + Firestore timeout audit |"
echo "| 03 | Incorrect HTTP status | false-success monitoring semantics |"
echo "| 04 | Container configuration | process up / endpoint down / target down |"
echo "| 05 | Database bottleneck | EXPLAIN ANALYZE + query-plan improvement |"
echo "| 06 | API authentication | upstream 401 + auth metric + audit event |"
echo "| 07 | Pool saturation | 503s + 5xx metrics + load-test recovery |"
echo
echo "## Evidence files"
for f in cloud/phase7/evidence/*; do [[ -f "$f" ]] && echo "- \`$f\`"; done
echo
echo "## Final health"
curl -fsS "$API/health" >/dev/null 2>&1 && echo "- API: healthy" || echo "- API: NOT healthy"
curl -fsS "$PROM/-/healthy" >/dev/null 2>&1 && echo "- Prometheus: healthy" || echo "- Prometheus: NOT healthy"
curl -fsS "$GRAFANA/api/health" >/dev/null 2>&1 && echo "- Grafana: healthy" || echo "- Grafana: NOT healthy"
} > "$OUT"
echo "Summary written: $OUT"
