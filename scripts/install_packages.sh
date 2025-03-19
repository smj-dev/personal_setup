#!/bin/bash
set -euo pipefail

source "$(dirname "$0")/constants.sh"


PACKAGES=(
    stow
    wget
    curl
    git
    unzip
    tmux
    fzf
    ripgrep
    zsh
    python3
    python3-pip
    nodejs
    npm
    cargo
    clang
    clang-format
    cmake
    make
    xclip
    bat
    lua5.1
    liblua5.1-0-dev
    unzip
    libgtk-3-dev
    #luarocks luarocks installation is broken for wsl.
)

echo "📦 Installing system packages..."

UPDATE_OUTPUT=$(sudo apt-get -s update 2>&1 || true)
if echo "$UPDATE_OUTPUT" | grep -q "Hit:" || echo "$UPDATE_OUTPUT" | grep -q "Ign:"; then
    echo "📦 Apt updates available, running apt update..."
    sudo apt update -y >> "$LOG_FILE" 2>&1
else
    echo "⏩ No updates available, skipping apt update."
fi

for package in "${PACKAGES[@]}"; do
    if dpkg-query -W -f='${Status}' "$package" 2>/dev/null | grep -q "installed"; then
        echo "✅ $package is already installed."
    else
        echo "Installing $package..."
        sudo apt install -y "$package"
    fi
done
