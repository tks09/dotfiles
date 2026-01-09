#!/bin/bash

# Absolute path to this script. /home/user/bin/foo.sh

# Absolute path this script is in. /home/user/bin
SCRIPTPATH=~/.dotfiles

echo "linking files..."
echo "- vimrc"
ln -sf $SCRIPTPATH/vimrc ~/.vimrc

echo "- gitconfig"
ln -sf $SCRIPTPATH/gitconfig ~/.gitconfig

echo "- bashrc"
echo "source $HOME/.dotfiles/bashrc" >> $HOME/.bashrc

echo "- zshrc"
echo "source $HOME/.dotfiles/zshrc" >> $HOME/.zshrc

echo "- tmux.conf"
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
ln -sf $SCRIPTPATH/tmux.conf ~/.tmux.conf

echo "- vim/"
ln -sf $SCRIPTPATH/vim ~/.vim

echo "- neovim/"
ln -sf $SCRIPTPATH/nvim ~/.config/nvim

echo "- fish/"
ln -sf $SCRIPTPATH/fish ~/.config/fish

echo "- creating vim_local"
touch $SCRIPTPATH/vim_local

echo "- assume unchanged"
bash assume-unchanged.sh
