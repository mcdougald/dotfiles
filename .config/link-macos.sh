#!/usr/bin/env bash
# Symlink dotfiles-managed configs into default macOS locations.
# Run from any directory: bash /path/to/dotfiles/.config/link-macos.sh
set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CFG="$DOTFILES/.config"

mkdir -p "$HOME/.config/zed"
ln -sfn "$CFG/zed/settings.json" "$HOME/.config/zed/settings.json"

mkdir -p "$HOME/.config/herdr"
ln -sfn "$CFG/herdr/config.toml" "$HOME/.config/herdr/config.toml"

REV_CFG="$HOME/.config/herdr/plugins/config/persiyanov.reviewr"
mkdir -p "$REV_CFG"
ln -sfn "$CFG/herdr/plugin-config/persiyanov.reviewr.toml" "$REV_CFG/config.toml"

SESS_CFG="$HOME/.config/herdr/plugins/config/sessionizer"
mkdir -p "$SESS_CFG"
ln -sfn "$CFG/herdr/plugin-config/sessionizer.toml" "$SESS_CFG/config.toml"

mkdir -p "$HOME/.config/herdr/bin"
ln -sfn "$CFG/herdr/bin/pick-theme.sh" "$HOME/.config/herdr/bin/pick-theme.sh"
ln -sfn "$CFG/herdr/bin/open-explorer.sh" "$HOME/.config/herdr/bin/open-explorer.sh"
ln -sfn "$CFG/herdr/bin/patch-herdr-sidebar.sh" "$HOME/.config/herdr/bin/patch-herdr-sidebar.sh"

HC_PROJ="$HOME/.config/herdr-control/projects"
mkdir -p "$HC_PROJ"
if [[ ! -e "$HC_PROJ/dotfiles.json" ]]; then
  cp "$CFG/herdr/plugin-config/herdr-control/projects/dotfiles.json" "$HC_PROJ/dotfiles.json"
fi

mkdir -p "$HOME/.claude"
ln -sfn "$CFG/claude/settings.json" "$HOME/.claude/settings.json"

AG_USER="$HOME/Library/Application Support/Antigravity/User"
mkdir -p "$AG_USER"
ln -sfn "$CFG/antigravity/User/settings.json" "$AG_USER/settings.json"
ln -sfn "$CFG/antigravity/User/keybindings.json" "$AG_USER/keybindings.json"

echo "Linked Zed, Herdr, Claude, and Antigravity User settings from $CFG"
echo "Skipped: Raycast (use raycast/config.json.example — contains secrets)"
echo "Skipped: Cursor/VS Code (pick Cursor vs VS Code User path yourself; see .config/README.md)"
echo "Herdr plugins: bash $CFG/herdr/install-plugins.sh"
