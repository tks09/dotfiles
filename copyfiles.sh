#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib.sh"

SCRIPTPATH="$SCRIPT_DIR"

append_once() {
    local line="$1"
    local file="$2"

    touch "$file"
    if ! grep -qxF "$line" "$file"; then
        echo "$line" >> "$file"
    fi
}

echo "linking files..."

echo "- vimrc"
ln -sfn "$SCRIPTPATH/vimrc" "$HOME/.vimrc"

echo "- gitconfig"
ln -sfn "$SCRIPTPATH/gitconfig" "$HOME/.gitconfig"

echo "- bashrc"
append_once "source $SCRIPTPATH/bashrc" "$HOME/.bashrc"

echo "- zshrc"
append_once "source $SCRIPTPATH/zshrc" "$HOME/.zshrc"

echo "- tmux.conf"
mkdir -p "$HOME/.tmux/plugins"
clone_if_missing https://github.com/tmux-plugins/tpm.git "$HOME/.tmux/plugins/tpm"
ln -sfn "$SCRIPTPATH/tmux.conf" "$HOME/.tmux.conf"

echo "- vim/"
ln -sfn "$SCRIPTPATH/vim" "$HOME/.vim"

echo "- fish/"
mkdir -p "$HOME/.config"
ln -sfn "$SCRIPTPATH/fish" "$HOME/.config/fish"

echo "- creating vim_local"
touch "$SCRIPTPATH/vim_local"

echo "- assume unchanged"
"$SCRIPT_DIR/assume-unchanged.sh"
