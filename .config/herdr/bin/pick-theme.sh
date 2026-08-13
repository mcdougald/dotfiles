#!/usr/bin/env bash
# Fuzzy-pick a Herdr built-in theme, patch config.toml, reload.
# Bound as prefix+alt+m. Needs fzf + python3.
set -euo pipefail

CFG="${HERDR_CONFIG:-${XDG_CONFIG_HOME:-$HOME/.config}/herdr/config.toml}"
REV="${XDG_CONFIG_HOME:-$HOME/.config}/herdr/plugins/config/persiyanov.reviewr/config.toml"

if ! command -v fzf >/dev/null 2>&1; then
  echo "brew install fzf"
  read -r _
  exit 1
fi
if ! command -v python3 >/dev/null 2>&1; then
  echo "python3 is required"
  read -r _
  exit 1
fi
if [[ ! -f "$CFG" ]]; then
  echo "missing $CFG"
  read -r _
  exit 1
fi

sel=$(
  fzf --prompt='theme> ' --height=100% --reverse --header='Herdr built-in themes (Enter applies + reload)' <<'EOF'
tokyo-night	dark · current default
tokyo-night-day	light sibling of tokyo-night
catppuccin	dark mocha (Herdr default)
catppuccin-latte	light catppuccin
dracula	dark purple/pink
nord	dark frosty blues
gruvbox	dark warm retro
gruvbox-light	light gruvbox
one-dark	dark Atom
one-light	light Atom
solarized	dark Ethan Schoonover
solarized-light	light Ethan Schoonover
kanagawa	dark Hokusai
kanagawa-lotus	light kanagawa
rose-pine	dark muted
rose-pine-dawn	light rosé pine
vesper	dark high-contrast peach/mint
terminal	follow host terminal ANSI
EOF
) || true

name="${sel%%	*}"
name="${name%% *}"
[[ -n "$name" ]] || exit 0

python3 - "$CFG" "$REV" "$name" <<'PY'
import re
import sys
from pathlib import Path

cfg_path = Path(sys.argv[1])
rev_path = Path(sys.argv[2])
name = sys.argv[3]

pairs = {
    "catppuccin": ("catppuccin", "catppuccin-latte"),
    "catppuccin-latte": ("catppuccin", "catppuccin-latte"),
    "tokyo-night": ("tokyo-night", "tokyo-night-day"),
    "tokyo-night-day": ("tokyo-night", "tokyo-night-day"),
    "gruvbox": ("gruvbox", "gruvbox-light"),
    "gruvbox-light": ("gruvbox", "gruvbox-light"),
    "one-dark": ("one-dark", "one-light"),
    "one-light": ("one-dark", "one-light"),
    "solarized": ("solarized", "solarized-light"),
    "solarized-light": ("solarized", "solarized-light"),
    "kanagawa": ("kanagawa", "kanagawa-lotus"),
    "kanagawa-lotus": ("kanagawa", "kanagawa-lotus"),
    "rose-pine": ("rose-pine", "rose-pine-dawn"),
    "rose-pine-dawn": ("rose-pine", "rose-pine-dawn"),
}

