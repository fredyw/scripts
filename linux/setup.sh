#!/bin/bash

set -euxo pipefail

# This script should work on on any Ubuntu-derived distros.

function install_bazel {
  URL=$(curl -s https://api.github.com/repos/bazelbuild/bazelisk/releases/latest | jq -r '.assets[] | select(.browser_download_url | contains("linux-amd64")) | .browser_download_url')
  BAZEL_DIR="${HOME}"/bazel
  mkdir -p "${BAZEL_DIR}"
  curl -L "${URL}" --output "${BAZEL_DIR}/bazel"
}

function install_jetbrains_toolbox {
  URL=$(curl -s 'https://data.services.jetbrains.com//products/releases?code=TBA&latest=true&type=release' | jq -r '.TBA[0].downloads.linux.link')
  DOWNLOAD_TEMP_DIR=$(mktemp -d)
  mkdir -p "${DOWNLOAD_TEMP_DIR}"
  curl -L "${URL}" --output "${DOWNLOAD_TEMP_DIR}/toolbox.tar.gz"
  TOOLBOX_DIR="${HOME}"/jetbrains-toolbox
  mkdir -p "${TOOLBOX_DIR}"
  tar -C "${TOOLBOX_DIR}" -xf "${DOWNLOAD_TEMP_DIR}/toolbox.tar.gz" --strip-components=1
}


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
  git \
  curl \
  vim \
  tmux \
  cmake \
  unzip \
  clang \
  ripgrep \
  htop \
  zip \
  unzip \
  tree \
  jq \
  libpython3-all-dev # For YouCompleteMe

git clone --depth 1 https://github.com/junegunn/fzf.git "${HOME}"/.fzf
"${HOME}"/.fzf/install --all

# Create directories.
mkdir -p "${GITHUB}"
mkdir -p "${TMP}"
mkdir -p "${PROJECTS}"

# Set up dot files.
git clone git@github.com:fredyw/dotfiles.git "${DOT_FILES}"
echo 'source ~/.bashrc.sh' >> "${HOME}/.bashrc"
cat >> "${BASHRC}" <<EOL
source \$HOME/github/dotfiles/bash/.bashrc
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
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y

# Copy fonts.
cp -rf .fonts "${HOME}"

# Install JetBrains Toolbox.
install_jetbrains_toolbox

source "${HOME}"/.bashrc

# Install JVM related stuff.
sdk install java
sdk install kotlin
sdk install maven
sdk install gradle