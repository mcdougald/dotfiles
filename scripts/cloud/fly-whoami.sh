#!/usr/bin/env bash
# fly-whoami.sh — Fly.io authenticated user / orgs.
set -euo pipefail

if ! command -v fly >/dev/null 2>&1 && ! command -v flyctl >/dev/null 2>&1; then
  echo "Fly CLI not found. Install: https://fly.io/docs/hands-on/install-flyctl/" >&2
  exit 1
fi

FLY=(fly)
command -v fly >/dev/null 2>&1 || FLY=(flyctl)

"${FLY[@]}" auth whoami "$@"