palettes = {
    "tokyo-night": dict(accent="#7aa2f7", blue="#7aa2f7", teal="#7dcfff", yellow="#e0af68", green="#9ece6a", red="#f7768e", mauve="#bb9af7"),
    "tokyo-night-day": dict(accent="#2e7de9", blue="#2e7de9", teal="#007197", yellow="#8c6c3e", green="#587539", red="#f52a65", mauve="#9854f1"),
    "catppuccin": dict(accent="#89b4fa", blue="#89b4fa", teal="#94e2d5", yellow="#f9e2af", green="#a6e3a1", red="#f38ba8", mauve="#cba6f7"),
    "catppuccin-latte": dict(accent="#1e66f5", blue="#1e66f5", teal="#179299", yellow="#df8e1d", green="#40a02b", red="#d20f39", mauve="#8839ef"),
    "dracula": dict(accent="#bd93f9", blue="#8be9fd", teal="#8be9fd", yellow="#f1fa8c", green="#50fa7b", red="#ff5555", mauve="#bd93f9"),
    "nord": dict(accent="#88c0d0", blue="#81a1c1", teal="#88c0d0", yellow="#ebcb8b", green="#a3be8c", red="#bf616a", mauve="#b48ead"),
    "gruvbox": dict(accent="#83a598", blue="#83a598", teal="#8ec07c", yellow="#fabd2f", green="#b8bb26", red="#fb4934", mauve="#d3869b"),
    "gruvbox-light": dict(accent="#076678", blue="#076678", teal="#427b58", yellow="#b57614", green="#79740e", red="#9d0006", mauve="#8f3f71"),
    "one-dark": dict(accent="#61afef", blue="#61afef", teal="#56b6c2", yellow="#e5c07b", green="#98c379", red="#e06c75", mauve="#c678dd"),
    "one-light": dict(accent="#4078f2", blue="#4078f2", teal="#0184bc", yellow="#c18401", green="#50a14f", red="#e45649", mauve="#a626a4"),
    "solarized": dict(accent="#268bd2", blue="#268bd2", teal="#2aa198", yellow="#b58900", green="#859900", red="#dc322f", mauve="#6c71c4"),
    "solarized-light": dict(accent="#268bd2", blue="#268bd2", teal="#2aa198", yellow="#b58900", green="#859900", red="#dc322f", mauve="#6c71c4"),
    "kanagawa": dict(accent="#7e9cd8", blue="#7e9cd8", teal="#7aa89f", yellow="#c0a36e", green="#98bb6c", red="#e82424", mauve="#957fb8"),
    "kanagawa-lotus": dict(accent="#4d699b", blue="#4d699b", teal="#597b75", yellow="#77713f", green="#6f894e", red="#c84053", mauve="#624c83"),
    "rose-pine": dict(accent="#c4a7e7", blue="#9ccfd8", teal="#31748f", yellow="#f6c177", green="#9ccfd8", red="#eb6f92", mauve="#c4a7e7"),
    "rose-pine-dawn": dict(accent="#907aa9", blue="#56949f", teal="#286983", yellow="#ea9d34", green="#56949f", red="#b4637a", mauve="#907aa9"),
    "vesper": dict(accent="#ffc799", blue="#a0a0a0", teal="#99ffe4", yellow="#ffc799", green="#99ffe4", red="#ff8080", mauve="#ffc799"),
}

reviewr_ok = {
    "catppuccin", "dracula", "nord", "gruvbox", "one-dark", "solarized",
    "tokyo-night", "rose-pine", "catppuccin-latte", "gruvbox-light",
    "one-light", "solarized-light", "tokyo-night-day", "rose-pine-dawn",
}

text = cfg_path.read_text()

if name in pairs:
    dark, light = pairs[name]
else:
    dark = name if name != "terminal" else "terminal"
    light = "catppuccin-latte" if name != "terminal" else "terminal"

def set_first(src: str, key: str, value: str) -> str:
    return re.sub(
        rf'^({re.escape(key)}\s*=\s*")[^"]*(")',
        rf'\1{value}\2',
        src,
        count=1,
        flags=re.M,
    )

def custom_value(src, key):
    custom = re.search(r"(?ms)^\[theme\.custom\]\n(.*?)(?=\n\[|\Z)", src)
    if not custom:
        return None
    m = re.search(rf'^{re.escape(key)}\s*=\s*"([^"]*)"', custom.group(0), flags=re.M)
    return m.group(1) if m else None

old_yellow = custom_value(text, "yellow")
old_teal = custom_value(text, "teal")
old_mauve = custom_value(text, "mauve")

text = set_first(text, "name", name)
text = set_first(text, "light_name", light)
text = set_first(text, "dark_name", dark)

palette = palettes.get(name)
if palette:
    custom = re.search(r"(?ms)^\[theme\.custom\]\n(.*?)(?=\n\[|\Z)", text)
    if custom:
        block = custom.group(0)
        for key, value in palette.items():
            block = re.sub(
                rf'^({re.escape(key)}\s*=\s*")[^"]*(")',
                rf'\1{value}\2',
                block,
                count=1,
                flags=re.M,
            )
        text = text[: custom.start()] + block + text[custom.end() :]

    # [ui] accent is the second `accent =` in this file.
    accents = list(re.finditer(r'^accent\s*=\s*"[^"]*"', text, flags=re.M))
    if len(accents) >= 2:
        m = accents[1]
        text = text[: m.start()] + f'accent = "{palette["accent"]}"' + text[m.end() :]

    swaps = (
        (old_yellow, palette["yellow"]),
        (old_teal, palette["teal"]),
        (old_mauve, palette["mauve"]),
    )
    for old, new in swaps:
        if old and old != new:
            text = text.replace(f'fg = "{old}"', f'fg = "{new}"')

cfg_path.write_text(text)

if name in reviewr_ok and rev_path.is_file():
    rev = rev_path.read_text()
    rev2, n = re.subn(
        r'^theme\s*=\s*"[^"]*"',
        f'theme = "{name}"',
        rev,
        count=1,
        flags=re.M,
    )
    if n:
        rev_path.write_text(rev2)

print(f"theme → {name}  (dark={dark}  light={light})")
PY

if command -v herdr >/dev/null 2>&1; then
  herdr server reload-config >/dev/null 2>&1 || true
fi

echo
echo "applied. enter to close."
read -r _
