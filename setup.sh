#!/bin/bash
set -euo pipefail

source "$(dirname "$0")/scripts/constants.sh"

> "$LOG_FILE"  # Reset log file at the beginning
echo "📜 Logging output to $LOG_FILE"

# ========================
# 🛠 ARGUMENT PARSING 🛠
# ========================
usage() {
    echo "Usage: $(basename "$0") [packages|tmux|neovim|bash|all]"
    exit 1
}

# Ensure at least one argument is passed
if [[ $# -eq 0 ]]; then
    usage
fi

# Process each argument
for arg in "$@"; do
    case "$arg" in
        packages)
            echo "📦 Installing packages..."
            bash "$REPO_DIR/scripts/install_packages.sh"
            ;;
        tmux)
            echo "Installing tmux config"
            bash "$REPO_DIR/scripts/stow.sh" "tmux"
            bash "$REPO_DIR/scripts/setup_tmux_plugins.sh"
            ;;
        neovim)
            echo "Setting up Neovim..."
            bash "$REPO_DIR/scripts/stow.sh" "nvim"
            bash "$REPO_DIR/scripts/setup_nvim_plugins.sh"
            ;;
        bash)
            echo "Setting up Bash..."
            bash "$REPO_DIR/scripts/stow.sh" "bash"
            source ~/.bashrc
            source ~/.bash_aliases
            ;;
        gitk)
            echo "Setting up gitk theme..."
            bash "$REPO_DIR/scripts/stow.sh" "gitk"
            bash "$REPO_DIR/scripts/setup_gitk_theme.sh"
            ;;
        all)
            echo "⚙️  Running full setup..."
            bash "$REPO_DIR/scripts/stow.sh" "tmux" "nvim" "bash" "gitk"

            bash "$REPO_DIR/scripts/install_packages.sh"
            bash "$REPO_DIR/scripts/setup_gitk_theme.sh"
            bash "$REPO_DIR/scripts/setup_nvim_plugins.sh"
            bash "$REPO_DIR/scripts/setup_tmux_plugins.sh"
            ;;
        *)
            echo "❌ Unknown option: $arg"
            usage
            ;;
    esac
done

echo "🎉 Setup complete! Logs saved to $LOG_FILE"
