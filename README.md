# Dotfiles bootstrap (Ubuntu)

This README lists concise, repeatable steps to bootstrap a fresh Ubuntu system using the files in this repo.

Prerequisites

- A user account (this repo assumes the username and home path are /home/darkzen).
- sudo access.

## Initial steps

1. Update system and install basic tools

```bash
sudo apt update && sudo apt upgrade -y
sudo apt install -y build-essential curl file git zsh
```

2. Clone this repo to your home (if not already present)

```bash
# run as your user; adjust URL if needed
git clone https://github.com/juanzenn/dotfiles.git /home/darkzen/.dotfiles
cd /home/darkzen/.dotfiles
```

3. Preserve existing dotfiles and symlink repo files

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

4. Install oh-my-zsh (without overwriting your .zshrc)

```bash
# clone oh-my-zsh to ~/.oh-my-zsh
[ -d /home/darkzen/.oh-my-zsh ] || git clone https://github.com/ohmyzsh/ohmyzsh.git /home/darkzen/.oh-my-zsh

# set zsh as default shell
chsh -s "$(which zsh)" || echo "chsh failed; run it manually: chsh -s $(which zsh)"
```

6. Install znap and zsh-syntax-highlighting (as referenced in .zshrc)

```bash
# znap (znap-repos path is used by .zshrc)
mkdir -p /home/darkzen/znap-repos
[ -d /home/darkzen/znap-repos/znap ] || git clone --depth 1 https://github.com/marlonrichert/zsh-snap.git /home/darkzen/znap-repos/znap

# zsh-syntax-highlighting (explicit clone used by .zshrc)
[ -d /home/darkzen/znap-repos/zsh-syntax-highlighting ] || git clone https://github.com/zsh-users/zsh-syntax-highlighting.git /home/darkzen/znap-repos/zsh-syntax-highlighting
```

7. nvm and Node (if needed)

```bash
# If you want nvm installed (the .zshrc expects nvm installed at ~/.nvm)
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.5/install.sh | bash
# Then open a new shell or source nvm script:
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
nvm install --lts
```

8. Finalize and verify

```bash
# Reload shell config
source restart

# Verify brew and packages
brew --version
git --version
zsh --version
tmux -V
```
