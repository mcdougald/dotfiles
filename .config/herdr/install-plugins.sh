#!/usr/bin/env bash
# Install the Herdr plugins this dotfiles config binds.
# Safe to re-run. Plugin user config is keyed by id and survives reinstall.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [[ -d "$SCRIPT_DIR/plugin-config" ]]; then
  EXAMPLES="$SCRIPT_DIR/plugin-config"
else
  EXAMPLES="$(cd "$SCRIPT_DIR/../.." && pwd)/.config/herdr/plugin-config"
fi

export PATH="${HOME}/.cargo/bin:/opt/homebrew/bin:/usr/local/bin:${PATH}"

if ! command -v herdr >/dev/null 2>&1; then
  echo "herdr is not on PATH. brew install herdr" >&2
  exit 1
fi

ensure_cargo() {
  if command -v cargo >/dev/null 2>&1; then
    return 0
  fi
  echo "==> cargo not found (herdr-sidebar builds with cargo). Installing rust…"
  if command -v brew >/dev/null 2>&1; then
    brew install rust
  else
    echo "Install Rust (https://rustup.rs) and re-run." >&2
    return 1
  fi
  hash -r
  command -v cargo >/dev/null 2>&1
}

FAILED=()

install_one() {
  local spec="$1"
  echo "==> herdr plugin install $spec"
  if herdr plugin install "$spec" --yes; then
    return 0
  fi
  echo "!! failed: $spec" >&2
  FAILED+=("$spec")
}

ensure_cargo || FAILED+=("cargo (required by alexarthurs/herdr-sidebar)")

install_one persiyanov/herdr-reviewr
install_one smarzban/herdr-file-viewer
install_one iurysza/herdr-tab-smart-rename
install_one alexarthurs/herdr-sidebar/plugins/herdr-sidebar
install_one andrewchng/herdr-sessionizer
install_one speardragon/herdr-plugin-manager
install_one tntpgh/herdr-control

REV_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/herdr/plugins/config/persiyanov.reviewr"
mkdir -p "$REV_DIR"
if [[ ! -e "$REV_DIR/config.toml" ]]; then
  cp "$EXAMPLES/persiyanov.reviewr.toml" "$REV_DIR/config.toml"
  echo "Wrote $REV_DIR/config.toml"
else
  echo "Kept existing $REV_DIR/config.toml"
fi

SR_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/herdr/plugins/config/tab-smart-rename"
mkdir -p "$SR_DIR"
if [[ ! -e "$SR_DIR/provider.env" ]]; then
  cp "$EXAMPLES/tab-smart-rename.provider.env.example" "$SR_DIR/provider.env"
  echo "Wrote $SR_DIR/provider.env (add OPENAI_API_KEY for model-backed names)"
else
  echo "Kept existing $SR_DIR/provider.env"
fi

SESS_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/herdr/plugins/config/sessionizer"
mkdir -p "$SESS_DIR"
if [[ ! -e "$SESS_DIR/config.toml" ]]; then
  cp "$EXAMPLES/sessionizer.toml" "$SESS_DIR/config.toml"
  echo "Wrote $SESS_DIR/config.toml"
else
  echo "Kept existing $SESS_DIR/config.toml"
fi

HC_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/herdr-control/projects"
mkdir -p "$HC_DIR"
if [[ ! -e "$HC_DIR/dotfiles.json" ]]; then
  cp "$EXAMPLES/herdr-control/projects/dotfiles.json" "$HC_DIR/dotfiles.json"
  echo "Wrote $HC_DIR/dotfiles.json"
else
  echo "Kept existing $HC_DIR/dotfiles.json"
fi

if command -v bun >/dev/null 2>&1; then
  herdr plugin action invoke start --plugin tab-smart-rename || true
else
  echo "bun not found — sessionizer and tab-smart-rename need Bun. brew install bun" >&2
fi

if ! command -v jq >/dev/null 2>&1; then
  echo "jq not found — herdr-control needs it. brew install jq" >&2
fi

echo
echo "Plugins:"
herdr plugin list || true
echo
echo "Reload Herdr: herdr server reload-config"
echo "Optional: brew install bun fzf glow git-delta bat jq rust"

if ((${#FAILED[@]})); then
  echo >&2
  echo "Failed installs: ${FAILED[*]}" >&2
  exit 1
fi
