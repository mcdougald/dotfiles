#!/usr/bin/env bash
# aws-identity.sh — STS caller identity (optional profile / JSON).
set -euo pipefail

usage() {
  cat <<'EOF'
Usage:
  aws-identity.sh              # uses current profile / instance role
  aws-identity.sh --profile P  # sets AWS_PROFILE for this invocation
  aws-identity.sh --json       # raw JSON only
EOF
}

PROFILE=""
JSON_ONLY=false
while [[ $# -gt 0 ]]; do
  case "$1" in
    --profile|-p) PROFILE="${2:?}"; shift 2 ;;
    --json) JSON_ONLY=true; shift ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown: $1" >&2; usage >&2; exit 1 ;;
  esac
done

if ! command -v aws >/dev/null 2>&1; then
  echo "aws CLI not found." >&2
  exit 1
fi

if [[ -n "$PROFILE" ]]; then
  export AWS_PROFILE="$PROFILE"
fi

if $JSON_ONLY; then
  exec aws sts get-caller-identity
fi

echo "AWS_PROFILE=${AWS_PROFILE:-<default>}"
aws sts get-caller-identity --output table
