#!/usr/bin/env bash

source "$(dirname "$0")/constants.sh"

TMUX_PLUGIN_DIR="$HOME/.tmux/plugins"

# Ensure the tmux plugin directory exists
mkdir -p "$TMUX_PLUGIN_DIR"

# Install TPM if not already installed
if [ ! -d "$TMUX_PLUGIN_DIR/tpm" ]; then
    echo "Cloning TPM..."
    git clone https://github.com/tmux-plugins/tpm "$TMUX_PLUGIN_DIR/tpm" >> "$LOG_FILE" 2>&1
else
    echo "TPM already installed, skipping clone."
fi

# Install Catppuccin theme if not already installed
if [ ! -d "$TMUX_PLUGIN_DIR/tmux-catppuccin" ]; then
    echo "Cloning Catppuccin theme..."
    git clone https://github.com/catppuccin/tmux.git "$TMUX_PLUGIN_DIR/tmux-catppuccin" >> "$LOG_FILE" 2>&1
else
    echo "Catppuccin theme already installed, skipping clone."
fi

# Install tmux-yank if not already installed
if [ ! -d "$TMUX_PLUGIN_DIR/tmux-yank" ]; then
    echo "Cloning tmux-yank..."
    git clone https://github.com/tmux-plugins/tmux-yank "$TMUX_PLUGIN_DIR/tmux-yank" >> "$LOG_FILE" 2>&1
else
    echo "tmux-yank already installed, skipping clone."
fi

# Install plugins using TPM
echo "Installing tmux plugins via TPM..."
"$TMUX_PLUGIN_DIR/tpm/bin/install_plugins" >> "$LOG_FILE" 2>&1

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

echo "✅ tmux base setup complete!"
