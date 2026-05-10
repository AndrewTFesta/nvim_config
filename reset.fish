#!/usr/bin/env fish

# Resolve absolute path to the directory containing this script
set SCRIPT_DIR (realpath (dirname (status filename)))
echo "Running script from $SCRIPT_DIR"

cd ~
rm -rf ~/.local/share/nvim
rm -rf ~/.local/state/nvim
rm -rf ~/.cache/nvim

ls -la ~/.config/nvim
readlink ~/.config/nvim
ls ~/.config/nvim/init.lua
