# Dotfiles bootstrap (Ubuntu)

This README lists concise, repeatable steps to bootstrap a fresh Ubuntu system using the files in this repo.

Prerequisites

- A user account (this repo assumes the username and home path are /home/darkzen).
- sudo access.

## Quick install script

A helper script automates the steps described above.

Run from the repo root:

```bash
cd /home/darkzen/.dotfiles
chmod +x ./install.sh
./install.sh            # interactive; use --yes for non-interactive
# Optional flags:
#   --no-brew    Skip Homebrew / brew bundle
#   --no-vscode  Skip installing VS Code extensions
#   --no-nvm     Skip installing nvm
```

1. Update system and install basic tools

```bash
sudo apt update && sudo apt upgrade -y
sudo apt install -y build-essential curl file git zsh tmux
```

2. Clone this repo to your home (if not already present)

```bash
# run as your user; adjust URL if needed
git clone git@github.com:juanzenn/dotfiles.git /home/darkzen/.dotfiles
cd /home/darkzen/.dotfiles
```

3. Install Homebrew (Linuxbrew) and enable it

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
# follow any instructions printed by the installer, then:
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
# you can add the eval line to your shell profile (done in .zshrc in this repo)
```

4. Install packages and apps from Brewfile

```bash
# Install formulae and casks listed in Brewfile
brew bundle --file=/home/darkzen/.dotfiles/Brewfile
```

5. Install VS Code extensions listed in the Brewfile

```bash
# Ensure `code` CLI is available (install VS Code and enable 'code' in PATH)
# This extracts extension ids from the Brewfile and installs them via the code CLI
grep '^vscode "' /home/darkzen/.dotfiles/Brewfile \
  | sed -E 's/vscode "([^"]+)"/\1/' \
  | xargs -L1 -I{} code --install-extension {} || true
```

6. Preserve existing dotfiles and symlink repo files

```bash
# Backup existing dotfiles (if any)
mkdir -p /home/darkzen/.dotfiles-backup
for f in .zshrc .gitconfig .tmux.conf; do
  [ -e /home/darkzen/$f ] && mv /home/darkzen/$f /home/darkzen/.dotfiles-backup/
done

# Create symlinks from repo to home
ln -sfn /home/darkzen/.dotfiles/.zshrc /home/darkzen/.zshrc
ln -sfn /home/darkzen/.dotfiles/.gitconfig /home/darkzen/.gitconfig
ln -sfn /home/darkzen/.dotfiles/.tmux.conf /home/darkzen/.tmux.conf
```

7. Install oh-my-zsh (without overwriting your .zshrc)

```bash
# clone oh-my-zsh to ~/.oh-my-zsh
[ -d /home/darkzen/.oh-my-zsh ] || git clone https://github.com/ohmyzsh/ohmyzsh.git /home/darkzen/.oh-my-zsh

# set zsh as default shell
chsh -s "$(which zsh)" || echo "chsh failed; run it manually: chsh -s $(which zsh)"
```

8. Install znap and zsh-syntax-highlighting (as referenced in .zshrc)

```bash
# znap (znap-repos path is used by .zshrc)
mkdir -p /home/darkzen/znap-repos
[ -d /home/darkzen/znap-repos/znap ] || git clone --depth 1 https://github.com/marlonrichert/zsh-snap.git /home/darkzen/znap-repos/znap

# zsh-syntax-highlighting (explicit clone used by .zshrc)
[ -d /home/darkzen/znap-repos/zsh-syntax-highlighting ] || git clone https://github.com/zsh-users/zsh-syntax-highlighting.git /home/darkzen/znap-repos/zsh-syntax-highlighting
```

9. nvm and Node (if needed)

```bash
# If you want nvm installed (the .zshrc expects nvm installed at ~/.nvm)
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.5/install.sh | bash
# Then open a new shell or source nvm script:
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
nvm install --lts
```

10. Finalize and verify

```bash
# Reload shell config
source /home/darkzen/.zshrc

# Verify brew and packages
brew --version
git --version
zsh --version
tmux -V

# Verify VS Code extensions (optional)
code --list-extensions
```

Notes and troubleshooting

- If the `code` CLI is not found, open VS Code → Command Palette → "Shell Command: Install 'code' command in PATH".
- The Brewfile contains many vscode extension entries. If any fail to install, run `code --install-extension <id>` manually.
- If the oh-my-zsh install script attempts to overwrite your .zshrc, the steps above prevent that by cloning and symlinking your dotfile first.
- Adjust permissions and ownership if you run any commands with sudo; keep files owned by your user.

That's all — after these steps the provided dotfiles should be active. If you want commands adjusted to a different username or repo URL, replace paths accordingly.
