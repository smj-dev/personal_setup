#!/bin/bash

# List of essential packages
PACKAGES=(
    wget
    curl
    git
    neovim
    stow
    tmux
    fzf
    ripgrep
    python3
    python3-pip
    tree
)

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
            echo "$package is already installed."
        fi
    done

    echo "All essential packages installed."
}

# Run the function
install_packages
