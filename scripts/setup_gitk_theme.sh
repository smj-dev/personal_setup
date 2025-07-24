#!/bin/bash
source "$(dirname "$0")/constants.sh"

GITK_DIR="$HOME/.config/gitk"
mkdir -p "$GITK_DIR"

THEME_FILE="$GITK_DIR/gitkrc"
if [[ ! -f "$THEME_FILE" ]]; then
    echo "🔄 Downloading Dracula gitk theme..."
    curl -fsSL https://raw.githubusercontent.com/dracula/gitk/master/gitkrc -o "$THEME_FILE" >> "$LOG_FILE" 2>&1
    echo "✅ gitkrc theme installed to $THEME_FILE"
else
    echo "🎨 gitkrc theme already exists, skipping."
fi
