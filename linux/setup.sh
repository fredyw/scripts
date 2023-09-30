#!/bin/bash

# This script should work on on any Ubuntu-derived distros.

function show_help {
    echo "Bootstrap Linux environment."
    echo
    echo "Options:"
    echo "  -h|--help       Show this help."
    echo "  -n|--no-gui     Do not install anything GUI related."
    exit 0
}

OPTIONS=$(getopt -o hn --long help,no-gui -- "$@")
eval set -- "${OPTIONS}"
NO_GUI=false
while true; do
    case "$1" in
        -h|--help)
            show_help
            ;;
        -n|--no-gui)
            NO_GUI=true
            ;;
        --)
            shift
            break
            ;;
    esac
    shift
done

set -exo pipefail

function install_go {
    GO_VERSION=$(curl -s https://go.dev/dl/?mode=json | jq -r '.[0].version')
    DOWNLOAD_TEMP_DIR=$(mktemp -d)
    mkdir -p "${DOWNLOAD_TEMP_DIR}"
    curl -L https://go.dev/dl/${GO_VERSION}.linux-amd64.tar.gz --output "${DOWNLOAD_TEMP_DIR}"/go.tar.gz
    tar -C "${HOME}" -xf "${DOWNLOAD_TEMP_DIR}"/go.tar.gz
}

function install_bazel {
    BAZEL_DIR="${HOME}"/bazel
    mkdir -p "${BAZEL_DIR}"

    BAZELISK_URL=$(curl -s https://api.github.com/repos/bazelbuild/bazelisk/releases/latest | jq -r '.assets[] | select(.browser_download_url | contains("linux-amd64")) | .browser_download_url')
    curl -L "${BAZELISK_URL}" --output "${BAZEL_DIR}"/bazel
    chmod +x "${BAZEL_DIR}"/bazel

    BUILDIFIER_URL=$(curl -s https://api.github.com/repos/bazelbuild/buildtools/releases/latest | jq -r '.assets[] | select(.browser_download_url | contains("buildifier-linux-amd64")) | .browser_download_url')
    curl -L "${BUILDIFIER_URL}" --output "${BAZEL_DIR}"/buildifier
    chmod +x "${BAZEL_DIR}"/buildifier

    BUILDOZER_URL=$(curl -s https://api.github.com/repos/bazelbuild/buildtools/releases/latest | jq -r '.assets[] | select(.browser_download_url | contains("buildozer-linux-amd64")) | .browser_download_url')
    curl -L "${BUILDOZER_URL}" --output "${BAZEL_DIR}"/buildozer
    chmod +x "${BAZEL_DIR}"/buildozer
}

function install_jetbrains_toolbox {
    URL=$(curl -s 'https://data.services.jetbrains.com//products/releases?code=TBA&latest=true&type=release' | jq -r '.TBA[0].downloads.linux.link')
    DOWNLOAD_TEMP_DIR=$(mktemp -d)
    mkdir -p "${DOWNLOAD_TEMP_DIR}"
    curl -L "${URL}" --output "${DOWNLOAD_TEMP_DIR}"/jetbrains-toolbox.tar.gz
    TOOLBOX_DIR="${HOME}"/jetbrains-toolbox
    mkdir -p "${TOOLBOX_DIR}"
    tar -C "${TOOLBOX_DIR}" -xf "${DOWNLOAD_TEMP_DIR}"/jetbrains-toolbox.tar.gz --strip-components=1
}

function install_vs_code {
    sudo apt-get install wget gpg
    wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
    sudo install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg
    sudo sh -c 'echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list'
    rm -f packages.microsoft.gpg
    sudo apt update
    sudo apt -y install code
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
     wget \
     gpg \
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
     apt-transport-https \
     libpython3-all-dev # For YouCompleteMe

if [[ ! -d "${HOME}"/.fzf ]]; then
    git clone --depth 1 https://github.com/junegunn/fzf.git "${HOME}"/.fzf
    "${HOME}"/.fzf/install --all
fi

# Create directories.
mkdir -p "${GITHUB}"
mkdir -p "${TMP}"
mkdir -p "${PROJECTS}"

# Set up dot files.
HAS_BASHRC_SH=$(cat "${HOME}"/.bashrc | grep "source ~/.bashrc.sh" || true)
if [[ -z "${HAS_BASHRC_SH}" ]]; then
    git clone git@github.com:fredyw/dotfiles.git "${DOT_FILES}"
    echo 'source ~/.bashrc.sh' >> "${HOME}/.bashrc"
    cat >> "${BASHRC}" <<EOL
    source \$HOME/github/dotfiles/bash/.bashrc
EOL
fi

# Set up symbolic links.
if [[ -f "${HOME}"/.vimrc ]]; then
    rm -f "${HOME}"/.vimrc
fi
ln -s "${DOT_FILES}"/vim/.vimrc "${HOME}"/.vimrc
if [[ -f "${HOME}"/.tmux.conf ]]; then
    rm -f "${HOME}"/.tmux.conf
fi
ln -s "${DOT_FILES}"/tmux/.tmux.conf "${HOME}"/.tmux.conf
if [[ -f "${HOME}"/.gitconfig ]]; then
    rm -f "${HOME}"/.gitconfig
fi
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

# Install Go.
install_go

# Install Bazel.
install_bazel

source "${HOME}"/.sdkman/bin/sdkman-init.sh

# Install JVM related stuff.
sdk install java
sdk install kotlin
sdk install maven
sdk install gradle

if [[ "${NO_GUI}" = false ]]; then
    # Copy fonts.
    cp -rf .fonts "${HOME}"

    # Install JetBrains Toolbox.
    install_jetbrains_toolbox

    # Install Visual Studio Code.
    install_vs_code
fi
