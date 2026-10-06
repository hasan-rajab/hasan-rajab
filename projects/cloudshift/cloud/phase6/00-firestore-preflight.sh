#!/usr/bin/env bash
set -euo pipefail

for command in gcloud java curl; do
  if ! command -v "${command}" >/dev/null 2>&1; then
    echo "Missing required command: ${command}"
    exit 1
  fi
done

echo "gcloud:"
gcloud version | head -n 1

echo
echo "Java:"
JAVA_LINE="$(java -version 2>&1 | head -n 1)"
echo "${JAVA_LINE}"

JAVA_MAJOR="$(java -XshowSettings:properties -version 2>&1 \
  | awk -F'= ' '/java.specification.version/ {print $2; exit}' \
  | awk -F. '{print ($1 == "1" ? $2 : $1)}')"

if [[ -z "${JAVA_MAJOR}" || "${JAVA_MAJOR}" -lt 21 ]]; then
  echo
  echo "Java 21+ is required for the current Firestore emulator."
  echo "Install/upgrade Java, then run this preflight again."
  exit 1
fi

echo
echo "Updating gcloud CLI components..."
gcloud components update --quiet

echo
echo "Ensuring the Cloud Firestore Emulator component is installed..."
gcloud components install cloud-firestore-emulator --quiet

echo
echo "Firestore emulator command:"
gcloud emulators firestore start --help >/dev/null
echo "available"

echo
echo "Preflight passed."
