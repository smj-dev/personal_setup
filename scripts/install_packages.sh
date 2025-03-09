#!/bin/bash

# Detect OS (WSL, Debian, etc.)
if grep -q Microsoft /proc/version; then
    OS="WSL"
elif [ -f "/etc/debian_version" ]; then
    OS="Debian"
else
    OS="Unknown"
fi

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

install_neovim() {
    echo "Checking Neovim installation..."

    # Detect system architecture
    ARCH=$(uname -m)
    if [[ "$ARCH" == "x86_64" ]]; then
        NVIM_FILE="nvim-linux-x86_64.tar.gz"
        NVIM_DIR="nvim-linux-x86_64"
    elif [[ "$ARCH" == "aarch64" ]]; then
        NVIM_FILE="nvim-linux-arm64.tar.gz"
        NVIM_DIR="nvim-linux-arm64"
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
    sudo mv "$NVIM_DIR" /usr/local/
    sudo ln -sf /usr/local/"$NVIM_DIR"/bin/nvim /usr/bin/nvim

    # Cleanup: Remove tar file and extracted directory
    rm -f "$NVIM_FILE"
    rm -rf "$NVIM_DIR"

    echo "✅ Neovim installation complete and cleaned up!"
}

install_wsl_dependencies() {
    echo "📦 Installing WSL-specific dependencies..."
    
    # Ensure clipboard support with win32yank
    if ! command -v win32yank.exe &> /dev/null; then
        echo "Installing win32yank for WSL clipboard support..."
        curl -LO https://github.com/equalsraf/win32yank/releases/latest/download/win32yank-x64.exe
        chmod +x win32yank-x64.exe
        sudo mv win32yank-x64.exe /usr/local/bin/win32yank.exe
    else
        echo "✅ win32yank is already installed."
    fi
}

install_neovim_plugins() {
    echo "📦 Installing Neovim plugins..."

    # Ensure Lazy.nvim is installed
    NVIM_LAZY_PATH="$HOME/.local/share/nvim/lazy/lazy.nvim"
    if [ ! -d "$NVIM_LAZY_PATH" ]; then
        echo "Cloning Lazy.nvim..."
        git clone --filter=blob:none https://github.com/folke/lazy.nvim.git --branch=stable "$NVIM_LAZY_PATH"
    else
        echo "✅ Lazy.nvim is already installed."
    fi

    # Install plugins (runs in headless mode to avoid GUI issues)
    echo "Syncing Neovim plugins..."
    nvim --headless "+Lazy! sync" +qall 2>/dev/null

    echo "✅ Neovim plugins installed!"
}

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

    # Install WSL-specific dependencies if needed
    if [[ "$OS" == "WSL" ]]; then
        install_wsl_dependencies
    fi

    # Install Neovim and plugins
    install_neovim
    install_neovim_plugins
}

# Run the package installation
install_packages
