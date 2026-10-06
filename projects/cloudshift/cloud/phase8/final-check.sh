#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$ROOT"

echo "=== Required files ==="
for f in \
  README.md \
  docs/architecture.md \
  docs/migration-story.md \
  docs/troubleshooting-scoreboard.md \
  docs/interview-guide.md \
  docs/portfolio-copy.md \
  cloud/phase7/PHASE7_RESULTS.md
do
  if [[ -f "$f" ]]; then
    echo "OK  $f"
  else
    echo "MISSING  $f"
  fi
done

echo
echo "=== Secret-pattern scan ==="
if grep -RInE \
  --exclude-dir=.git \
  --exclude='*.zip' \
  '(AIza[0-9A-Za-z_-]{20,}|-----BEGIN (RSA |EC |OPENSSH )?PRIVATE KEY-----)' \
  .; then
  echo
  echo "Potential secret-like values found. Review before committing."
  exit 1
else
  echo "No obvious Google API key/private-key patterns found."
fi

echo
echo "=== Accuracy checks ==="
if grep -RInE \
  --exclude-dir=.git \
  '(deployed (to|on) Cloud Run|live Cloud SQL deployment)' \
  README.md docs cloud/phase8 2>/dev/null; then
  echo "Review wording above to ensure live deployment is not falsely claimed."
else
  echo "No obvious live-deployment overclaim found."
fi

echo
echo "=== Git status ==="
git status --short 2>/dev/null || echo "Not currently inside a Git repository."

echo
echo "Final portfolio check complete."
