#!/usr/bin/env bash
# tls-expiry.sh — Show TLS certificate expiry for a host:port (defaults to 443).
set -euo pipefail

HOST="${1:-}"
PORT="${2:-443}"

if [[ -z "$HOST" || "$HOST" == "-h" || "$HOST" == "--help" ]]; then
  cat <<'EOF'
Usage: tls-expiry.sh <host> [port]

Examples:
  tls-expiry.sh api.example.com
  tls-expiry.sh localhost 8443
EOF
  exit 0
fi

if ! [[ "$PORT" =~ ^[0-9]+$ ]]; then
  echo "Invalid port: $PORT" >&2
  exit 1
fi

echo | openssl s_client -servername "$HOST" -connect "${HOST}:${PORT}" 2>/dev/null \
  | openssl x509 -noout -dates -subject 2>/dev/null \
  || { echo "Could not fetch certificate (host down, TLS error, or openssl missing)." >&2; exit 1; }
