#!/usr/bin/env bash
set -euo pipefail
P7="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "${P7}/../.." && pwd)"
BASE="cloud/phase6/docker-compose.phase6.yml"
API="http://localhost:8080"
PROM="http://localhost:9090"
GRAFANA="http://localhost:3001"
cd "${ROOT}"

wait_api() {
  for _ in $(seq 1 30); do curl -fsS "${API}/health" >/dev/null 2>&1 && return 0; sleep 1; done
  return 1
}
wait_api_down() {
  for _ in $(seq 1 20); do ! curl -fsS "${API}/health" >/dev/null 2>&1 && return 0; sleep 1; done
  return 1
}
prom() {
  python3 - "$PROM" "$1" <<'PY2'
import json,sys,urllib.parse,urllib.request
url=sys.argv[1]+"/api/v1/query?"+urllib.parse.urlencode({"query":sys.argv[2]})
try:
    d=json.load(urllib.request.urlopen(url,timeout=5))
    r=d.get("data",{}).get("result",[])
    print("NO_DATA" if not r else "\n".join(json.dumps({"metric":x.get("metric",{}),"value":x.get("value",[None,None])[1]}) for x in r[:20]))
except Exception as e: print("PROM_QUERY_FAILED:",e)
PY2
}
