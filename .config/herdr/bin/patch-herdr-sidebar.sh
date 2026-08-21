#!/usr/bin/env bash
# Patch alexarthurs/herdr-sidebar for herdr 0.8:
# `pane run` sends keystrokes into a shell (no launch_argv, races the prompt).
# Auto-dock and git launchers must use `plugin pane open` / a delayed exec.
#
# Also teaches the unix ensure hook to handle a REPLACE decision. Upstream's
# ensure-sidebar.sh bails unless the decision is exactly OPEN, so a corpse pane
# (a Sidebar/Explorer label around a dead TUI — what a server-restart resume
# leaves behind) blocks the dock forever and the sidebar silently never appears.
# src/ensure.rs (the Windows sidecar) and both launcher scripts already do this.
set -euo pipefail

export PATH="${HOME}/.cargo/bin:/opt/homebrew/bin:/usr/local/bin:${PATH}"

ROOT="$(
  herdr plugin list --json | python3 -c '
import json, sys
data = json.load(sys.stdin)
plugins = data.get("result", data).get("plugins", [])
for p in plugins:
    if p.get("plugin_id") == "herdr-sidebar" or p.get("id") == "herdr-sidebar":
        print(p.get("plugin_root") or "")
        break
'
)"

if [[ -z "$ROOT" || ! -d "$ROOT/scripts" ]]; then
  echo "herdr-sidebar plugin root not found; skip 0.8 patch" >&2
  exit 0
fi

python3 - "$ROOT" <<'PY'
import pathlib
import sys

root = pathlib.Path(sys.argv[1])
marker = "# herdr-0.8-plugin-pane-open"
replace_marker = "# herdr-sidebar-ensure-replace"

# Everything after the lock's EXIT trap is rewritten. The dock block becomes a
# function so both the OPEN and the REPLACE branch can call it; it retries the
# `pane run` that races the shell prompt, and holds the lock until the fresh
# TUI stamps its identity token (a queued hook that sees a label-without-token
# pane would otherwise call it a corpse and kill it mid-boot — endless churn).
ENSURE_BODY = r'''
snooze_dir="${TMPDIR:-/tmp}/herdr-sidebar-snooze"
# A tab whose last dock attempt failed. Healing a corpse means closing a pane,
# so a launch that can never succeed would otherwise close-and-redock on every
# single focus event, forever. The marker rate-limits that to one attempt per
# FAIL_COOLDOWN seconds.
fail_dir="${TMPDIR:-/tmp}/herdr-sidebar-ensure-fail"
FAIL_COOLDOWN=300

# The TUI stamps an identity token on startup; until it does, the pane is
# indistinguishable from a corpse. A decision of FOCUS/CLOSE means the focused
# tab holds a sidebar that is recognisably alive.
sidebar_live() {
  local d
  d="$("$herdr_bin" pane list 2>/dev/null | "$bin" --launch-decision 2>/dev/null || true)"
  case "$d" in
    "FOCUS "* | "CLOSE "*) return 0 ;;
    *) return 1 ;;
  esac
}

# herdr-0.8-plugin-pane-open
# pane run sends keystrokes; wait for the shell. Do not use `plugin pane open
# --cwd` — herdr then resolves ./target/release/herdr-sidebar from that cwd.
dock_sidebar() {
  local panes="$1"
  local fp fid fcwd target ratio plan out np live=""

  fp="$(printf '%s' "$panes" | "$bin" --focused-pane 2>/dev/null || true)"
  fid="${fp%%	*}"
  fcwd="${fp#*	}"
  [ -n "$fid" ] || return 1

  target="$fid"
  ratio="0.25"
  plan="$("$herdr_bin" pane layout --pane "$fid" 2>/dev/null | "$bin" --open-plan 2>/dev/null || true)"
  if [ -n "$plan" ]; then
    target="${plan%%	*}"
    ratio="${plan#*	}"
  fi

  out="$("$herdr_bin" pane split "$target" --direction right --ratio "$ratio" \
    ${fcwd:+--cwd "$fcwd"} --no-focus 2>/dev/null || true)"
  np="$(printf '%s' "$out" | sed -n 's/.*"pane_id":"\([^"]*\)".*/\1/p' | head -n1)"
  [ -n "$np" ] || return 1

  # Move the new pane into the left slot, then start the sidebar in it.
  "$herdr_bin" pane swap --source-pane "$np" --target-pane "$target" >/dev/null 2>&1 || true

  # `pane run` types into the pane's shell, so it races the prompt: keystrokes
  # sent before the shell reads stdin are dropped and the pane sits empty. Wait
  # for the identity token and re-send if it never arrives — only ever while no
  # live sidebar is recognised, so a resend can't land as keystrokes inside a
  # running TUI. This loop also HOLDS THE LOCK until the TUI has stamped:
  # a queued hook that saw a label-without-token pane would call it a corpse
  # and kill it mid-boot, churning panes endlessly.
  for _ in 1 2 3; do
    sleep 0.8
    "$herdr_bin" pane run "$np" exec "$bin"
    for _ in $(seq 1 8); do
      sleep 0.5
      if sidebar_live; then
        live=1
        break
      fi
    done
    [ -n "$live" ] && break
  done

  "$herdr_bin" pane rename "$np" Explorer >/dev/null 2>&1 || true

  # Hand focus back if the swap left it on the explorer (focus follows the slot).
  if [ "$target" = "$fid" ]; then
    "$herdr_bin" pane focus --direction right --pane "$np" >/dev/null 2>&1 || true
  fi

  [ -n "$live" ]
}

# Snapshot AFTER acquiring the lock, so a just-finished ensure's rename is visible.
panes="$("$herdr_bin" pane list 2>/dev/null || true)"
[ -n "$panes" ] || exit 0

decision="$(printf '%s' "$panes" | "$bin" --launch-decision 2>/dev/null || true)"
tab="$(printf '%s' "$panes" | "$bin" --focused-tab 2>/dev/null || true)"
fail_file=""
[ -n "$tab" ] && fail_file="$fail_dir/${tab//:/_}"

# Record whether the dock succeeded, so a tab that cannot launch the TUI stops
# being re-docked on every focus event.
mark_dock() {
  if "$@"; then
    [ -n "$fail_file" ] && rm -f "$fail_file" 2>/dev/null
  elif [ -n "$fail_file" ]; then
    mkdir -p "$fail_dir" 2>/dev/null
    : > "$fail_file"
  fi
  return 0
}

case "$decision" in
  OPEN)
    # Respect a tab the user toggled closed (open-explorer.sh writes the marker) —
    # otherwise the very next focus event would reopen what they just closed.
    [ -n "$tab" ] && [ -f "$snooze_dir/${tab//:/_}" ] && exit 0
    mark_dock dock_sidebar "$panes"
    ;;
  "REPLACE "*)
    # herdr-sidebar-ensure-replace
    # A corpse: a Sidebar/Explorer-labelled pane whose TUI is gone (stale
    # heartbeat, or a server-restart resume that restored the label around a
    # fresh shell). No event heals it by itself and it blocks every later dock,
    # so close it and dock a fresh one — snooze does not apply, the user never
    # asked for this pane to be empty. Matches src/ensure.rs (the Windows
    # sidecar) and both launcher scripts.
    if [ -n "$fail_file" ] && [ -f "$fail_file" ]; then
      now="$(date +%s)"
      born="$(stat -c %Y "$fail_file" 2>/dev/null || stat -f %m "$fail_file" 2>/dev/null || echo "$now")"
      [ $((now - born)) -gt "$FAIL_COOLDOWN" ] || exit 0
    fi
    pid="${decision#REPLACE }"
    "$herdr_bin" pane close "$pid" >/dev/null 2>&1 || true
    # A pane list snapshot goes stale the moment a pane closes — if the corpse
    # was focused, the old snapshot still names it and the split target would
    # be pane_not_found. Re-snapshot before computing where to dock.
    panes="$("$herdr_bin" pane list 2>/dev/null || true)"
    [ -n "$panes" ] || exit 0
    mark_dock dock_sidebar "$panes"
    ;;
esac
exit 0
'''

