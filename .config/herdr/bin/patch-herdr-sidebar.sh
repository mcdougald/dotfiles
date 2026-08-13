#!/usr/bin/env bash
# Patch alexarthurs/herdr-sidebar for herdr 0.8:
# `pane run` sends keystrokes into a shell (no launch_argv, races the prompt).
# Auto-dock and git launchers must use `plugin pane open` / a delayed exec.
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

ensure = root / "scripts" / "ensure-sidebar.sh"
text = ensure.read_text()
if marker not in text:
    old = '''fp="$(printf '%s' "$panes" | "$bin" --focused-pane 2>/dev/null || true)"
fid="${fp%%\t*}"
fcwd="${fp#*\t}"
[ -n "$fid" ] || exit 0

target="$fid"
ratio="0.25"
plan="$("$herdr_bin" pane layout --pane "$fid" 2>/dev/null | "$bin" --open-plan 2>/dev/null || true)"
if [ -n "$plan" ]; then
  target="${plan%%\t*}"
  ratio="${plan#*\t}"
fi

out="$("$herdr_bin" pane split "$target" --direction right --ratio "$ratio" \\
  ${fcwd:+--cwd "$fcwd"} --no-focus 2>/dev/null || true)"
np="$(printf '%s' "$out" | sed -n 's/.*"pane_id":"\\([^"]*\\)".*/\\1/p' | head -n1)"
[ -n "$np" ] || exit 0

"$herdr_bin" pane swap --source-pane "$np" --target-pane "$target" >/dev/null 2>&1 || true
"$herdr_bin" pane run "$np" "exec \\"$bin\\""
"$herdr_bin" pane rename "$np" Explorer >/dev/null 2>&1 || true

# Hand focus back if the swap left it on the explorer (focus follows the slot).
if [ "$target" = "$fid" ]; then
  "$herdr_bin" pane focus --direction right --pane "$np" >/dev/null 2>&1 || true
fi
exit 0
'''
    new = f'''{marker}
fp="$(printf '%s' "$panes" | "$bin" --focused-pane 2>/dev/null || true)"
fid="${{fp%%	*}}"
fcwd="${{fp#*	}}"
[ -n "$fid" ] || exit 0

target="$fid"
ratio="0.25"
plan="$("$herdr_bin" pane layout --pane "$fid" 2>/dev/null | "$bin" --open-plan 2>/dev/null || true)"
if [ -n "$plan" ]; then
  target="${{plan%%	*}}"
  ratio="${{plan#*	}}"
fi

out="$("$herdr_bin" pane split "$target" --direction right --ratio "$ratio" \\
  ${{fcwd:+--cwd "$fcwd"}} --no-focus 2>/dev/null || true)"
np="$(printf '%s' "$out" | sed -n 's/.*"pane_id":"\\([^"]*\\)".*/\\1/p' | head -n1)"
[ -n "$np" ] || exit 0

"$herdr_bin" pane swap --source-pane "$np" --target-pane "$target" >/dev/null 2>&1 || true
sleep 0.8
"$herdr_bin" pane run "$np" exec "$bin"
"$herdr_bin" pane rename "$np" Explorer >/dev/null 2>&1 || true

if [ "$target" = "$fid" ]; then
  "$herdr_bin" pane focus --direction right --pane "$np" >/dev/null 2>&1 || true
fi
exit 0
'''
    if old not in text:
        # Tabs in the file are real tabs; retry with the file's own block
        # by replacing from the focused-pane snapshot through exit 0.
        start = text.find('fp="$(printf')
        end = text.rfind('exit 0\n')
        if start == -1 or end == -1:
            print(f"warn: could not patch {ensure}", file=sys.stderr)
        else:
            ensure.write_text(text[:start] + new + text[end + len('exit 0\n'):])
            print(f"patched {ensure}")
    else:
        ensure.write_text(text.replace(old, new, 1))
        print(f"patched {ensure}")
else:
    print(f"already patched {ensure}")

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
