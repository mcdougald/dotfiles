#!/usr/bin/env bash
# listening-ports.sh — Show TCP listeners with process names (lsof).
set -euo pipefail

# Optional: pass a port to filter (e.g. listening-ports.sh 5432)
FILTER="${1:-}"

if [[ -n "$FILTER" && ! "$FILTER" =~ ^[0-9]+$ ]]; then
  echo "Usage: $0 [port]" >&2
  exit 1
fi

if [[ -n "$FILTER" ]]; then
  lsof -nP -iTCP:"$FILTER" -sTCP:LISTEN
else
  lsof -nP -iTCP -sTCP:LISTEN | awk 'NR==1 || $8 ~ /LISTEN/'
fi
