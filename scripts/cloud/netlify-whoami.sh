#!/usr/bin/env bash
# netlify-whoami.sh — Netlify auth status / linked site context.
set -euo pipefail

if ! command -v netlify >/dev/null 2>&1; then
  echo "Netlify CLI not found. Install: npm i -g netlify-cli" >&2
  exit 1
fi

netlify status "$@"
