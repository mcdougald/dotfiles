#!/usr/bin/env bash
# k8s-context.sh — Show current kubectl context and cluster server (quick sanity check).
set -euo pipefail

if ! command -v kubectl >/dev/null 2>&1; then
  echo "kubectl not found in PATH." >&2
  exit 1
fi

echo "current-context: $(kubectl config current-context 2>/dev/null || echo '(none)')"
ctx="$(kubectl config current-context 2>/dev/null || true)"
if [[ -n "$ctx" ]]; then
  server="$(kubectl config view --minify -o jsonpath='{.clusters[0].cluster.server}' 2>/dev/null || true)"
  [[ -n "$server" ]] && echo "server: $server"
fi
