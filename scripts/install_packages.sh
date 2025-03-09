#!/bin/bash

# List of essential packages
PACKAGES=(
    stow
    wget
    curl
    git
    tmux
    fzf
    ripgrep
    zsh
    python3
    python3-pip
    tree
    htop
)

# Detect if running in WSL or Debian
if grep -q Microsoft /proc/version; then
    OS="WSL"
elif [ -f "/etc/debian_version" ]; then
    OS="Debian"
else
    OS="Other"
fi

install_neovim() {
    echo "Checking Neovim installation..."

    # Detect system architecture
    ARCH=$(uname -m)
    if [[ "$ARCH" == "x86_64" ]]; then
        NVIM_FILE="nvim-linux-x86_64.tar.gz"
    elif [[ "$ARCH" == "aarch64" ]]; then
        NVIM_FILE="nvim-linux-arm64.tar.gz"
    else
        echo "❌ Unsupported architecture: $ARCH"
        exit 1
    fi

    # Download and install Neovim
    echo "Downloading Neovim for $ARCH..."
    NVIM_URL="https://github.com/neovim/neovim/releases/latest/download/${NVIM_FILE}"

    rm -f "$NVIM_FILE"
    curl -L -O "$NVIM_URL"

    # Verify download
    if ! tar -tzf "$NVIM_FILE" &>/dev/null; then
        echo "❌ Download failed or corrupted. Exiting..."
        rm -f "$NVIM_FILE"
        exit 1
    fi

    # Extract and install
    tar xzvf "$NVIM_FILE"
    sudo mv nvim-linux-x86_64 /usr/local/
    sudo ln -sf /usr/local/nvim-linux-x86_64/bin/nvim /usr/bin/nvim

    # Cleanup
    rm -f "$NVIM_FILE"

    echo "✅ Neovim installation complete!"
}




# Function to install packages
install_packages() {
    echo "Updating package lists..."
    sudo apt update -y

    echo "Installing packages..."
    for package in "${PACKAGES[@]}"; do
        if ! dpkg -l | grep -q "^ii  $package "; then
            echo "Installing $package..."
            sudo apt install -y "$package"
        else
            echo "✅ $package is already installed."
        fi
    done

    # Install Neovim only if needed
    install_neovim
}

# Run the function
install_packages
