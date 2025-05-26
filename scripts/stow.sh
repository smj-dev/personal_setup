#!/bin/bash
set -euo pipefail 

source "$(dirname "$0")/constants.sh"

# Ensure at least one argument is passed
if [[ $# -eq 0 ]]; then
    echo "Usage: $(basename "$0") <package1> <package2> ..."
    exit 1
fi


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

for package in "$@"; do
    echo "🔗 Preparing to stow $package..."
    package_dir="$REPO_DIR/$package"

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
done
