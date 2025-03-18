#!/bin/bash
set -euo pipefail

source "$(dirname "$0")/scripts/constants.sh"

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

setup_tmux() {
    echo "Setting up tmux configuration..."

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


bash "$(dirname "$0")/scripts/stow.sh" "tmux" "nvim" "bash"
setup_tmux

source ~/.bashrc

echo "🎉 Setup complete! Logs saved to $LOG_FILE"
