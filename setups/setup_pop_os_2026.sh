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
  fd-find
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
  log "Updating Homebrew"
  brew update

  log "Installing brew packages"
  local package
  for package in "${BREW_PACKAGES[@]}"; do
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

print_next_steps() {
  cat <<'EOF'

Setup complete.

Recommended next steps:
  1) Restart your shell: exec zsh
  2) If docker group was updated, log out/in once
  3) Configure runtimes with mise, for example:
       mise use -g node@lts
       mise use -g python@3.13
       mise use -g go@stable
  4) Enable corepack-managed package managers:
       corepack enable
  5) Verify:
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
  install_brew_packages
  install_docker_engine
  setup_modern_runtime_defaults
  print_next_steps
}

main "$@"
