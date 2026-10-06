#!/usr/bin/env bash
set -euo pipefail

LOG_FILE="/tmp/cloudshift-firestore-emulator.log"
PID_FILE="/tmp/cloudshift-firestore-emulator.pid"

if curl -fsS http://127.0.0.1:8085/ >/dev/null 2>&1; then
  echo "Firestore emulator already appears to be running on port 8085."
  exit 0
fi

echo "Starting Firestore emulator on 0.0.0.0:8085..."
nohup gcloud emulators firestore start \
  --host-port=0.0.0.0:8085 \
  --project=cloudshift-local \
  > "${LOG_FILE}" 2>&1 &

echo $! > "${PID_FILE}"

for i in $(seq 1 30); do
  if curl -sS http://127.0.0.1:8085/ >/dev/null 2>&1; then
    echo "Firestore emulator started."
    echo "Log: ${LOG_FILE}"
    exit 0
  fi
  sleep 1
done

echo "Firestore emulator did not become ready."
echo "Last log lines:"
tail -n 40 "${LOG_FILE}" || true
exit 1
