#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib.sh"

NVIM_DIR="$HOME/.config/nvim"

backup_existing astronvim "$NVIM_DIR"

clone_if_missing https://github.com/AstroNvim/AstroNvim.git "$NVIM_DIR"

rm -rf "$NVIM_DIR/.git"

rm -rf "$NVIM_DIR/lua/user"
mv "$NVIM_DIR/lua/user_template" "$NVIM_DIR/lua/user"
