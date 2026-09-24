#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPTPATH="$SCRIPT_DIR"
BACKUP_ROOT="$HOME/.dotfiles-backup"

# ---------- helpers ----------

detect_os() {
    case "$(uname -s)" in
        Darwin)
            echo "macos"
            ;;
        Linux)
            echo "linux"
            ;;
        *)
            echo "unsupported: $(uname -s)" >&2
            return 1
            ;;
    esac
}

backup_existing() {
    local name="$1"
    shift
    local target backup_dir found=0

    for target in "$@"; do
        if [ -e "$target" ]; then
            if [ "$found" -eq 0 ]; then
                backup_dir="$BACKUP_ROOT/$name-$(date +%Y%m%d%H%M%S)"
                mkdir -p "$backup_dir"
            fi
            found=1
            echo "backing up $target to $backup_dir"
            mv "$target" "$backup_dir/"
        fi
    done

    if [ "$found" -eq 1 ]; then
        echo "backup created at $backup_dir"
    fi
}

clone_if_missing() {
    local repo="$1"
    local dest="$2"

    if [ -e "$dest" ]; then
        echo "$dest already exists, skipping clone of $repo"
        return 0
    fi

    git clone --depth 1 "$repo" "$dest"
}

append_once() {
    local line="$1"
    local file="$2"

    touch "$file"
    if ! grep -qxF "$line" "$file"; then
        echo "$line" >> "$file"
    fi
}

# ---------- steps ----------

install_packages() {
    local os="$1"

    case "$os" in
        linux)
            sudo apt-get update
            sudo apt-get install -y git tmux zsh neovim
            ;;
        macos)
            brew install git tmux zsh neovim
            ;;
    esac
}

install_ohmyzsh() {
    if [ -e "$HOME/.oh-my-zsh" ]; then
        echo "oh-my-zsh already installed, updating plugins only"
    else
        backup_existing ohmyzsh "$HOME/.zshrc"

        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    fi

    local zsh_custom="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

    clone_if_missing https://github.com/zsh-users/zsh-syntax-highlighting.git "$zsh_custom/plugins/zsh-syntax-highlighting"

    clone_if_missing https://github.com/zsh-users/zsh-autosuggestions.git "$zsh_custom/plugins/zsh-autosuggestions"
}

install_astronvim() {
    local nvim_dir="$HOME/.config/nvim"

    if [ -e "$nvim_dir" ]; then
        echo "$nvim_dir already exists, skipping astronvim setup"
        return 0
    fi

    backup_existing astronvim "$nvim_dir"

    git clone --depth 1 https://github.com/AstroNvim/template.git "$nvim_dir"
    rm -rf "$nvim_dir/.git"
}

link_files() {
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
    bash "$SCRIPT_DIR/assume-unchanged.sh"
}

# ---------- main ----------

main() {
    local os
    os="$(detect_os)"
    echo "detected os: $os"

    echo "== packages =="
    install_packages "$os"

    echo "== oh-my-zsh =="
    install_ohmyzsh

    echo "== astronvim =="
    install_astronvim

    echo "== dotfiles =="
    link_files

    echo "installation complete"
}

main "$@"
