#!/usr/bin/env bash
# saas-whoami.sh — Edge / SaaS CLI identity for whatever is installed (continues on errors).
set -uo pipefail

section() { printf '\n── %s ──\n' "$1"; }

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
any=false

section_cloudflare() {
  section "Cloudflare (wrangler)"
  "$SCRIPT_DIR/cloudflare-whoami.sh" || echo "(wrangler whoami failed)"
}

section_vercel() {
  section "Vercel"
  "$SCRIPT_DIR/vercel-whoami.sh" || echo "(vercel whoami failed)"
}

section_netlify() {
  section "Netlify"
  "$SCRIPT_DIR/netlify-whoami.sh" || echo "(netlify status failed)"
}

section_fly() {
  section "Fly.io"
  "$SCRIPT_DIR/fly-whoami.sh" || echo "(fly auth whoami failed)"
}

section_railway() {
  section "Railway"
  "$SCRIPT_DIR/railway-whoami.sh" || echo "(railway whoami failed)"
}

section_doppler() {
  section "Doppler"
  "$SCRIPT_DIR/doppler-whoami.sh" || echo "(doppler me failed)"
}

if command -v wrangler >/dev/null 2>&1 || command -v npx >/dev/null 2>&1; then
  any=true
  section_cloudflare
fi

if command -v vercel >/dev/null 2>&1; then
  any=true
  section_vercel
fi

if command -v netlify >/dev/null 2>&1; then
  any=true
  section_netlify
fi

if command -v fly >/dev/null 2>&1 || command -v flyctl >/dev/null 2>&1; then
  any=true
  section_fly
fi

if command -v railway >/dev/null 2>&1; then
  any=true
  section_railway
fi

if command -v doppler >/dev/null 2>&1; then
  any=true
  section_doppler
fi

if ! $any; then
  echo "No wrangler/npx, vercel, netlify, fly, railway, or doppler CLI found in PATH."
  exit 1
fi
