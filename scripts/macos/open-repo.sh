#!/usr/bin/env bash
# open-repo.sh — From a git repo root, open the remote URL in the default browser (GitHub/GitLab/etc.).
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel 2>/dev/null)" || {
  echo "Not inside a git repository." >&2
  exit 1
}

cd "$ROOT"
URL="$(git remote get-url origin 2>/dev/null)" || {
  echo "No origin remote." >&2
  exit 1
}

if [[ "$URL" =~ ^https?:// ]]; then
  :
elif [[ "$URL" == git@*:* ]]; then
  host="${URL#git@}"
  host="${host%%:*}"
  path="${URL#*:}"
  path="${path%.git}"
  URL="https://${host}/${path}"
elif [[ "$URL" == ssh://git@* ]]; then
  rest="${URL#ssh://git@}"
  rest="${rest/://}"
  rest="${rest%.git}"
  URL="https://${rest}"
else
  URL="${URL%.git}"
fi

if [[ "$(uname -s)" == "Darwin" ]]; then
  open "$URL"
else
  echo "$URL"
fi
