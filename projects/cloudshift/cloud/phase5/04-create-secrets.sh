#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/_common.sh"

TMP_DIR="$(mktemp -d)"
trap 'rm -rf "${TMP_DIR}"' EXIT

DB_PASSWORD_FILE="${TMP_DIR}/db-password"
SHIPPING_TOKEN_FILE="${TMP_DIR}/shipping-token"

openssl rand -base64 30 | tr -d '\n' > "${DB_PASSWORD_FILE}"
openssl rand -hex 24 | tr -d '\n' > "${SHIPPING_TOKEN_FILE}"

if gcloud secrets describe "${DB_PASSWORD_SECRET}" >/dev/null 2>&1; then
  echo "DB password secret already exists; not rotating automatically."
  DB_SECRET_EXISTS=1
else
  gcloud secrets create "${DB_PASSWORD_SECRET}" --replication-policy=automatic
  gcloud secrets versions add "${DB_PASSWORD_SECRET}" \
    --data-file="${DB_PASSWORD_FILE}"
  DB_SECRET_EXISTS=0
fi

if gcloud secrets describe "${SHIPPING_TOKEN_SECRET}" >/dev/null 2>&1; then
  echo "Shipping token secret already exists; not rotating automatically."
else
  gcloud secrets create "${SHIPPING_TOKEN_SECRET}" --replication-policy=automatic
  gcloud secrets versions add "${SHIPPING_TOKEN_SECRET}" \
    --data-file="${SHIPPING_TOKEN_FILE}"
fi

gcloud secrets add-iam-policy-binding "${DB_PASSWORD_SECRET}" \
  --member="serviceAccount:${RUN_SA_EMAIL}" \
  --role="roles/secretmanager.secretAccessor" \
  --quiet >/dev/null

gcloud secrets add-iam-policy-binding "${SHIPPING_TOKEN_SECRET}" \
  --member="serviceAccount:${RUN_SA_EMAIL}" \
  --role="roles/secretmanager.secretAccessor" \
  --quiet >/dev/null

if [[ "${DB_SECRET_EXISTS}" == "0" ]]; then
  DB_PASSWORD="$(cat "${DB_PASSWORD_FILE}")"

  if gcloud sql users list \
      --instance="${SQL_INSTANCE}" \
      --format="value(name)" | grep -qx "${DB_USER}"; then
    echo "Database user exists; updating its password to match the new secret."
    gcloud sql users set-password "${DB_USER}" \
      --instance="${SQL_INSTANCE}" \
      --password="${DB_PASSWORD}"
  else
    gcloud sql users create "${DB_USER}" \
      --instance="${SQL_INSTANCE}" \
      --password="${DB_PASSWORD}"
  fi
else
  echo
  echo "Important: existing DB secret was preserved."
  echo "If the database user/password was already configured during an earlier run, continue."
fi

echo
echo "Secrets and access policy configured."
