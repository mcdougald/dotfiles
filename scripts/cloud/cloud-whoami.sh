#!/usr/bin/env bash
# cloud-whoami.sh — AWS / GCP / Azure / kubectl. For Vercel, Cloudflare, etc. see saas-whoami.sh.
set -euo pipefail

section() { printf '\n── %s ──\n' "$1"; }

if command -v aws >/dev/null 2>&1; then
  section "AWS"
  aws sts get-caller-identity 2>&1 || echo "(not authenticated or no permissions)"
fi

if command -v gcloud >/dev/null 2>&1; then
  section "Google Cloud"
  active_account="$(gcloud auth list --filter=status:ACTIVE --format='value(account)' 2>/dev/null | { head -1 || true; })" || true
  [[ -n "$active_account" ]] && echo "active account: $active_account"
  proj="$(gcloud config get-value project 2>/dev/null || true)"
  [[ -n "$proj" && "$proj" != "(unset)" ]] && echo "project: $proj"
fi

if command -v az >/dev/null 2>&1; then
  section "Azure"
  az account show --query '{name:name, user:user.name, subscriptionId:id}' -o table 2>&1 || echo "(not logged in)"
fi

if command -v kubectl >/dev/null 2>&1; then
  section "Kubernetes"
  echo "current-context: $(kubectl config current-context 2>/dev/null || echo '(none)')"
fi

if ! command -v aws >/dev/null 2>&1 && ! command -v gcloud >/dev/null 2>&1 && ! command -v az >/dev/null 2>&1 && ! command -v kubectl >/dev/null 2>&1; then
  echo "No AWS, gcloud, Azure CLI, or kubectl found in PATH."
  exit 1
fi
