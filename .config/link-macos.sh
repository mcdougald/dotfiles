#!/usr/bin/env bash
# Symlink dotfiles-managed configs into default macOS locations.
# Run from any directory: bash /path/to/dotfiles/.config/link-macos.sh
set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CFG="$DOTFILES/.config"

mkdir -p "$HOME/.config/zed"
ln -sfn "$CFG/zed/settings.json" "$HOME/.config/zed/settings.json"

mkdir -p "$HOME/.claude"
ln -sfn "$CFG/claude/settings.json" "$HOME/.claude/settings.json"

AG_USER="$HOME/Library/Application Support/Antigravity/User"
mkdir -p "$AG_USER"
ln -sfn "$CFG/antigravity/User/settings.json" "$AG_USER/settings.json"
ln -sfn "$CFG/antigravity/User/keybindings.json" "$AG_USER/keybindings.json"

echo "Linked Zed, Claude, and Antigravity User settings from $CFG"
echo "Skipped: Raycast (use raycast/config.json.example — contains secrets)"
echo "Skipped: Cursor/VS Code (pick Cursor vs VS Code User path yourself; see .config/README.md)"
