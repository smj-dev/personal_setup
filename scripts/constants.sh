#!/bin/bash

# General constants
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SCRIPT_DIR="$REPO_DIR/scripts"

LOG_FILE="$REPO_DIR/install.log"

# Colors for output formatting
GREEN="\e[32m"
RED="\e[31m"
YELLOW="\e[33m"
RESET="\e[0m"

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