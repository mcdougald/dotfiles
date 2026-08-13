#!/usr/bin/env bash
#
# setup_pop_os_2026.sh
#
# Bootstrap a Pop!_OS machine with Linuxbrew and modern dev tooling.
# Safe to re-run; most steps are idempotent.
#

set -euo pipefail

SCRIPT_NAME="$(basename "$0")"
BREW_BIN="/home/linuxbrew/.linuxbrew/bin/brew"
BREW_SHELLENV='eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"'
ZPROFILE="${HOME}/.zprofile"
ZSHRC="${HOME}/.zshrc"
OH_MY_ZSH_DIR="${HOME}/.oh-my-zsh"
OH_MY_ZSH_CUSTOM="${ZSH_CUSTOM:-${OH_MY_ZSH_DIR}/custom}"
MODE="${1:-full}"

APT_BASE_PACKAGES=(
  build-essential
  ca-certificates
  curl
  file
  git
  gpg
  lsb-release
  pkg-config
  software-properties-common
  unzip
  zip
)

APT_DEV_PACKAGES=(
  apt-transport-https
  bat
  btop
  command-not-found
  fd-find
  fontconfig
  fzf
  jq
  neovim
  pipx
  ripgrep
  shellcheck
  shfmt
  stow
  tmux
  tree
  xclip
  zsh
)

BREW_PACKAGES=(
  atuin
  bat
  bun
  deno
  direnv
  docker
  docker-compose
  duf
  dust
  eza
  fd
  fzf
  gh
  git-delta
  go
  helm
  hyperfine
  jq
  just
  k9s
  kind
  kubectl
  herdr
  lazygit
  mise
  neovim
  pnpm
  pre-commit
  procs
  python@3.13
  ripgrep
  starship
  yq
  zoxide
  zstd
)

BREW_TERMINAL_PACKAGES=(
  atuin
  bat
  direnv
  dust
  eza
  fd
  fzf
  gh
  git-delta
  herdr
  jq
  lazygit
  neovim
  ripgrep
  starship
  tmux
  yq
  zoxide
)

log() {
  printf '[%s] %s\n' "$SCRIPT_NAME" "$*"
}

warn() {
  printf '[%s] WARN: %s\n' "$SCRIPT_NAME" "$*" >&2
}

require_pop_os_or_ubuntu() {
  if [[ ! -r /etc/os-release ]]; then
    warn "Cannot read /etc/os-release. Aborting."
    exit 1
  fi

  # shellcheck disable=SC1091
  . /etc/os-release
  if [[ "${ID:-}" != "pop" && "${ID_LIKE:-}" != *"ubuntu"* && "${ID:-}" != "ubuntu" ]]; then
    warn "This script is intended for Pop!_OS / Ubuntu-like systems."
    warn "Detected ID=${ID:-unknown} ID_LIKE=${ID_LIKE:-unknown}"
    exit 1
  fi
}

ensure_line() {
  local line="$1"
  local file="$2"
  mkdir -p "$(dirname "$file")"
  touch "$file"
  if ! grep -Fqx "$line" "$file"; then
    printf '\n%s\n' "$line" >>"$file"
  fi
}

apt_install() {
  local package
  for package in "$@"; do
    if dpkg -s "$package" >/dev/null 2>&1; then
      continue
    fi
    sudo apt-get install -y "$package"
  done
}

install_apt_prereqs() {
  log "Updating apt metadata"
  sudo apt-get update -y

  log "Installing base apt packages"
  apt_install "${APT_BASE_PACKAGES[@]}"

  log "Installing developer apt packages"
  apt_install "${APT_DEV_PACKAGES[@]}"

  if command -v pipx >/dev/null 2>&1; then
    pipx ensurepath >/dev/null 2>&1 || true
  fi
}

install_linuxbrew() {
  if [[ -x "$BREW_BIN" ]]; then
    log "Linuxbrew already installed"
    return
  fi

  log "Installing Linuxbrew"
  NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
}

configure_shell_for_brew() {
  ensure_line "$BREW_SHELLENV" "$ZPROFILE"
  ensure_line "$BREW_SHELLENV" "$ZSHRC"

  # Make brew available in the current script session.
  # shellcheck disable=SC1091
  eval "$("$BREW_BIN" shellenv)"
}

install_brew_packages() {
  local package
  local packages=("$@")

  log "Updating Homebrew"
  brew update

  log "Installing brew packages"
  for package in "${packages[@]}"; do
    if brew list --formula "$package" >/dev/null 2>&1; then
      continue
    fi
    brew install "$package"
  done
}

install_docker_engine() {
  if command -v docker >/dev/null 2>&1; then
    log "Docker already installed"
  else
    log "Installing Docker Engine from Docker apt repo"
    sudo install -m 0755 -d /etc/apt/keyrings
    if [[ ! -f /etc/apt/keyrings/docker.asc ]]; then
      sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
      sudo chmod a+r /etc/apt/keyrings/docker.asc
    fi

    local codename
    codename="$(. /etc/os-release && echo "${VERSION_CODENAME}")"
    if [[ ! -f /etc/apt/sources.list.d/docker.list ]]; then
      echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu ${codename} stable" \
        | sudo tee /etc/apt/sources.list.d/docker.list >/dev/null
    fi

    sudo apt-get update -y
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
  fi

  if getent group docker >/dev/null 2>&1; then
    if id -nG "$USER" | grep -qw docker; then
      :
    else
      sudo usermod -aG docker "$USER"
      warn "Added $USER to docker group. Log out and back in for group changes."
    fi
  fi
}

