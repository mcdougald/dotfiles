# iTerm2

## Color scheme

Import the repo theme:

1. iTerm2 → **Settings** → **Profiles** → **Colors** → **Color Presets** → **Import…**
2. Choose `themes/iterm/DoomOne.itermcolors` from this dotfiles repository.

## Optional: track Application Support via `~/.config`

Some setups keep a short symlink under XDG config pointing at Apple’s folder:

```bash
mkdir -p ~/.config/iterm2
ln -sfn "$HOME/Library/Application Support/iTerm2" ~/.config/iterm2/AppSupport
```

Replace or skip if you already manage `~/Library/Application Support/iTerm2` another way.

## Dynamic profiles

To version a full profile, export **JSON** from iTerm2 (or use **Dynamic Profiles** under *Application Support*) and store the exported file under this directory if you want it in git—avoid committing window titles or host-specific names.
