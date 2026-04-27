#!/usr/bin/env bash
# flush-dns.sh — Flush macOS DNS and mDNS caches (common fix after VPN / hosts edits).
set -euo pipefail

if [[ "$(uname -s)" != "Darwin" ]]; then
  echo "This script is for macOS only." >&2
  exit 1
fi

echo "Flushing DNS cache (requires sudo)..."
sudo dscacheutil -flushcache 2>/dev/null || true
sudo killall -HUP mDNSResponder 2>/dev/null || true
echo "Done. Try your lookup again."
