# Shared application config (dotfiles)

Paths below assume `DOTFILES` is the root of this repository, for example:

```bash
DOTFILES="$HOME/workspace/dotfiles"
```

## Herdr

Agent multiplexer. Copy **managed files only** (runtime logs/sockets/session
state stay in `~/.config/herdr`):

```bash
rsync -a --exclude session.json --exclude session-history.json \
  --exclude '*.log' --exclude '*.log.*' --exclude '*.sock' \
  "$DOTFILES/.config/herdr/" ~/.config/herdr/
```

Or link only `config.toml`:

```bash
mkdir -p ~/.config/herdr
ln -sfn "$DOTFILES/.config/herdr/config.toml" ~/.config/herdr/config.toml
```

See `herdr/README.md` for install, reload, integrations, plugins, and keybindings.

## Zed

```bash
mkdir -p ~/.config/zed
ln -sfn "$DOTFILES/.config/zed/settings.json" ~/.config/zed/settings.json
```

Optional: merge keys from `zed/context_servers.example.json` into your local `settings.json` (fill tokens locally; do not commit secrets).

## Raycast

Raycast stores secrets in `config.json`. Keep tokens out of git:

```bash
cp "$DOTFILES/.config/raycast/config.json.example" \
  "$HOME/Library/Application Support/com.raycast.macos/config.json"
# Edit config.json and paste tokens from Raycast → Settings → Advanced
```

## Claude Code (`~/.claude`)

```bash
mkdir -p ~/.claude
ln -sfn "$DOTFILES/.config/claude/settings.json" ~/.claude/settings.json
```

Project-level rules live in each repo’s `CLAUDE.md`. For a reusable template, see `agents/AGENTS.md`.

## Antigravity

VS Code–style user config lives under Application Support:

```bash
AG_USER="$HOME/Library/Application Support/Antigravity/User"
mkdir -p "$AG_USER"
ln -sfn "$DOTFILES/.config/antigravity/User/settings.json" "$AG_USER/settings.json"
ln -sfn "$DOTFILES/.config/antigravity/User/keybindings.json" "$AG_USER/keybindings.json"
```

Planning/agent artifacts may also appear under `~/.gemini/antigravity/`; that tree is machine-specific and is usually not symlinked wholesale.

## GitHub Copilot (VS Code / Cursor)

- Canonical editor settings in this repo: `.config/.vscode/user-settings.json`
- Extra Copilot keys for reference or merging: `copilot/vscode-settings.fragment.json`

Symlink into your editor’s `User` folder (example for Cursor):

```bash
CURSOR_USER="$HOME/Library/Application Support/Cursor/User"
mkdir -p "$CURSOR_USER"
ln -sfn "$DOTFILES/.config/.vscode/user-settings.json" "$CURSOR_USER/settings.json"
```

## iTerm2

See `iterm2/README.md` (color import + optional `AppSupport` symlink).

## Agents (repo template)

Copy `agents/AGENTS.md` into a project root when you want shared agent instructions across tools.

## One-shot macOS linker

```bash
bash "$DOTFILES/.config/link-macos.sh"
```

Review the script before running; it overwrites existing symlink targets for the same names.
