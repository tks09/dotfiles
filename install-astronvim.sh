#!/bin/bash

BACKUP_DIR="$HOME/.dotfiles-backup/astronvim-$(date +%Y%m%d%H%M%S)"

if [ -d "$HOME/.config/nvim" ]; then
    mkdir -p "$BACKUP_DIR"
    echo "backing up existing configuration to $BACKUP_DIR"

    mv "$HOME/.config/nvim" "$BACKUP_DIR/nvim"
fi

git clone --depth 1 https://github.com/AstroNvim/AstroNvim ~/.config/nvim
rm -rf ~/.config/nvim/.git

if [ -d "$HOME/.config/nvim/lua/user" ]; then
    rm -rf ~/.config/nvim/lua/user
fi

mv ~/.config/nvim/lua/user_template ~/.config/nvim/lua/user