ensure = root / "scripts" / "ensure-sidebar.sh"
text = ensure.read_text()
if marker in text and replace_marker in text:
    print(f"already patched {ensure}")
else:
    anchor = "trap 'rmdir \"$lock_dir\" 2>/dev/null' EXIT\n"
    at = text.find(anchor)
    if at == -1:
        print(f"warn: could not patch {ensure}", file=sys.stderr)
    else:
        head = text[: at + len(anchor)]
        # A dock now takes up to ~15s; the stale-lock break must stay above it
        # or a slow dock loses its lock and a second ensure docks a duplicate.
        head = head.replace("now - born)) -gt 30 ]", "now - born)) -gt 60 ]")
        ensure.write_text(head + ENSURE_BODY)
        print(f"patched {ensure}")


def replace_run(path: pathlib.Path, old: str, new: str) -> None:
    t = path.read_text()
    if new.strip() in t and "sleep 0.6" in t:
        print(f"already patched {path}")
        return
    if old not in t:
        print(f"warn: pattern missing in {path}", file=sys.stderr)
        return
    path.write_text(t.replace(old, new, 1))
    print(f"patched {path}")


open_sb = root / "scripts" / "open-sidebar.sh"
replace_run(
    open_sb,
    '"$herdr_bin" pane run "$np" "exec \\"$bin\\""',
    'sleep 0.6\n  "$herdr_bin" pane run "$np" exec "$bin"',
)
t = open_sb.read_text()
if "--entrypoint filetree" in t:
    open_sb.write_text(t.replace("--entrypoint filetree", "--entrypoint sidebar"))
    print(f"fixed entrypoint in {open_sb}")

open_git = root / "scripts" / "open-git.sh"
replace_run(
    open_git,
    '"$herdr_bin" pane run "$np" "exec \\"$bin\\" --view git"',
    'sleep 0.6\n  "$herdr_bin" pane run "$np" exec "$bin" --view git',
)
PY
