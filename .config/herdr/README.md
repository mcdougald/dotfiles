# Herdr

Agent-aware terminal multiplexer. Config is lean overrides only — Herdr works
without a file; this one customizes keys, theme, sidebar, notifications, and
worktrees.

Docs: [configuration](https://herdr.dev/docs/configuration/) ·
[config reference](https://herdr.dev/docs/config-reference/) ·
[keyboard](https://herdr.dev/docs/keyboard/) ·
[agents](https://herdr.dev/docs/agents/) ·
[session restore](https://herdr.dev/docs/session-state/)

## Install

```bash
brew install herdr
# macOS click-to-focus notifications
brew install terminal-notifier
```

Homebrew, mise, and Nix installs ignore Herdr’s own `preview` update channel.
Stay on `stable` (already set in `config.toml`).

## Deploy (do not replace the whole directory)

Runtime files (`*.log`, sockets, `session.json`) live in `~/.config/herdr`.
Copy or link **managed files only**.

```bash
DOTFILES="$HOME/workspace/dotfiles"
SRC="$DOTFILES/.config/herdr"
DST="$HOME/.config/herdr"
mkdir -p "$DST/bin" "$DST/plugin-config"
rsync -a --exclude session.json --exclude session-history.json \
  --exclude '*.log' --exclude '*.log.*' --exclude '*.sock' \
  "$SRC/" "$DST/"
```

Or symlink just `config.toml` (edits stay in the repo):

```bash
ln -sfn "$DOTFILES/.config/herdr/config.toml" ~/.config/herdr/config.toml
bash "$DOTFILES/.config/link-macos.sh"
```

Reload a running server after edits:

```bash
herdr server reload-config
# or prefix+shift+r inside Herdr
```

Print the installed build’s full default config:

```bash
herdr --default-config
```

Broken keybindings: `herdr config reset-keys` (backs up `config.toml`, strips
`[keys]` / `[[keys.command]]`).

## First-run agents

Integrations give native session restore (and lifecycle hooks where supported).
Screen detection still works without them.

```bash
herdr integration install claude
herdr integration install cursor
herdr integration install copilot
herdr integration install antigravity-cli
herdr integration status
```

Use the exact names from `herdr integration --help` / the [integrations](https://herdr.dev/docs/integrations/) list if an id differs.

Do **not** auto-enter tmux (or nest Zellij) inside Herdr panes. Detection then
sees `tmux` instead of the agent. Oh My Zsh’s `tmux` plugin is fine as long as
`ZSH_TMUX_AUTOSTART` is unset.

## Plugins

These community plugins are bound in `config.toml`. Install them after `herdr` is
on PATH (trust preview is skipped via `--yes` because these specs are pinned here):

```bash
bash "$DOTFILES/.config/herdr/install-plugins.sh"
```

| Plugin | Install spec | Keys |
| --- | --- | --- |
| [herdr-reviewr](https://github.com/persiyanov/herdr-reviewr) | `persiyanov/herdr-reviewr` | `prefix+alt+r` / `cmd+r` toggle |
| [herdr-file-viewer](https://github.com/smarzban/herdr-file-viewer) | `smarzban/herdr-file-viewer` | `prefix+f` split, `prefix+shift+f` tab |
| [herdr-tab-smart-rename](https://github.com/iurysza/herdr-tab-smart-rename) | `iurysza/herdr-tab-smart-rename` | `prefix+alt+t` now, `prefix+alt+shift+t` all |
| [herdr-sidebar](https://github.com/alexarthurs/herdr-sidebar) | `alexarthurs/herdr-sidebar/plugins/herdr-sidebar` | `prefix+shift+e` explorer, `prefix+shift+c` git |
| [herdr-sessionizer](https://github.com/andrewchng/herdr-sessionizer) | `andrewchng/herdr-sessionizer` | `ctrl+alt+f` projects, `prefix+up` worktrees |
| [herdr-plugin-manager](https://github.com/speardragon/herdr-plugin-manager) | `speardragon/herdr-plugin-manager` | `prefix+shift+m` / `ctrl+alt+p` |
| [herdr-control](https://github.com/tntpgh/herdr-control) | `tntpgh/herdr-control` | projects `prefix+alt+shift+o`, quick actions `prefix+alt+shift+q`, sort `prefix+shift+s`, name tab `prefix+alt+n`, attention `prefix+alt+shift+a` |
| [herdr-navigator](https://github.com/thanhdat77/herdr-navigator) | `thanhdat77/herdr-navigator` | `ctrl+alt+t` open |

`prefix+b` remains Herdr’s built-in agent/workspace sidebar. The plugin explorer
opens with `prefix+shift+e` or `ctrl+alt+e` (Herdr 0.8 `plugin pane open`, so it
restores after restart). Auto-dock on tab focus is patched the same way.

Renderers for the file viewer: `brew install glow git-delta bat`. Smart rename
needs [Bun](https://bun.sh) (`brew install bun`). herdr-sidebar compiles with
Rust (`brew install rust` — the install script does this if `cargo` is missing).
Model-backed names: add
`OPENAI_API_KEY` to `~/.config/herdr/plugins/config/tab-smart-rename/provider.env`
(example in `plugin-config/tab-smart-rename.provider.env.example`), then:

```bash
herdr plugin action invoke check-ai --plugin tab-smart-rename
herdr plugin action invoke start --plugin tab-smart-rename
```

Reviewr’s own config (theme, auto-open on worktrees) lives at
`~/.config/herdr/plugins/config/persiyanov.reviewr/config.toml` and is linked
from `plugin-config/persiyanov.reviewr.toml`.

Sessionizer scans `~/workspace` (git repos, depth 1). New workspaces get a
`dev` tab (shell + Claude + lazygit) and a spare `shell` tab. Picker is a 90%
popup. Override per repo with `<repo>/.sessionizer/config.toml`. Global file:
`plugin-config/sessionizer.toml` → `~/.config/herdr/plugins/config/sessionizer/config.toml`.
Needs Bun and fzf (`brew install bun fzf`).

Navigator is a fuzzy jump-to-anything picker across workspaces, agents,
projects, sessions, remotes, and zoxide/root directories. Its own default key
is `prefix+t`, already taken here by the scratch terminal, so it is bound to
`ctrl+alt+t` instead. First run writes a commented config to
`herdr plugin config-dir herdr-navigator`. Optional: `zoxide` for directory
history (already used elsewhere in this config).

Plugin manager is a popup over `herdr plugin` (install / update / disable /
marketplace). Official `prefix+p` is previous-tab here, so it is bound to
`prefix+shift+m` and `ctrl+alt+p`. Inside the popup: `m` marketplace, `u`
update, `e` toggle, `x` uninstall.

herdr-control adds project templates, quick actions, tab sort, smart names,
and “what needs me.” Templates live in `~/.config/herdr-control/projects/`
(example: `plugin-config/herdr-control/projects/dotfiles.json`). Needs `jq`
and `fzf` (`brew install jq fzf`). This install does **not** run
`herdr-control`’s `install.sh` (that wires Claude Code hooks).

## Themes

Default is `tokyo-night` with `auto_switch` to `tokyo-night-day`. Pick any
built-in live with `prefix+alt+m` (writes `config.toml` + reload). Built-ins:

`catppuccin`, `catppuccin-latte`, `tokyo-night`, `tokyo-night-day`,
`dracula`, `nord`, `gruvbox`, `gruvbox-light`, `one-dark`, `one-light`,
`solarized`, `solarized-light`, `kanagawa`, `kanagawa-lotus`, `rose-pine`,
`rose-pine-dawn`, `vesper`, `terminal` (host ANSI).

The picker also updates `[theme.custom]` tokens, sidebar accents, and
reviewr’s theme when the name exists there. Settings (`prefix+s`) can still
change the theme; that turns `auto_switch` off.

## Daily keys

Prefix is `ctrl+b`. Direct `ctrl+alt` chords are also bound for panes/tabs.

| Action | Key |
| --- | --- |
| Help (filter with `/`) | `prefix+?` |
| Toggle sidebar | `prefix+b` or `ctrl+alt+b` |
| New tab | `prefix+c` or `ctrl+alt+c` |
| Split right / down | `prefix+v` / `prefix+-` |
| Move panes | `prefix+h/j/k/l` or `ctrl+alt+h/j/k/l` |
| Workspaces | `prefix+w` |
| Detach (leave agents running) | `prefix+q` |
| lazygit | `prefix+alt+g` |
| Scratch terminal | `prefix+t` |
| git diff (delta) | `prefix+alt+d` |
| GitHub PRs | `prefix+alt+p` |
| Fuzzy file → editor | `prefix+alt+f` |
| k9s | `prefix+alt+k` |
| Agent dashboard | `prefix+alt+a` |
| Claude Code | `prefix+alt+c` |
| AI launcher (fzf) | `prefix+alt+i` |
| Prompt focused agent | `prefix+alt+s` |
| Ollama chat | `prefix+alt+o` |
| Reviewr (plugin) | `prefix+alt+r` or `cmd+r` |
| File viewer split / tab | `prefix+f` / `prefix+shift+f` |
| Smart rename tab / all | `prefix+alt+t` / `prefix+alt+shift+t` |
| Explorer / source control (plugin) | `prefix+shift+e` / `ctrl+alt+e` · `prefix+shift+c` |
| Sessionizer (projects) | `ctrl+alt+f` |
| Sessionizer (worktrees) | `prefix+up` |
| Plugin manager | `prefix+shift+m` or `ctrl+alt+p` |
| herdr-control projects | `prefix+alt+shift+o` |
| herdr-control quick actions | `prefix+alt+shift+q` |
| herdr-control sort tabs | `prefix+shift+s` |
| herdr-control name this tab | `prefix+alt+n` |
| herdr-control what needs me | `prefix+alt+shift+a` |
| Navigator (jump to anything) | `ctrl+alt+t` |
| Pick theme | `prefix+alt+m` |
| zoxide jump (scratch) | `prefix+alt+z` |
| Delete worktree checkout | `prefix+shift+backspace` |
| PR conversation | `prefix+alt+v` |
| PR checks (watch) | `prefix+alt+u` |
| Commit review (`git log -p`) | `prefix+alt+l` |
| Logs | `prefix+alt+j` |
| Process monitor | `prefix+alt+b` |
| Yank pane cwd | `prefix+y` |
| Next / previous agent | `prefix+.` / `prefix+,` |
| Agent 1–9 | `prefix+alt+1..9` |

Popups are session-modal (Herdr 0.8.0): they do not split the tab. Exit the tool or press Esc to close. Ctrl+right-click passes through to the pane app; plain right-click is Herdr’s menu.

In-app toasts (top-right) jump to the notifying pane on click. For detached or SSH sessions, set `ui.toast.delivery` to `"system"` or `"terminal"`.

## Local agent-detection overrides

Only add files under `~/.config/herdr/agent-detection/<agent>.toml` when a
bundled/remote manifest is wrong. Local files **always win** and will hide
upstream rule updates for that agent.

```bash
herdr server agent-manifests
herdr server update-agent-manifests
# after editing a local override:
herdr server reload-agent-manifests
herdr agent explain
```

## Security

`experimental.pane_history` stays off. Enabling it writes pane contents
(tokens, prompts, command output) to `session-history.json`. Treat that path
like shell history if you ever turn it on.
