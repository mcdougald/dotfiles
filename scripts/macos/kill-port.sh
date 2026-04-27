#!/usr/bin/env bash
# kill-port.sh — Stop whatever is listening on a TCP port (dev servers, stale processes).
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: kill-port.sh <port> [--signal SIG]

Examples:
  kill-port.sh 3000
  kill-port.sh 8080 --signal SIGKILL

Default signal: SIGTERM (accepts TERM or 15 as well)
EOF
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" || $# -lt 1 ]]; then
  usage
  exit 0
fi

PORT="$1"
SIGNAL="TERM"
shift || true

while [[ $# -gt 0 ]]; do
  case "$1" in
    --signal)
      SIGNAL="${2:?}"
      shift 2
      ;;
    *)
      echo "Unknown option: $1" >&2
      usage >&2
      exit 1
      ;;
  esac
done

if ! [[ "$PORT" =~ ^[0-9]+$ ]] || [[ "$PORT" -lt 1 || "$PORT" -gt 65535 ]]; then
  echo "Invalid port: $PORT" >&2
  exit 1
fi

SIGNAL="${SIGNAL#SIG}"

PIDS="$(lsof -nP -iTCP:"$PORT" -sTCP:LISTEN -t 2>/dev/null || true)"
if [[ -z "$PIDS" ]]; then
  echo "Nothing listening on TCP port $PORT."
  exit 0
fi

echo "Sending -$SIGNAL to PIDs on port $PORT: $PIDS"
# shellcheck disable=SC2086
kill -"$SIGNAL" $PIDS
