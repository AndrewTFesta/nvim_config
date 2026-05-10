#!/usr/bin/env fish

# Node + Go
curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -; or exit 1
sudo apt install -y nodejs golang-go; or exit 1
node --version
npm --version
go version

# npm global prefix without sudo
mkdir -p ~/.npm-global
npm config set prefix ~/.npm-global

set -l npm_line 'set -gx PATH $HOME/.npm-global/bin $PATH'
if not grep -qxF "$npm_line" ~/.config/fish/config.fish 2>/dev/null
    echo $npm_line >> ~/.config/fish/config.fish
end
set -gx PATH $HOME/.npm-global/bin $PATH

# Persistent `fd` abbreviation
set -l abbr_line 'abbr -a fd fdfind'
if not grep -qxF "$abbr_line" ~/.config/fish/config.fish 2>/dev/null
    echo $abbr_line >> ~/.config/fish/config.fish
end

# QoL + build tools + clipboard (X11 and Wayland) + fd + emoji
sudo apt install -y make gcc ripgrep unzip git curl xclip wl-clipboard fd-find; or exit 1
# If we want emojis
sudo apt install -y fonts-noto-color-emoji; or exit 1

# Working dir for downloads
set tmpdir (mktemp -d)
cd $tmpdir

# CascadiaMono Nerd Font
mkdir -p ~/.local/share/fonts
curl -LO https://github.com/ryanoasis/nerd-fonts/releases/latest/download/CascadiaMono.zip; or exit 1
unzip -o CascadiaMono.zip -d ~/.local/share/fonts/CascadiaMono; or exit 1
fc-cache -f ~/.local/share/fonts

# Neovim from tarball
curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz; or exit 1
sudo tar -C /opt -xzf nvim-linux-x86_64.tar.gz; or exit 1
sudo ln -sf /opt/nvim-linux-x86_64/bin/nvim /usr/local/bin/nvim

cd $OLDPWD
rm -rf $tmpdir

# Python provider for nvim (only needed if you use Python plugins)
sudo apt install -y python3-pynvim; or exit 1

# Resolve absolute path to the directory containing this script
set SCRIPT_DIR (realpath (dirname (status filename)))

# Link this repo to ~/.config/nvim so neovim picks it up
set nvim_config "$HOME/.config/nvim"
mkdir -p ~/.config

if test -L "$nvim_config"
    # Existing symlink — replace it
    echo "Replacing existing symlink at $nvim_config"
    rm "$nvim_config"
else if test -e "$nvim_config"
    # Existing real directory or file — back it up
    set backup "$nvim_config.backup-"(date +%Y%m%d-%H%M%S)
    echo "Backing up existing $nvim_config to $backup"
    mv "$nvim_config" "$backup"
end

ln -s "$SCRIPT_DIR" "$nvim_config"
echo "Linked $nvim_config -> $SCRIPT_DIR"

echo "Done. Open a new shell or run: source ~/.config/fish/config.fish"