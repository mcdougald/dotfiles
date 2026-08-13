#!/usr/bin/env bash
# Toggle the herdr-sidebar explorer.
#
# herdr 0.8 `pane run` types into the pane shell (it does not exec a process),
# so we wait for the prompt then `exec` the absolute binary. `plugin pane open`
# cannot take --cwd: it would resolve ./target/release/herdr-sidebar from that
# directory and fail.
set -euo pipefail

herdr="${HERDR_BIN_PATH:-herdr}"
cwd="${HERDR_ACTIVE_PANE_CWD:-$PWD}"

bin="$(
  "$herdr" plugin list --json | python3 -c '
import json, sys
data = json.load(sys.stdin)
plugins = data.get("result", data).get("plugins", [])
for p in plugins:
    if p.get("plugin_id") == "herdr-sidebar" or p.get("id") == "herdr-sidebar":
        root = p.get("plugin_root") or ""
        if root:
            print(root.rstrip("/") + "/target/release/herdr-sidebar")
        break
'
)"

if [[ -z "$bin" || ! -x "$bin" ]]; then
  echo "herdr-sidebar binary not found. bash ~/.config/herdr/install-plugins.sh" >&2
  exit 1
fi

decision="$(
  "$herdr" pane list | python3 -c '
import json, sys
data = json.load(sys.stdin)
panes = data.get("result", data).get("panes", [])
focused = next((p for p in panes if p.get("focused")), None)
if not focused:
    print("OPEN")
    raise SystemExit
tab = focused.get("tab_id")
explorers = []
for p in panes:
    if p.get("tab_id") != tab:
        continue
    tokens = p.get("tokens") or {}
    label = p.get("label") or ""
    if "herdr-sidebar-explorer" in tokens or label in ("Explorer", "Sidebar"):
        explorers.append(p)
if not explorers:
    print("OPEN")
elif any(p.get("focused") for p in explorers):
    print("CLOSE", explorers[0]["pane_id"])
else:
    print("FOCUS", explorers[0]["pane_id"])
'
)"

case "$decision" in
  OPEN)
    tab="$(
      "$herdr" pane list | python3 -c '
import json, sys
data = json.load(sys.stdin)
panes = data.get("result", data).get("panes", [])
focused = next((p for p in panes if p.get("focused")), None)
print((focused or {}).get("tab_id") or "")
'
    )"
    [[ -n "$tab" ]] && rm -f "${TMPDIR:-/tmp}/herdr-sidebar-snooze/${tab//:/_}"
    out="$("$herdr" pane split --current --direction right --ratio 0.75 --cwd "$cwd" --no-focus)"
    np="$(printf '%s' "$out" | python3 -c 'import json,sys; print(json.load(sys.stdin)["result"]["pane"]["pane_id"])')"
    sleep 0.8
    "$herdr" pane run "$np" exec "$bin"
    "$herdr" pane rename "$np" Explorer >/dev/null 2>&1 || true
    "$herdr" pane zoom "$np" --on >/dev/null 2>&1 || true
    "$herdr" pane zoom "$np" --off
    ;;
  CLOSE\ *)
    tab="$(
      "$herdr" pane list | python3 -c '
import json, sys
data = json.load(sys.stdin)
panes = data.get("result", data).get("panes", [])
focused = next((p for p in panes if p.get("focused")), None)
print((focused or {}).get("tab_id") or "")
'
    )"
    if [[ -n "$tab" ]]; then
      mkdir -p "${TMPDIR:-/tmp}/herdr-sidebar-snooze"
      : > "${TMPDIR:-/tmp}/herdr-sidebar-snooze/${tab//:/_}"
    fi
    exec "$herdr" pane close "${decision#CLOSE }"
    ;;
  FOCUS\ *)
    pid="${decision#FOCUS }"
    "$herdr" pane zoom "$pid" --on >/dev/null 2>&1 || true
    exec "$herdr" pane zoom "$pid" --off
    ;;
  *)
    echo "herdr-sidebar: unexpected decision: $decision" >&2
    exit 1
    ;;
esac
