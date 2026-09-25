#!/bin/bash
#
# install.sh - dotfiles bootstrap for Ubuntu and macOS
#
# Detects the operating system, installs the required tools
# (git, tmux, zsh, neovim), sets up Oh My Zsh and AstroNvim
# and links the dotfiles into place.
#
# Existing configurations are backed up to ~/.dotfiles-backup/
# before they are replaced. The script is idempotent and can
# safely be run multiple times.
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPTPATH="$SCRIPT_DIR"
BACKUP_ROOT="$HOME/.dotfiles-backup"

# ---------- helpers ----------

# Print the current step as a numbered banner, e.g. "[1/4] packages".
step() {
    echo ""
    echo "== [$1/$2] $3 =="
}

# Detect the operating system: "macos" or "linux".
# Exits with an error on unsupported systems.
detect_os() {
    case "$(uname -s)" in
        Darwin)
            echo "macos"
            ;;
        Linux)
            echo "linux"
            ;;
        *)
            echo "error: unsupported os: $(uname -s)" >&2
            exit 1
            ;;
    esac
}

# Backup existing files/directories into a timestamped folder below
# $BACKUP_ROOT, e.g. backup_existing ohmyzsh ~/.zshrc
# Skips paths that do not exist.
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
            echo "  backing up $target -> $backup_dir"
            mv "$target" "$backup_dir/"
        fi
    done

    if [ "$found" -eq 1 ]; then
        echo "  backup created at $backup_dir"
    fi
}

# Clone a git repository only if the destination does not exist yet.
clone_if_missing() {
    local repo="$1"
    local dest="$2"

    if [ -e "$dest" ]; then
        echo "  $dest already exists, skipping clone of $repo"
        return 0
    fi

    echo "  cloning $repo"
    git clone --depth 1 "$repo" "$dest"
}

# Append a line to a file, but only if it is not already present.
# Keeps repeated runs of this script from duplicating entries.
append_once() {
    local line="$1"
    local file="$2"

    touch "$file"
    if ! grep -qxF "$line" "$file"; then
        echo "  appending '$line' to $file"
        echo "$line" >> "$file"
    else
        echo "  $file already sources this entry, skipping"
    fi
}

# ---------- steps ----------

# Install the required tools: git, tmux, zsh and neovim.
# Ubuntu uses apt, macOS uses Homebrew.
install_packages() {
    local os="$1"

    echo "installing packages via $os package manager..."

    case "$os" in
        linux)
            echo "  updating apt package index"
            sudo apt-get update
            echo "  installing git tmux zsh neovim"
            sudo apt-get install -y git tmux zsh neovim
            ;;
        macos)
            echo "  installing git tmux zsh neovim"
            brew install git tmux zsh neovim
            ;;
    esac

    echo "packages installed"
}

# Install Oh My Zsh (unattended) and its plugins.
# If Oh My Zsh is already present, only the plugins are ensured.
install_ohmyzsh() {
    if [ -e "$HOME/.oh-my-zsh" ]; then
        echo "oh-my-zsh already installed, ensuring plugins only"
    else
        echo "oh-my-zsh not found, backing up existing .zshrc"
        backup_existing ohmyzsh "$HOME/.zshrc"

        echo "  downloading and running oh-my-zsh installer"
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    fi

    local zsh_custom="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

    echo "ensuring oh-my-zsh plugins..."
    clone_if_missing https://github.com/zsh-users/zsh-syntax-highlighting.git "$zsh_custom/plugins/zsh-syntax-highlighting"
    clone_if_missing https://github.com/zsh-users/zsh-autosuggestions.git "$zsh_custom/plugins/zsh-autosuggestions"

    echo "oh-my-zsh ready"
}

# Install AstroNvim from the official template repository.
# AstroNvim itself is bootstrapped by lazy.nvim on the first nvim start.
install_astronvim() {
    local nvim_dir="$HOME/.config/nvim"

    if [ -e "$nvim_dir" ]; then
        echo "$nvim_dir already exists, skipping astronvim setup"
        return 0
    fi

    echo "no existing nvim config found, installing astronvim template"
    git clone --depth 1 https://github.com/AstroNvim/template.git "$nvim_dir"
    rm -rf "$nvim_dir/.git"

    echo "astronvim ready - run nvim once to bootstrap plugins"
}

# Link the dotfiles from this repository into $HOME.
link_files() {
    echo "linking dotfiles from $SCRIPTPATH ..."

    echo "  vimrc"
    ln -sfn "$SCRIPTPATH/vimrc" "$HOME/.vimrc"

    echo "  gitconfig"
    ln -sfn "$SCRIPTPATH/gitconfig" "$HOME/.gitconfig"

    echo "  bashrc"
    append_once "source $SCRIPTPATH/bashrc" "$HOME/.bashrc"

    echo "  zshrc"
    append_once "source $SCRIPTPATH/zshrc" "$HOME/.zshrc"

    echo "  tmux.conf"
    mkdir -p "$HOME/.tmux/plugins"
    clone_if_missing https://github.com/tmux-plugins/tpm.git "$HOME/.tmux/plugins/tpm"
    ln -sfn "$SCRIPTPATH/tmux.conf" "$HOME/.tmux.conf"

    echo "  vim/"
    ln -sfn "$SCRIPTPATH/vim" "$HOME/.vim"

    echo "  fish/"
    mkdir -p "$HOME/.config"
    ln -sfn "$SCRIPTPATH/fish" "$HOME/.config/fish"

    echo "  creating vim_local"
    touch "$SCRIPTPATH/vim_local"

    echo "  assume unchanged"
    bash "$SCRIPT_DIR/assume-unchanged.sh"

    echo "dotfiles linked"
}

# ---------- main ----------

main() {
    local os
    os="$(detect_os)"
    echo "detected os: $os"

    step 1 4 "packages"
    install_packages "$os"

    step 2 4 "oh-my-zsh"
    install_ohmyzsh

    step 3 4 "astronvim"
    install_astronvim

    step 4 4 "dotfiles"
    link_files

    echo ""
    echo "installation complete"
}

main "$@"
