#!/usr/bin/env bash
# cloudflare-whoami.sh — Wrangler / Cloudflare account (OAuth or API token).
set -euo pipefail

run_wrangler() {
  if command -v wrangler >/dev/null 2>&1; then
    wrangler "$@"
  elif command -v npx >/dev/null 2>&1; then
    npx --yes wrangler "$@"
  else
    echo "Install Wrangler: npm install -g wrangler  (or use npx)" >&2
    exit 1
  fi
}

run_wrangler whoami
