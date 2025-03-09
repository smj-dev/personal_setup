#!/bin/bash
set -euo pipefail

##########################################################################
# Execute stow to create symlinks to the config file in the home folder
##########################################################################

# Function to check if Stow is installed
check_stow() {
    if command -v stow &>/dev/null; then
        echo "✅ Stow is already installed."
    else
        echo "⚠️ Stow is not installed. Installing..."
        install_stow
    fi
}

# Function to install Stow
install_stow() {
    if [[ -f /etc/debian_version ]]; then
        sudo apt update && sudo apt install -y stow
    elif [[ -f /etc/arch-release ]]; then
        sudo pacman -S --noconfirm stow
    elif [[ -f /etc/fedora-release ]]; then
        sudo dnf install -y stow
    elif [[ -f /etc/SuSE-release ]]; then
        sudo zypper install -y stow
    else
        echo "❌ Unsupported Linux distribution."
        exit 1
    fi
}

# Function to backup existing directories before stowing
backup_existing() {
    local target="$1"
    if [[ -e "$target" && ! -L "$target" ]]; then
        echo "⚠️ $target exists as a regular directory. Moving to $target_backup"
        mv "$target" "${target}_backup"
    fi
}

# Function to run Stow with correct target directory
run_stow() {
    local package="$1"
    
    # Ensure only ~/.config/nvim gets symlinked, not the whole ~/.config
    if [[ "$package" == "nvim" ]]; then
        echo "🔗 Running 'stow -v -t ~/.config $package'..."
        backup_existing ~/.config/nvim
        stow -v -t ~/.config "$package"
    else
        echo "🔗 Running 'stow -v $package'..."
        backup_existing ~/."$package"
        stow -v -t ~ "$package"
    fi

    # Verify symlinks
    case "$package" in
        "nvim")
            if [[ -L ~/.config/nvim ]]; then
                echo "✅ Symlink created: ~/.config/nvim -> $(readlink -f ~/.config/nvim)"
                ls -ld ~/.config/nvim  # Debug: Show symlink details
            else
                echo "❌ Symlink creation failed for Neovim!"
                exit 1
            fi
            ;;
        "tmux")
            if [[ -L ~/.tmux.conf ]]; then
                echo "✅ Symlink created: ~/.tmux.conf -> $(readlink -f ~/.tmux.conf)"
            else
                echo "❌ Symlink creation failed for ~/.tmux.conf!"
               # exit 1
            fi

            if [[ -L ~/.tmux ]]; then
                echo "✅ Symlink created: ~/.tmux -> $(readlink -f ~/.tmux)"
            else
                echo "❌ Symlink creation failed for ~/.tmux!"
                exit 1
            fi
            ;;
    esac

    echo "✅ Successfully ran Stow for $package"
}

# Create 
check_stow
run_stow "nvim"
run_stow "tmux"

./scripts/install_packages.sh

echo "Setup complete!"
