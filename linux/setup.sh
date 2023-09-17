#!/bin/bash

set -euxo pipefail

# This script should work on on any Ubuntu-derived distros.

GITHUB="${HOME}"/github
DOT_FILES="${GITHUB}"/dotfiles
MY_BASHRC="${HOME}"/.mybashrc.sh
TMP="${HOME}"/tmp

# Software installation.
sudo apt update
sudo apt -y dist-upgrade
sudo apt -y install \
  build-essential \
  tmux \
  cmake \
  unzip \
  clang \
  ripgrep \
  htop \
  zip \
  unzip \
  tree \
  libpython3-all-dev # For YouCompleteMe

git clone --depth 1 https://github.com/junegunn/fzf.git "${HOME}"/.fzf
"${HOME}"/.fzf/install

# Create directories.
mkdir -p "${GITHUB}"
mkdir -p "${TMP}"

# Set up Git.
git config --global user.name "Fredy Wijaya"
git config --global user.email "fredy.wijaya@gmail.com"
git config --global alias.tree "log --decorate --graph"
git config --global alias.lg "log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit --date=relative"
git config --global pull.rebase true
git config --global init.defaultBranch main

# Set up dot files.
git clone git@github.com:fredyw/dotfiles.git "${DOT_FILES}"
echo 'source ~/github/dotfiles/bash/bashrc' >> "${HOME}/.bashrc"
echo 'source ~/.mybashrc.sh' >> "${HOME}/.bashrc"
cat >> "${MY_BASHRC}" <<EOL
alias vbash="vim \$HOME/.mybashrc.sh"
alias sbash="source \$HOME/.bashrc"
alias cdgithub="cd \$HOME/github"
alias cddotfiles="cd \$HOME/github/dotfiles"
alias cdtmp="cd \$HOME/tmp"
alias cdvim="cd \$HOME/.vim"
EOL

# Set up symbolic links.
ln -s "${DOT_FILES}"/vim/.vimrc "${HOME}"/.vimrc
ln -s "${DOT_FILES}"/tmux/.tmux.conf "${HOME}"/.tmux.conf

# Install Vundle plugins.
git clone https://github.com/VundleVim/Vundle.vim.git "${HOME}"/.vim/bundle/Vundle.vim
vim +PluginInstall +qall

# Install YouCompleteMe.
"${HOME}"/.vim/bundle/YouCompleteMe/install.py

# Install SDKMAN
curl -s "https://get.sdkman.io" | bash

# Install Rust
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
