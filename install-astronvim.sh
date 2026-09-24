#!/bin/bash

git clone --depth 1 https://github.com/AstroNvim/AstroNvim ~/.config/nvim
rm -rf ~/.config/nvim/.git

if [ -d "$HOME/.config/nvim/lua/user" ]; then
    rm -rf ~/.config/nvim/lua/user
fi

mv ~/.config/nvim/lua/user_template ~/.config/nvim/lua/user
