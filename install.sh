#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOME_DIR="${HOME:-/home/darkzen}"
BACKUP_DIR="$HOME_DIR/.dotfiles-backup-$(date +%Y%m%d%H%M%S)"

NO_BREW=0
NO_VSCODE=0
NO_NVM=0
ASSUME_YES=0

usage() {
  cat <<EOF
Usage: $(basename "$0") [--no-brew] [--no-vscode] [--no-nvm] [--yes]
Options:
  --no-brew    Skip Homebrew installation and brew bundle
  --no-vscode  Skip installing VS Code extensions
  --no-nvm     Skip installing nvm
  --yes        Non-interactive (assume yes for prompts)
EOF
  exit 1
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --no-brew) NO_BREW=1; shift ;;
    --no-vscode) NO_VSCODE=1; shift ;;
    --no-nvm) NO_NVM=1; shift ;;
    --yes) ASSUME_YES=1; shift ;;
    -h|--help) usage ;;
    *) echo "Unknown arg: $1"; usage ;;
  esac
done

confirm() {
  if [[ $ASSUME_YES -eq 1 ]]; then
    return 0
  fi
  read -r -p "$1 [y/N]: " resp
  [[ "$resp" =~ ^[Yy]$ ]]
}

info() { printf "\n==> %s\n" "$1"; }

# 1) apt prerequisites
info "Updating apt and installing prerequisites"
if confirm "Continue with apt update/install?"; then
  sudo apt update
  sudo apt install -y build-essential curl file git zsh tmux || true
fi

# 2) Homebrew (Linuxbrew)
if [[ $NO_BREW -eq 0 ]]; then
  if ! command -v brew >/dev/null 2>&1; then
    info "Installing Homebrew (Linuxbrew)"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  else
    info "Homebrew already installed"
  fi
  # load brew env for this session
  if [[ -f /home/linuxbrew/.linuxbrew/bin/brew ]]; then
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
  elif command -v brew >/dev/null 2>&1; then
    eval "$(brew shellenv)"
  fi

  info "Running brew bundle"
  if [[ -f "$DOTFILES_DIR/Brewfile" ]]; then
    brew bundle --file="$DOTFILES_DIR/Brewfile" || true
  else
    info "No Brewfile found at $DOTFILES_DIR/Brewfile"
  fi
fi

# 3) VS Code extensions
if [[ $NO_VSCODE -eq 0 ]]; then
  if command -v code >/dev/null 2>&1; then
    info "Installing VS Code extensions from Brewfile"
    grep '^vscode "' "$DOTFILES_DIR/Brewfile" 2>/dev/null \
      | sed -E 's/vscode "([^"]+)"/\1/' \
      | xargs -r -L1 -I{} code --install-extension {} || true
  else
    info "VS Code 'code' CLI not found; skipping extensions (use 'Shell Command: Install code command in PATH' in VS Code)"
  fi
fi

# 4) Backup existing dotfiles and symlink new ones
info "Backing up existing dotfiles to $BACKUP_DIR"
mkdir -p "$BACKUP_DIR"
for f in .zshrc .gitconfig .tmux.conf; do
  if [[ -e "$HOME_DIR/$f" && ! -L "$HOME_DIR/$f" ]]; then
    mv "$HOME_DIR/$f" "$BACKUP_DIR/"
  fi
done

info "Creating symlinks for dotfiles"
ln -sfn "$DOTFILES_DIR/.zshrc" "$HOME_DIR/.zshrc"
ln -sfn "$DOTFILES_DIR/.gitconfig" "$HOME_DIR/.gitconfig"
ln -sfn "$DOTFILES_DIR/.tmux.conf" "$HOME_DIR/.tmux.conf"

# 5) oh-my-zsh
if [[ ! -d "$HOME_DIR/.oh-my-zsh" ]]; then
  info "Cloning oh-my-zsh"
  git clone https://github.com/ohmyzsh/ohmyzsh.git "$HOME_DIR/.oh-my-zsh"
else
  info "oh-my-zsh already present"
fi

# 6) znap and zsh-syntax-highlighting
info "Ensuring znap and zsh-syntax-highlighting are cloned under \$HOME/znap-repos"
mkdir -p "$HOME_DIR/znap-repos"
if [[ ! -d "$HOME_DIR/znap-repos/znap" ]]; then
  git clone --depth 1 https://github.com/marlonrichert/zsh-snap.git "$HOME_DIR/znap-repos/znap"
fi
if [[ ! -d "$HOME_DIR/znap-repos/zsh-syntax-highlighting" && ! -d "$HOME_DIR/zsh-syntax-highlighting" ]]; then
  git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$HOME_DIR/znap-repos/zsh-syntax-highlighting"
fi

# 7) nvm (optional)
if [[ $NO_NVM -eq 0 ]]; then
  if [[ ! -d "$HOME_DIR/.nvm" ]]; then
    info "Installing nvm"
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.5/install.sh | bash
  else
    info "nvm already installed"
  fi
fi

# 8) Ensure zsh is default shell (inform, do not force)
if [[ "$(basename "$SHELL")" != "zsh" ]]; then
  info "You can set zsh as default shell with: chsh -s \"$(command -v zsh)\""
fi

info "Bootstrap complete. Useful commands:"
cat <<EOF
- Restart your terminal or run: source ~/.zshrc
- Verify brew: brew --version
- Verify git: git --version
- Verify tmux: tmux -V
EOF

chmod +x "$DOTFILES_DIR/install.sh" || true
info "Done."
