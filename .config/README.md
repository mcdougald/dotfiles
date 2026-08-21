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

## opencode

```bash
mkdir -p ~/.config/opencode
ln -sfn "$DOTFILES/.config/opencode/opencode.json" ~/.config/opencode/opencode.json
ln -sfn "$DOTFILES/.config/opencode/tui.json"      ~/.config/opencode/tui.json
ln -sfn "$DOTFILES/.config/opencode/AGENTS.md"     ~/.config/opencode/AGENTS.md
ln -sfn "$DOTFILES/.config/opencode/agent"         ~/.config/opencode/agent
ln -sfn "$DOTFILES/.config/opencode/command"       ~/.config/opencode/command
```

Runtime config (`opencode.json`) is split from TUI preferences (`tui.json`);
both are JSONC and annotated inline. Bash permissions are an allowlist —
read-only inspection and test runners run unattended, mutating git and network
tools ask, `sudo` / force-push / pipe-to-shell are denied. Credentials live in
`~/.local/share/opencode/auth.json`, not here.

See `opencode/README.md` for the permission model, keybinds, and how to add
agents and commands. Verify with `opencode debug config`.

## Claude Code (`~/.claude`)

```bash
mkdir -p ~/.claude
ln -sfn "$DOTFILES/.config/claude/settings.json" ~/.claude/settings.json
```

Project-level rules live in each repo’s `CLAUDE.md`. For a reusable template, see `agents/AGENTS.md`; opencode also reads `CLAUDE.md` via its `instructions` setting, so one file covers both.

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

## CLI tooling

Standard XDG locations — link the directory or the single file into
`~/.config/<name>/`:

| Path | Tool | Notes |
| --- | --- | --- |
| `starship.toml` | [Starship](https://starship.rs) | Prompt (alternative to the p10k config at repo root). |
| `bat/config` | [bat](https://github.com/sharkdp/bat) | `cat` with syntax highlighting. |
| `ripgrep/config` | [ripgrep](https://github.com/BurntSushi/ripgrep) | Point `RIPGREP_CONFIG_PATH` at it. |
| `fd/ignore` | [fd](https://github.com/sharkdp/fd) | Global ignore patterns. |
| `git/` | Git | `ignore` (global gitignore) + `include-delta.gitconfig` for [delta](https://github.com/dandavison/delta). |
| `gh/` | [GitHub CLI](https://cli.github.com) | `config.yml` + `hosts.yml`; auth tokens are stored in the keychain, not here. |
| `lazygit/config.yml` | [lazygit](https://github.com/jesseduffield/lazygit) | Git TUI. |
| `helix/config.toml` | [Helix](https://helix-editor.com) | Modal editor. |
| `zellij/` | [Zellij](https://zellij.dev) | `config.kdl` + `layouts/`. |
| `mise/config.toml` | [mise](https://mise.jdx.dev) | Runtime/tool versions. |
| `direnv/direnv.toml` | [direnv](https://direnv.net) | Per-directory environments. |
| `ruff/ruff.toml` | [Ruff](https://docs.astral.sh/ruff/) | Python lint/format defaults. |
| `taplo/taplo.toml` | [Taplo](https://taplo.tamasfe.dev) | TOML formatter. |

## One-shot macOS linker

```bash
bash "$DOTFILES/.config/link-macos.sh"
```

Links Zed, Herdr, Claude Code, opencode, and Antigravity. Review the script before
running; it retargets existing symlinks and backs up real files it replaces
(`<name>.backup-<timestamp>`).
