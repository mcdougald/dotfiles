#!/usr/bin/env bash
# doppler-whoami.sh — Doppler CLI authenticated user / workplace.
set -euo pipefail

if ! command -v doppler >/dev/null 2>&1; then
  echo "Doppler CLI not found. Install: brew install dopplerhq/cli/doppler" >&2
  exit 1
fi

doppler me "$@"
