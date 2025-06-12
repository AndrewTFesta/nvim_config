# install wsl2 and configure windows terminal
# https://learn.microsoft.com/en-us/windows/wsl/install
# https://learn.microsoft.com/en-us/windows/terminal/install
# Guide in installing neovim and setting up kickstart
# https://github.com/nvim-lua/kickstart.nvim?tab=readme-ov-file
# ttps://github.com/nvim-lua/kickstart.nvim?tab=readme-ov-file#Install-Recipes
mkdir tmp && cd tmp
curl https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/CascadiaMono.zip

sudo add-apt-repository ppa:neovim-ppa/unstable -y
sudo apt update
sudo apt install -y make gcc ripgrep unzip git xclip fd-find
sudo apt install -y neovim python3-neovim

# If we want emojis
sudo apt install -y fonts-noto-color-emoji

# add languages
sudo apt install -y golang-go nodejs npm
