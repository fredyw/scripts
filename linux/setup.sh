#!/bin/bash

set -euxo pipefail

# This script should work on on any Ubuntu-derived distros.

GITHUB="${HOME}"/github
PROJECTS="${HOME}"/projects
DOT_FILES="${GITHUB}"/dotfiles
BASHRC="${HOME}"/.bashrc.sh
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
mkdir -p "${PROJECTS}"

# Set up dot files.
git clone git@github.com:fredyw/dotfiles.git "${DOT_FILES}"
echo 'source ~/github/dotfiles/bash/bashrc' >> "${HOME}/.bashrc"
echo 'source ~/.mybashrc.sh' >> "${HOME}/.bashrc"
cat >> "${BASHRC}" <<EOL
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
ln -s "${DOT_FILES}"/git/.gitconfig "${HOME}"/.gitconfig

# Install Vundle plugins.
git clone https://github.com/VundleVim/Vundle.vim.git "${HOME}"/.vim/bundle/Vundle.vim
vim +PluginInstall +qall

# Install YouCompleteMe.
"${HOME}"/.vim/bundle/YouCompleteMe/install.py

# Install SDKMAN.
curl -s "https://get.sdkman.io" | bash

# Install Rust.
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
