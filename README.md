# Installation
```
git clone [repo] ~/.dotfiles

git submodule init
git submodule update

./install.sh
```

Das Script erkennt das Betriebssystem automatisch (Ubuntu via `apt`, macOS via `brew`) und installiert git, tmux, zsh, neovim, Oh My Zsh, AstroNvim und verlinkt die Dotfiles. Bestehende Konfigurationen werden vor der Installation nach `~/.dotfiles-backup/` gesichert.
