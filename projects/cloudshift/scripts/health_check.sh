#!/usr/bin/env sh
set -eu

curl --fail --silent http://localhost:8000/health
echo
