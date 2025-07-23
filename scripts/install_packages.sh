#!/bin/bash
set -euo pipefail

source "$(dirname "$0")/constants.sh"

# Determine distribution
if [[ -f /etc/os-release ]]; then
    source /etc/os-release
else
    echo "❌ Unable to determine Linux distribution."
    exit 1
fi

# Define package list
COMMON_PACKAGES=(
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
    cargo
    clang
    clang-format
    cmake
    make
    xclip
    bat
    alsa-utils
)

DEBIAN_PACKAGES=(
    lua5.1
    liblua5.1-0-dev
    libgtk-3-dev
    libwebkit2gtk-4.0-dev
)

RHEL_PACKAGES=(
    lua
    lua-devel
    gtk3-devel
    webkit2gtk3-devel
)

# Print info
echo "📦 Detected distro: $ID"
echo "📦 Installing system packages..."

# Update and install
if [[ "$ID" == "debian" || "$ID" == "ubuntu" ]]; then
    UPDATE_OUTPUT=$(sudo apt-get -s update 2>&1 || true)
    if echo "$UPDATE_OUTPUT" | grep -q -e "Hit:" -e "Ign:"; then
        echo "📦 Running apt update..."
        sudo apt update -y >> "$LOG_FILE" 2>&1
    fi

    # Adding NodeSource APT repo for Node.js 18
    curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash - >> "$LOG_FILE" 2>&1

    for package in "${COMMON_PACKAGES[@]}" "${DEBIAN_PACKAGES[@]}"; do
        if dpkg -s "$package" 2>/dev/null | grep -q "Status: install ok installed"; then
            echo "✅ $package is already installed."
        else
            echo "Installing $package..."
            run_command "sudo apt install -y "$package""
        fi
    done

elif [[ "$ID" == "almalinux" || "$ID" == "rhel" || "$ID" == "centos" ]]; then
    echo "📦 Running dnf update..."
    sudo dnf check-update || true
    sudo dnf -y update >> "$LOG_FILE" 2>&1

    # Adding NodeSource DNF repo for Node.js 18
    curl -fsSL https://rpm.nodesource.com/setup_18.x | sudo bash - >> "$LOG_FILE" 2>&1

    for package in "${COMMON_PACKAGES[@]}" "${RHEL_PACKAGES[@]}"; do
        if rpm -q "$package" &>/dev/null; then
            echo "✅ $package is already installed."
        else
            echo "Installing $package..."
            sudo dnf install -y "$package" >> "$LOG_FILE" 2>&1
        fi
    done

else
    echo "❌ Unsupported distribution: $ID"
    exit 1
fi

echo "Packages installed successfully!"