setup_modern_runtime_defaults() {
  if command -v mise >/dev/null 2>&1; then
    ensure_line 'eval "$(mise activate zsh)"' "$ZSHRC"
  fi

  if command -v direnv >/dev/null 2>&1; then
    ensure_line 'eval "$(direnv hook zsh)"' "$ZSHRC"
  fi

  if command -v zoxide >/dev/null 2>&1; then
    ensure_line 'eval "$(zoxide init zsh)"' "$ZSHRC"
  fi

  if command -v atuin >/dev/null 2>&1; then
    ensure_line 'eval "$(atuin init zsh --disable-up-arrow)"' "$ZSHRC"
  fi
}

set_default_shell_to_zsh() {
  local zsh_path
  zsh_path="$(command -v zsh || true)"
  if [[ -z "$zsh_path" ]]; then
    warn "zsh not found; cannot set default shell."
    return
  fi

  if [[ "$SHELL" == "$zsh_path" ]]; then
    return
  fi

  if ! grep -Fqx "$zsh_path" /etc/shells; then
    echo "$zsh_path" | sudo tee -a /etc/shells >/dev/null
  fi

  if chsh -s "$zsh_path" "$USER"; then
    log "Default shell set to zsh"
  else
    warn "Failed to change default shell to zsh. You can run: chsh -s $zsh_path"
  fi
}

install_oh_my_zsh() {
  if [[ -d "$OH_MY_ZSH_DIR" ]]; then
    log "Oh My Zsh already installed"
    return
  fi

  log "Installing Oh My Zsh"
  RUNZSH=no CHSH=no KEEP_ZSHRC=yes \
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
}

clone_or_update_git_repo() {
  local repo_url="$1"
  local target_dir="$2"

  if [[ -d "$target_dir/.git" ]]; then
    git -C "$target_dir" pull --ff-only >/dev/null 2>&1 || true
    return
  fi

  git clone --depth=1 "$repo_url" "$target_dir"
}

install_powerlevel10k_and_plugins() {
  mkdir -p "${OH_MY_ZSH_CUSTOM}/themes" "${OH_MY_ZSH_CUSTOM}/plugins"

  log "Installing Powerlevel10k theme and zsh plugins"
  clone_or_update_git_repo "https://github.com/romkatv/powerlevel10k.git" \
    "${OH_MY_ZSH_CUSTOM}/themes/powerlevel10k"
  clone_or_update_git_repo "https://github.com/zsh-users/zsh-autosuggestions" \
    "${OH_MY_ZSH_CUSTOM}/plugins/zsh-autosuggestions"
  clone_or_update_git_repo "https://github.com/zsh-users/zsh-syntax-highlighting.git" \
    "${OH_MY_ZSH_CUSTOM}/plugins/zsh-syntax-highlighting"
  clone_or_update_git_repo "https://github.com/zsh-users/zsh-completions" \
    "${OH_MY_ZSH_CUSTOM}/plugins/zsh-completions"
}

install_meslo_nerd_fonts() {
  local fonts_dir="${HOME}/.local/share/fonts"
  local marker="${fonts_dir}/MesloLGS NF Regular.ttf"

  if [[ -f "$marker" ]]; then
    return
  fi

  mkdir -p "$fonts_dir"
  log "Installing Meslo Nerd Fonts for Powerlevel10k"

  local base_url="https://github.com/romkatv/powerlevel10k-media/raw/master"
  curl -fsSL "${base_url}/MesloLGS%20NF%20Regular.ttf" -o "${fonts_dir}/MesloLGS NF Regular.ttf"
  curl -fsSL "${base_url}/MesloLGS%20NF%20Bold.ttf" -o "${fonts_dir}/MesloLGS NF Bold.ttf"
  curl -fsSL "${base_url}/MesloLGS%20NF%20Italic.ttf" -o "${fonts_dir}/MesloLGS NF Italic.ttf"
  curl -fsSL "${base_url}/MesloLGS%20NF%20Bold%20Italic.ttf" -o "${fonts_dir}/MesloLGS NF Bold Italic.ttf"

  if command -v fc-cache >/dev/null 2>&1; then
    fc-cache -f "${fonts_dir}" >/dev/null 2>&1 || true
  fi
}

setup_terminal_experience() {
  install_oh_my_zsh
  install_powerlevel10k_and_plugins
  install_meslo_nerd_fonts
  set_default_shell_to_zsh
}

print_next_steps() {
  cat <<'EOF'

Setup complete.

Recommended next steps:
  1) Restart your shell: exec zsh
  2) In your terminal app, set font to "MesloLGS NF" for best Powerlevel10k rendering
  3) If this is your first p10k run, configure prompt:
       p10k configure
  4) If docker group was updated, log out/in once
  5) Configure runtimes with mise, for example:
       mise use -g node@lts
       mise use -g python@3.13
       mise use -g go@stable
  6) Enable corepack-managed package managers:
       corepack enable
  7) Verify:
       brew doctor
       docker --version
       kubectl version --client
       gh --version

EOF
}

main() {
  require_pop_os_or_ubuntu
  install_apt_prereqs
  install_linuxbrew
  configure_shell_for_brew

  if [[ "$MODE" == "--terminal-only" || "$MODE" == "terminal" ]]; then
    install_brew_packages "${BREW_TERMINAL_PACKAGES[@]}"
  else
    install_brew_packages "${BREW_PACKAGES[@]}"
    install_docker_engine
  fi

  setup_terminal_experience
  setup_modern_runtime_defaults
  print_next_steps
}

main "$@"
