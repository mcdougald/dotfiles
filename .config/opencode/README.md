# opencode

Config for [opencode](https://opencode.ai) — the terminal AI coding agent.

## Layout

| File | Purpose |
| --- | --- |
| `opencode.json` | Agent/runtime config: models, permissions, LSP, formatters, MCP. |
| `tui.json` | Terminal-only preferences: theme, keybinds, notifications. |
| `AGENTS.md` | Global instructions loaded into every session. |
| `agent/*.md` | Custom subagents (`@review`, `@debug`). |
| `command/*.md` | Slash commands (`/commit`, `/review`, `/test`, `/explain`). |

Both JSON files are **JSONC** — opencode allows comments and trailing commas,
which is why they are annotated inline.

## Install

Handled by the repo linker:

```bash
bash "$DOTFILES/.config/link-macos.sh"
```

Or by hand:

```bash
mkdir -p ~/.config/opencode
ln -sfn "$DOTFILES/.config/opencode/opencode.json" ~/.config/opencode/opencode.json
ln -sfn "$DOTFILES/.config/opencode/tui.json"      ~/.config/opencode/tui.json
ln -sfn "$DOTFILES/.config/opencode/AGENTS.md"     ~/.config/opencode/AGENTS.md
ln -sfn "$DOTFILES/.config/opencode/agent"         ~/.config/opencode/agent
ln -sfn "$DOTFILES/.config/opencode/command"       ~/.config/opencode/command
```

Verify the merged result:

```bash
opencode debug config     # resolved config, all layers merged
opencode debug agent review
opencode debug paths      # where data/config/cache/state actually live
```

## Secrets

Credentials live in `~/.local/share/opencode/auth.json` (managed by
`opencode auth login`) — **not** in this directory, so nothing here is
sensitive. Give MCP servers their tokens via `{env:VAR}`, never inline.

## Config precedence

Later layers override earlier ones:

1. `~/.config/opencode/opencode.json` — this repo
2. `$OPENCODE_CONFIG` — explicit override path
3. `./opencode.json` — project root
4. `.opencode/` directories

Project files should carry project-specific rules only; anything you would want
on every machine belongs here.

## Choices worth knowing about

**Permissions are an allowlist, not a blanket yes.** `permission.bash` starts at
`"*": "ask"` and then opens up read-only inspection, git history, `gh` reads, and
test/build/lint runners. Mutating git, network fetches, and infra tools stay on
`ask`; `sudo`, force pushes, `rm -rf /`, and pipe-to-shell are `deny`. **Last
matching rule wins**, so ordering in that block is deliberate — append new rules
at the end of the tier they belong to.

**The `plan` agent is genuinely read-only.** The built-in `plan` only *asks*
before editing; the override here denies `edit` outright and allows a short list
of inspection commands. Use `tab` to cycle to `build` when you actually want
changes.

**Cross-tool instructions.** `instructions` pulls in `CLAUDE.md`,
`.cursor/rules/*.md`, and `.github/copilot-instructions.md` so a repo's
conventions apply no matter which agent is reading them. `AGENTS.md` next to
this file is loaded automatically.

**LSP and formatters are on.** Edits get real diagnostics, and files come back
formatted the way the repo expects rather than the way the model guessed.

## Keybinds

Leader is `ctrl+x`. `tui.json` only fills in actions opencode ships unbound;
everything else is stock.

| Key | Action |
| --- | --- |
| `<leader>n` / `<leader>l` | New session / session list |
| `<leader>m` / `<leader>a` | Model list / agent list |
| `tab` | Cycle agent (build ⇄ plan) |
| `ctrl+p` | Command palette |
| `<leader>c` | Compact session |
| `<leader>u` / `<leader>r` | Undo / redo (snapshot-backed) |
| `<leader>e` | Open the message in `$EDITOR` |
| `<leader>t` / `<leader>b` | Theme picker / sidebar |
| `<leader>f` | Fork session *(added here)* |
| `<leader>d` | Toggle full tool output *(added here)* |
| `<leader>i` | Toggle thinking blocks *(added here)* |
| `<leader>k` | Skill picker *(added here)* |
| `<leader>p` | MCP server list *(added here)* |
| `escape` | Interrupt |
| `ctrl+x ?` … | `ctrl+alt+k` shows the which-key overlay |

## Plugins

`oh-my-openagent` is declared in both files. Plugin installs write
`node_modules/`, `package.json`, and `bun.lock` into `~/.config/opencode`; the
local `.gitignore` keeps those out of the repo.

```bash
opencode plugin <module>   # install and record in config
opencode --pure            # start with external plugins disabled
```

## Adding an agent or command

Drop a markdown file in `agent/` or `command/`; the filename becomes the name.

```markdown
---
description: What it does and when to reach for it
mode: subagent          # subagent | primary | all
temperature: 0.1
permission:
  edit: deny
  bash:
    "*": deny
    "rg *": allow
---

The system prompt goes here.
```

Commands support `$ARGUMENTS` / `$1`, shell injection with `` !`cmd` ``, and file
references with `@path`.

## Docs

- Config reference — <https://opencode.ai/docs/config>
- Permissions — <https://opencode.ai/docs/permissions>
- Agents — <https://opencode.ai/docs/agents>
- Commands — <https://opencode.ai/docs/commands>
- TUI — <https://opencode.ai/docs/tui>
