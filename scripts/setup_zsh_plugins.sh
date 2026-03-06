#!/bin/bash
set -euo pipefail

source "$(dirname "$0")/constants.sh"

ZSH_PLUGIN_DIR="$HOME/.local/share/zsh/plugins"
mkdir -p "$ZSH_PLUGIN_DIR"

install_plugin() {
  local repo="$1"
  local name="$2"
  local dir="$ZSH_PLUGIN_DIR/$name"

  if [ ! -d "$dir" ]; then
    echo "Cloning $name..."
    git clone --depth 1 "https://github.com/$repo" "$dir" >>"$LOG_FILE" 2>&1
  else
    echo "$name already installed, skipping clone."
  fi
}

install_plugin "zsh-users/zsh-autosuggestions" "zsh-autosuggestions"
install_plugin "zsh-users/zsh-syntax-highlighting" "zsh-syntax-highlighting"
install_plugin "zsh-users/zsh-completions" "zsh-completions"
install_plugin "zsh-users/zsh-history-substring-search" "zsh-history-substring-search"
install_plugin "Aloxaf/fzf-tab" "fzf-tab"

echo "✅ zsh plugins installed."
