#!/usr/bin/env bash
set -euo pipefail

# Resolve absolute path to the directory containing this script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
echo "Running script from $SCRIPT_DIR"

# Node + Go
curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
sudo apt install -y nodejs golang-go
node --version
npm --version
go version

npm install -g tree-sitter-cli

# npm global prefix without sudo
mkdir -p "$HOME/.npm-global"
npm config set prefix "$HOME/.npm-global"
LINE='export PATH="$HOME/.npm-global/bin:$PATH"'
if ! grep -qxF "$LINE" "$HOME/.bashrc" 2>/dev/null; then
    echo "$LINE" >> "$HOME/.bashrc"
fi
export PATH="$HOME/.npm-global/bin:$PATH"

# QoL + build tools + clipboard (X11 and Wayland) + fd + emoji
sudo apt install -y make gcc ripgrep unzip git curl xclip wl-clipboard fd-find
# If we want emojis
sudo apt install -y fonts-noto-color-emoji

# Persistent `fd` alias via symlink in user PATH (after fd-find is installed)
mkdir -p "$HOME/.local/bin"
ln -sf "$(command -v fdfind)" "$HOME/.local/bin/fd"
LINE='export PATH="$HOME/.local/bin:$PATH"'
if ! grep -qxF "$LINE" "$HOME/.bashrc" 2>/dev/null; then
    echo "$LINE" >> "$HOME/.bashrc"
fi
export PATH="$HOME/.local/bin:$PATH"

# Working dir for downloads
TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT
cd "$TMPDIR"

# CascadiaMono Nerd Font
mkdir -p "$HOME/.local/share/fonts"
curl -LO https://github.com/ryanoasis/nerd-fonts/releases/latest/download/CascadiaMono.zip
unzip -o CascadiaMono.zip -d "$HOME/.local/share/fonts/CascadiaMono"
fc-cache -f "$HOME/.local/share/fonts"

# Neovim from tarball
curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz
sudo rm -rf /opt/nvim-linux-x86_64
sudo mkdir -p /opt/nvim-linux-x86_64
sudo chmod a+rX /opt/nvim-linux-x86_64
sudo tar -C /opt -xzf nvim-linux-x86_64.tar.gz
sudo ln -sf /opt/nvim-linux-x86_64/bin/nvim /usr/local/bin/

# Python provider for nvim (only needed if you use Python plugins)
sudo apt install -y python3-pynvim

# Link this repo to ~/.config/nvim so neovim picks it up
NVIM_CONFIG="$HOME/.config/nvim"
mkdir -p "$HOME/.config"

if [ -L "$NVIM_CONFIG" ]; then
    # Existing symlink — replace it
    echo "Replacing existing symlink at $NVIM_CONFIG"
    rm "$NVIM_CONFIG"
elif [ -e "$NVIM_CONFIG" ]; then
    # Existing real directory or file — back it up
    BACKUP="$NVIM_CONFIG.backup-$(date +%Y%m%d-%H%M%S)"
    echo "Backing up existing $NVIM_CONFIG to $BACKUP"
    mv "$NVIM_CONFIG" "$BACKUP"
fi

ln -s "$SCRIPT_DIR" "$NVIM_CONFIG"
echo "Linked $NVIM_CONFIG -> $SCRIPT_DIR"

echo "Done. Open a new shell or run: source ~/.bashrc"