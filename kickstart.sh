#configs live under either
#   $XDG_CONFIG_HOME/nvim
#   ~/.config/nvim

git clone https://github.com/AndrewTFesta/nvim_config.git "${XDG_CONFIG_HOME:-$HOME/.config}"/nvim
# That's it! Lazy will install all the plugins you have.
# Use :Lazy to view the current plugin status.
# Hit q to close the window.

# Read through the init.lua file in your configuration folder for more information about extending
# and exploring Neovim.
# That also includes examples of adding popularly requested plugins.

# https://youtu.be/m8C0Cq9Uv9o

# For moving forward
# This is a fork of nvim-lua/kickstart.nvim that moves from a single file to a multi file configuration.
#   https://github.com/dam9000/kickstart-modular.nvim