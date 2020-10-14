#!/bin/bash

set -euxo pipefail

# This script should work on on any Ubuntu-derived distros.

DATA="${HOME}"/data
APPS="${DATA}"/apps
GITHUB="${DATA}"/github
MY_BASHRC="${HOME}"/.mybashrc.sh
TMP="${HOME}"/tmp

# Software installation.
sudo apt update
sudo apt dist-upgrade
sudo apt install \
  build-essential \
  cmake \
  unzip \
  clang \
  ripgrep \
  libpython3-all-dev # For YouCompleteMe

git clone --depth 1 https://github.com/junegunn/fzf.git "${HOME}"/.fzf
"${HOME}"/.fzf/install

# Create directories.
mkdir -p "${APPS}"
mkdir -p "${GITHUB}"
mkdir -p "${TMP}"

# Set up Git.
git config --global user.name "Fredy Wijaya"
git config --global user.email "fredy.wijaya@gmail.com"
git config --global alias.tree "log --decorate --graph"
git config --global alias.lg "log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit --date=relative"
git config --global pull.rebase true

# Set up dot files.
git clone git@github.com:fredyw/dotfiles.git "${GITHUB}"
echo -n 'source ~/.mybashrc.sh' >>"${HOME}/.bashrc"
cat >> "${MY_BASHRC}" <<EOL
export DATA=\$HOME/data
export APPS=\$HOME/data/apps

alias vbash="vim \$HOME/.mybashrc.sh"
alias sbash="source \$HOME/.bashrc"
alias cddata="cd \$DATA"
alias cdapps="cd \$APPS"
alias cdgithub="cd \$DATA/github"
alias cddotfiles="cd \$DATA/github/dotfiles"
alias cdtmp="cd \$HOME/tmp"
alias cdvim="cd \$HOME/.vim"
EOL

# Set up symbolic links.
ln -s "${GITHUB}"/vim/.vimrc "${HOME}"/.vimrc
ln -s "${GITHUB}"/tmux/.tmux.conf "${HOME}"/.tmux.conf

# Install Vundle plugins.
vim +PluginInstall +qall

# Install YouCompleteMe.
"${HOME}"/.vim/bundle/YouCompleteMe/install.py
