#!/bin/bash
set -euo pipefail

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
    python3.10-venv
    nodejs
    npm
    cargo
    clang
    clang-format
    cmake
    make
)

MASON_PACKAGES=(
    stylua                 # Lua formatter
    lua-language-server    # LSP for Lua
    rust-analyzer          # LSP for Rust
    pyright                # LSP for Python
    bash-language-server   # LSP for Bash
    eslint_d               # Linter for JavaScript
    prettier               # Formatter for JavaScript/TypeScript
    clangd                 # LSP for C/C++
    clang-format           # C/C++ Formating
    cmakelang              # Cmake LSP
    checkmake              # Cmake linter
)

install_neovim() {
    echo "Checking Neovim installation..."

    # Get installed Neovim version (if available)
    if command -v nvim &> /dev/null; then
        INSTALLED_NVIM_VERSION=$(nvim --version | head -n 1 | sed -E 's/NVIM v//')
        echo "Neovim installed: v$INSTALLED_NVIM_VERSION"
    else
        INSTALLED_NVIM_VERSION="0.0.0"  # Treat as not installed
    fi

    # Get latest available Neovim version from GitHub
    LATEST_NVIM_VERSION=$(curl -s https://api.github.com/repos/neovim/neovim/releases/latest | grep '"tag_name":' | sed -E 's/.*"v([^"]+)".*/\1/')

    echo "Latest Neovim version: v$LATEST_NVIM_VERSION"

    # If Neovim is already the latest version, exit early
    if [ "$(printf '%s\n' "$LATEST_NVIM_VERSION" "$INSTALLED_NVIM_VERSION" | sort -V | head -n 1)" == "$LATEST_NVIM_VERSION" ]; then
        echo "✅ Neovim is already up to date! Exiting early."
        return 0
    fi

    # Prompt user before updating
    echo "⚠️ A new Neovim version is available: v$LATEST_NVIM_VERSION"
    read -p "Would you like to update Neovim? (y/N): " -r
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "🚀 Skipping Neovim update."
        return 0
    fi

    echo "🔄 Updating Neovim to v$LATEST_NVIM_VERSION..."

    # 🛑 NOW we check the OS, because an update is actually happening
    if grep -q Microsoft /proc/version; then
        OS="WSL"
    elif [ -f "/etc/debian_version" ]; then
        OS="Debian"
    else
        OS="Unknown"
    fi

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

    # Remove old version
    sudo apt remove --purge neovim -y
    sudo apt autoremove -y

    # Download and install latest Neovim
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

    # Cleanup
    rm -f "$NVIM_FILE"
    rm -rf "$NVIM_DIR"

    echo "✅ Neovim updated to v$LATEST_NVIM_VERSION!"
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

install_stylua() {
    if ! command -v stylua &> /dev/null; then
        echo "Installing stylua..."
        cargo install stylua
    else
        echo "✅ stylua is already installed."
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

    # Install plugins (runs in headless mode)
    echo "Syncing Neovim plugins..."
    nvim --headless "+Lazy! sync" +qall 2>/dev/null || {
        echo "❌ Failed to sync Lazy.nvim plugins!"
        exit 1
    }

    echo "📦 Installing Mason.nvim tools..."

    MASON_INSTALL_CMD="MasonInstall ${MASON_PACKAGES[*]}"

    nvim --headless -c 'lua require("mason-registry").refresh()' \
                     -c "$MASON_INSTALL_CMD" \
                     -c 'qall' 2>&1 | tee /tmp/mason_install.log

    # Check for failures
    if grep -q "failed to install" /tmp/mason_install.log; then
        echo "❌ Some Mason.nvim packages failed to install! Check the log in /tmp/mason_install.log"
        exit 1
    fi

    echo "✅ Neovim plugins and Mason tools installed successfully!"
}


# Detect OS (WSL, Debian, etc.)
if grep -q Microsoft /proc/version; then
    OS="WSL"
elif [ -f "/etc/debian_version" ]; then
    OS="Debian"
else
    OS="Unknown"
fi

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

    if [[ "$OS" == "WSL" ]]; then
        install_wsl_dependencies
    fi

    # Required dependency for install_neovim_plugins
    install_stylua

    # Install Neovim and plugins
    install_neovim
    install_neovim_plugins
}

# Run the package installation
install_packages
