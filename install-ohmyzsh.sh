#!/bin/bash

BACKUP_DIR="$HOME/.dotfiles-backup/ohmyzsh-$(date +%Y%m%d%H%M%S)"

if [ -d "$HOME/.oh-my-zsh" ] || [ -f "$HOME/.zshrc" ]; then
    mkdir -p "$BACKUP_DIR"
    echo "backing up existing configuration to $BACKUP_DIR"

    if [ -d "$HOME/.oh-my-zsh" ]; then
        mv "$HOME/.oh-my-zsh" "$BACKUP_DIR/.oh-my-zsh"
    fi

    if [ -f "$HOME/.zshrc" ]; then
        mv "$HOME/.zshrc" "$BACKUP_DIR/.zshrc"
    fi
fi

sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
