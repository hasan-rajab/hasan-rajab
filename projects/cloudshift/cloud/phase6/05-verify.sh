#!/usr/bin/env bash
set -euo pipefail

BASE="http://localhost:8080"

echo "=== API health ==="
curl -fsS "${BASE}/health"; echo

echo
echo "=== Recent Firestore audit events ==="
curl -fsS "${BASE}/audit-events?limit=10"; echo

echo
echo "=== Metrics markers ==="
curl -fsS "${BASE}/metrics" | grep -E \
  'cloudshift_(requests_total|errors_total|dependency_requests_total|audit_events_total|firestore_write_duration_seconds)' \
  | head -n 30

echo
echo "=== Prometheus health ==="
curl -fsS http://localhost:9090/-/healthy; echo

echo
echo "=== Grafana health ==="
curl -fsS http://localhost:3001/api/health; echo

echo
echo "=== Structured API log sample ==="
docker logs cloudshift-p6-api --tail=20 | tail -n 10

echo
echo "Phase 6 verification complete."
echo "Grafana:    http://localhost:3001  (admin / cloudshift)"
echo "Prometheus: http://localhost:9090"
