#!/usr/bin/env bash
# vercel-whoami.sh — Logged-in Vercel user / team context.
set -euo pipefail

if ! command -v vercel >/dev/null 2>&1; then
  echo "Vercel CLI not found. Install: npm i -g vercel" >&2
  exit 1
fi

vercel whoami "$@"
