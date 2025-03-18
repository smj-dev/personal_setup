#!/bin/bash
set -euo pipefail  # Ensure script exits on errors and undefined variables

LOG_FILE="/tmp/setup.log"
echo "📜 Logging output to $LOG_FILE"

# ========================
# 🛠 CONFIGURABLE PACKAGE LISTS 🛠
# ========================

# System packages to install
PACKAGES=(
    stow wget curl git unzip tmux fzf ripgrep zsh
    python3 python3-pip nodejs npm cargo clang
    clang-format cmake make xclip bat luarocks
)

# Mason.nvim packages (LSPs, formatters, linters)
MASON_PACKAGES=(
    stylua lua-language-server rust-analyzer pyright
    bash-language-server eslint_d prettier clangd
    clang-format cmakelang checkmake
)

LUAROCKS_PACKAGES=("jsregexp")  # Add more packages as needed

# ======================== 
# 🛠 HELPER FUNCTIONS 🛠
# ========================

# Function to execute a command and log output while printing only errors
run_command() {
    local cmd="$1"
    echo "🔄 Running: $cmd" >> "$LOG_FILE"
    eval "$cmd" >> "$LOG_FILE" 2>&1 || {
        echo "❌ ERROR: Command failed: $cmd"
        echo "Check logs: $LOG_FILE"
        exit 1
    }
}

install_packages() {
    echo "📦 Installing system packages..."
    sudo apt update -y >> "$LOG_FILE" 2>&1

    for package in "${PACKAGES[@]}"; do
        if ! dpkg -l | grep -q "^ii  $package "; then
            echo "Installing $package..."
            run_command "sudo apt install -y $package"
        else
            echo "✅ $package is already installed." >> "$LOG_FILE"
        fi
    done
}

install_neovim() {
    echo "🔍 Checking Neovim installation..."
    if command -v nvim &> /dev/null; then
        INSTALLED_NVIM_VERSION=$(nvim --version | head -n 1 | sed -E 's/NVIM v//')
        echo "Neovim installed: v$INSTALLED_NVIM_VERSION" >> "$LOG_FILE"
    else
        INSTALLED_NVIM_VERSION="0.0.0"
    fi

    LATEST_NVIM_VERSION=$(curl -s https://api.github.com/repos/neovim/neovim/releases/latest | grep '"tag_name":' | sed -E 's/.*"v([^"]+)".*/\1/')

    if [ "$(printf '%s\n' "$LATEST_NVIM_VERSION" "$INSTALLED_NVIM_VERSION" | sort -V | head -n 1)" == "$LATEST_NVIM_VERSION" ]; then
        echo "✅ Neovim is up to date!"
        return 0
    fi

    echo "⚠️ Updating Neovim to v$LATEST_NVIM_VERSION..."
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

    run_command "sudo apt remove --purge neovim -y"
    run_command "sudo apt autoremove -y"
    run_command "curl -L -O https://github.com/neovim/neovim/releases/latest/download/${NVIM_FILE}"
    run_command "tar xzvf $NVIM_FILE"
    run_command "sudo mv $NVIM_DIR /usr/local/"
    run_command "sudo ln -sf /usr/local/$NVIM_DIR/bin/nvim /usr/bin/nvim"
    run_command "rm -f $NVIM_FILE"
    run_command "rm -rf $NVIM_DIR"

    echo "✅ Neovim updated to v$LATEST_NVIM_VERSION!"
}

install_luarocks_packages() {
    # Define the list of Luarocks packages

    for package in "${LUAROCKS_PACKAGES[@]}"; do
        # Check if the package is already installed
        if luarocks list | grep -q "^$package"; then
            echo "✔ $package is already installed."
        else
            echo "⏳ Installing $package via Luarocks..."
            if luarocks install "$package"; then
                echo "✔ Successfully installed $package."
            else
                echo "❌ Failed to install $package. Check your Luarocks setup." >&2
            fi
        fi
    done

    # Ensure LUA_PATH and LUA_CPATH are set
    if ! echo "$LUA_PATH" | grep -q "$HOME/.luarocks/share/lua/5.1"; then
        echo 'export LUA_PATH="$HOME/.luarocks/share/lua/5.1/?.lua;$LUA_PATH"' >> ~/.bashrc
        echo 'export LUA_CPATH="$HOME/.luarocks/lib/lua/5.1/?.so;$LUA_CPATH"' >> ~/.bashrc
        echo "🔄 Added LUA_PATH and LUA_CPATH to ~/.bashrc"
        source ~/.bashrc
    fi

    echo "🚀 All requested Luarocks packages are installed!"
}


install_neovim_plugins() {
    echo "📦 Installing Neovim plugins..."
    
    NVIM_LAZY_PATH="$HOME/.local/share/nvim/lazy/lazy.nvim"
    if [ ! -d "$NVIM_LAZY_PATH" ]; then
        echo "Cloning Lazy.nvim..." >> "$LOG_FILE"
        run_command "git clone --filter=blob:none https://github.com/folke/lazy.nvim.git --branch=stable $NVIM_LAZY_PATH"
    else
        echo "✅ Lazy.nvim is already installed." >> "$LOG_FILE"
    fi

    run_command "nvim --headless '+Lazy! sync' +qall"

    echo "📦 Installing Mason.nvim tools..."
    MASON_INSTALL_CMD="MasonInstall ${MASON_PACKAGES[*]}"
    run_command "nvim --headless -c 'lua require(\"mason-registry\").refresh()' -c '$MASON_INSTALL_CMD' -c 'qall'"

    echo "✅ Neovim plugins and Mason tools installed successfully!"
}

# ========================
# 🛠 RUN SETUP FUNCTIONS 🛠
# ========================

install_packages
install_neovim
install_neovim_plugins
install_luarocks_packages

echo "🎉 Setup complete! Logs saved to $LOG_FILE"
