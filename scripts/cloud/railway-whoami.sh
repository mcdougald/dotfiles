#!/usr/bin/env bash
# railway-whoami.sh — Railway CLI logged-in user.
set -euo pipefail

if ! command -v railway >/dev/null 2>&1; then
  echo "Railway CLI not found. Install: brew install railway  or  npm i -g @railway/cli" >&2
  exit 1
fi

railway whoami "$@"
