#!/usr/bin/env bash
# ai-dev-check.sh — Sanity check local AI dev setup: CLIs, env var presence (values never printed).
set -euo pipefail

check_cmd() {
  if command -v "$1" >/dev/null 2>&1; then
    printf '  %-22s %s\n' "$1" "ok ($(command -v "$1"))"
  else
    printf '  %-22s %s\n' "$1" "missing"
  fi
}

check_env() {
  local n="$1"
  if [[ -n "${!n:-}" ]]; then
    printf '  %-22s %s\n' "$n" "set"
  else
    printf '  %-22s %s\n' "$n" "unset"
  fi
}

echo "Commands:"
check_cmd ollama
check_cmd gh
check_cmd kubectl
check_cmd claude || true

echo ""
echo "API keys / tokens (presence only):"
check_env OPENAI_API_KEY
check_env ANTHROPIC_API_KEY
check_env GOOGLE_API_KEY
check_env GEMINI_API_KEY
check_env COHERE_API_KEY
check_env HUGGINGFACE_HUB_TOKEN
check_env HF_TOKEN
check_env LANGCHAIN_API_KEY
check_env WANDB_API_KEY

if command -v ollama >/dev/null 2>&1; then
  echo ""
  echo "Ollama (first few models):"
  (set +o pipefail; ollama list 2>/dev/null | head -6) || echo "  (ollama list failed — is the daemon running?)"
fi

if command -v gh >/dev/null 2>&1; then
  echo ""
  echo "GitHub CLI:"
  gh auth status 2>&1 | sed 's/^/  /' || true
fi
