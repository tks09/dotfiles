#!/bin/bash

BACKUP_ROOT="$HOME/.dotfiles-backup"

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
