#!/bin/bash
set -euo pipefail

source "$(dirname "$0")/scripts/constants.sh"

>"$LOG_FILE" # Reset log file at the beginning
echo "📜 Logging output to $LOG_FILE"

# gitk owns its config once installed (it writes window geometry back to it), so
# an existing file is the machine's, not ours. Asking is enough: the user ran this.
install_gitk_config() {
  local target="$HOME/.config/git/gitk"
  local reply=""

  if [[ -f "$target" ]]; then
    if [[ ! -t 0 ]]; then
      echo "⚠️  $target exists and there is no terminal to confirm on, keeping it."
      return 0
    fi
    read -rp "⚠️  $target already exists. Overwrite? [y/N] " reply || reply=""
    if [[ ! "$reply" =~ ^[Yy]$ ]]; then
      echo "Keeping the existing gitk config."
      return 0
    fi
  fi

  mkdir -p "$(dirname "$target")"
  cp "$SCRIPT_DIR/gitk_config.default" "$target"
  echo "✅ Installed gitk config to $target"
}

usage() {
  echo "Usage: $(basename "$0") [packages|tmux|nvim|bash|zsh|gitk|code|all]"
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
  nvim)
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
  zsh)
    echo "Setting up ZShell..."
    bash "$REPO_DIR/scripts/stow.sh" "zsh"

    if [ "${SHELL:-}" != "$(command -v zsh)" ]; then
      echo "Setting default shell to zsh."
      sudo usermod -s "$(command -v zsh)" "$USER"
    fi

    bash "$REPO_DIR/scripts/setup_zsh_plugins.sh"
    source ~/.zshrc
    source ~/.zsh
    ;;
  gitk)
    echo "Setting up gitk theme..."
    install_gitk_config
    ;;
  code)
    echo "Setting up vs code config..."
    bash "$REPO_DIR/scripts/setup_vs_code.sh"
    bash "$REPO_DIR/scripts/vscode.sh" sync
    ;;
  all)
    echo "⚙️  Running full setup..."
    bash "$REPO_DIR/scripts/install_packages.sh"
    bash "$REPO_DIR/scripts/stow.sh" "tmux" "nvim" "bash"  "zsh"

    bash "$REPO_DIR/scripts/setup_nvim_plugins.sh"
    bash "$REPO_DIR/scripts/setup_tmux_plugins.sh"

    echo "Setting up gitk theme..."
    install_gitk_config
    ;;
  *)
    echo "❌ Unknown option: $arg"
    usage
    ;;
  esac
done

echo "🎉 Setup complete! Logs saved to $LOG_FILE"
