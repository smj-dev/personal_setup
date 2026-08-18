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
  local target="$1" # The actual file/directory that needs to be backed up

  if [[ ! -e "$target" ]]; then
    echo "✅ No existing file at $target, skipping backup."
    return 0
  fi

  if [[ -e "$target" && ! -L "$target" ]]; then
    backup_target="${target}_backup_$(date +%Y%m%d_%H%M%S)"
    echo "⚠️ Backing up: $target -> $backup_target"
    mv "$target" "$backup_target"
  fi

  if [[ -L "$target" ]]; then
    echo "⚠️ Removing existing symlink: $target"
    rm "$target"
  fi
}

for package in "$@"; do
  echo "🔗 Preparing to stow $package..."
  package_dir="$REPO_DIR/$package"
  if [[ ! -d "$package_dir" ]]; then
    echo "❌ ERROR: Stow package directory '$package_dir' does not exist!"
    exit 1
  fi

  # Decide stow target: ~/.config or ~
  if [[ -d "$package_dir/.config" ]]; then
    target_dir="$HOME/.config"
    mkdir -p "$target_dir"

    echo "📂 Detected .config in $package, stowing into ~/.config"
    for item in "$package_dir/.config"/*; do
      relative_path="${item#$package_dir/.config/}"
      backup_existing "$target_dir/$relative_path"
    done

    run_command "stow -v --no-folding -d $package_dir -t $target_dir .config"
  else
    target_dir="$HOME"

    echo "📂 No .config detected, stowing into ~"
    for item in "$package_dir"/.* "$package_dir"/*; do
      file_name=$(basename "$item")
      [[ "$file_name" == "." || "$file_name" == ".." ]] && continue
      backup_existing "$target_dir/$file_name"
    done

    run_command "stow -v --no-folding -d $package_dir -t $target_dir ."
  fi

  echo "✅ Successfully ran Stow for $package!"
done
