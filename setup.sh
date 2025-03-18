#!/bin/bash
set -euo pipefail  # Exit on errors, undefined variables, and pipe failures

repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
echo "📂 Repo directory detected: $repo_dir"

LOG_FILE="/tmp/setup.log"
> "$LOG_FILE"  # Reset log file at the beginning
echo "📜 Logging output to $LOG_FILE"

# ========================
# 🛠 ARGUMENT PARSING 🛠
# ========================

INSTALL_PACKAGES=false

# Check if the argument --install-packages was provided
if [[ $# -gt 0 && "$1" == "--install-packages" ]]; then
    INSTALL_PACKAGES=true
fi

# ========================
# 🛠 HELPER FUNCTIONS 🛠
# ========================

run_command() {
    local cmd="$1"
    echo "🔄 Running: $cmd" >> "$LOG_FILE"
    eval "$cmd" >> "$LOG_FILE" 2>&1 || {
        echo "❌ ERROR: Command failed: $cmd"
        echo "Check logs: $LOG_FILE"
        exit 1
    }
}

check_and_install_stow() {
    if command -v stow &>/dev/null; then
        echo "✅ Stow is already installed."
    else
        echo "⚠️ Stow is not installed. Installing..."
        if [[ -f /etc/debian_version ]]; then
            run_command "sudo apt update && sudo apt install -y stow"
        elif [[ -f /etc/arch-release ]]; then
            run_command "sudo pacman -S --noconfirm stow"
        elif [[ -f /etc/fedora-release ]]; then
            run_command "sudo dnf install -y stow"
        elif [[ -f /etc/SuSE-release ]]; then
            run_command "sudo zypper install -y stow"
        else
            echo "❌ Unsupported Linux distribution. Please install 'stow' manually."
            exit 1
        fi
    fi
}

# Function to backup existing files before stowing
backup_existing() {
    local target="$1"  # The actual file/directory that needs to be backed up

    # Ensure target exists before proceeding
    if [[ ! -e "$target" ]]; then
        echo "✅ No existing file at $target, skipping backup."
        return 0
    fi

    # If the target exists and is NOT a symlink, back it up
    if [[ -e "$target" && ! -L "$target" ]]; then
        backup_target="${target}_backup_$(date +%Y%m%d_%H%M%S)"
        echo "⚠️ Backing up: $target -> $backup_target"
        mv "$target" "$backup_target"
    fi

    # If the target is still there but is a symlink, remove it
    if [[ -L "$target" ]]; then
        echo "⚠️ Removing existing symlink: $target"
        rm "$target"
    fi
}

run_stow() {
    local package="$1"
    local package_dir="$repo_dir/$package"

    echo "🔗 Preparing to stow $package..."

    # Ensure the package directory exists
    if [[ ! -d "$package_dir" ]]; then
        echo "❌ ERROR: Stow package directory '$package_dir' does not exist!"
        exit 1
    fi

    # Handle Neovim separately (it goes into ~/.config)
    if [[ "$package" == "nvim" ]]; then
        target_dir="$HOME/.config/nvim"
        backup_existing "$target_dir"
        echo "🔗 Running 'stow -v -t ~/.config $package'..."
        run_command "stow -v -t ~/.config $package"
    else
        # Handle other packages (bash, tmux) in home directory
        for file in "$package_dir"/.*; do
            file_name=$(basename "$file")

            # Ignore "." and ".."
            if [[ "$file_name" == "." || "$file_name" == ".." ]]; then
                continue
            fi

            # Backup existing file in home directory before stowing
            backup_existing "$HOME/$file_name"
        done

        echo "🔗 Running 'stow -v -t ~ $package'..."
        run_command "stow -v -t ~ $package"
    fi

    echo "✅ Successfully ran Stow for $package!"
}

setup_tmux() {
    echo "Setting up tmux configuration..."
    run_stow tmux

    # Detect WSL and configure clipboard accordingly
    if grep -qi microsoft /proc/version; then
        echo "Detected WSL: Using Windows clipboard integration."
        CLIP_CMD="clip.exe"
    else
        echo "Detected native Linux: Using xclip for clipboard integration."
        CLIP_CMD="xclip -selection clipboard"
    fi

    # Append clipboard settings to tmux.conf
    echo "Configuring tmux-yank with clipboard integration..."
    cat <<EOF >> ~/.tmux.conf

# tmux-yank settings (Added via setup script)
set -g @yank_action 'printf %s | $CLIP_CMD'
EOF

    # Reload tmux configuration
    tmux source ~/.tmux.conf

    echo "tmux base setup complete!"
}

# ========================
# 🛠 RUN SETUP FUNCTIONS 🛠
# ========================


if [ "$INSTALL_PACKAGES" = true ]; then
    echo "📦 Running full setup, including package installation..."
    ./scripts/install_packages.sh
    
    # Run the tmux plugin setup script
    ./scripts/setup_tmux_plugins.sh
else
    echo "🔄 Skipping package installation."
fi

check_and_install_stow

run_stow "nvim"

setup_tmux

run_stow "bash"
source ~/.bashrc

echo "🎉 Setup complete! Logs saved to $LOG_FILE"
