#!/bin/bash
set -euo pipefail

source "$(dirname "$0")/constants.sh"

# Detect distribution
if [[ -f /etc/os-release ]]; then
  source /etc/os-release
else
  echo "❌ Unable to determine Linux distribution."
  exit 1
fi

# Mason.nvim packages (LSPs, formatters, linters)
MASON_PACKAGES=(
  stylua
  lua-language-server
  rust-analyzer
  pyright
  bash-language-server
  eslint_d
  prettier
  clangd
  clang-format
  cmakelang
  checkmake
  julia-lsp
)

LUAROCKS_PACKAGES=("jsregexp") # Add more packages as needed

install_neovim() {
  echo "🔍 Checking Neovim installation..."
  if command -v nvim &>/dev/null; then
    INSTALLED_NVIM_VERSION=$(nvim --version | head -n 1 | sed -E 's/NVIM v//')
    echo "Neovim installed: v$INSTALLED_NVIM_VERSION" >>"$LOG_FILE"
  else
    INSTALLED_NVIM_VERSION="0.0.0"
  fi

  # Authoritative in both directions: lower this to downgrade.
  NVIM_VERSION="0.12.4"
  if [[ "$INSTALLED_NVIM_VERSION" == "$NVIM_VERSION" ]]; then
    echo "✅ Neovim is already at v$NVIM_VERSION."
    return 0
  fi

  echo "⚠️ Installing Neovim v$NVIM_VERSION (was v$INSTALLED_NVIM_VERSION)..."
  ARCH=$(uname -m)
  if [[ "$ARCH" == "x86_64" ]]; then
    NVIM_FILE="nvim-linux-x86_64.tar.gz"
    NVIM_DIR="nvim-linux-x86_64"
  elif [[ "$ARCH" == "aarch64" ]]; then
    NVIM_FILE="nvim-linux-arm64.tar.gz"
    NVIM_DIR="nvim-linux-arm64"
  else
    echo "❌ Unsupported architecture: $ARCH"
    exit 1
  fi

  if [[ "$ID" == "almalinux" || "$ID" == "rhel" || "$ID" == "centos" ]]; then
    run_command "sudo dnf remove -y neovim"
    run_command "sudo dnf autoremove -y"
  else
    run_command "sudo apt remove --purge neovim -y"
    run_command "sudo apt autoremove -y"
  fi

  run_command "curl -fL -O https://github.com/neovim/neovim/releases/download/v${NVIM_VERSION}/${NVIM_FILE}"
  run_command "tar xzvf $NVIM_FILE"
  run_command "sudo rm -rf /usr/local/$NVIM_DIR"
  run_command "sudo mv $NVIM_DIR /usr/local/"
  run_command "sudo ln -sf /usr/local/$NVIM_DIR/bin/nvim /usr/bin/nvim"
  run_command "rm -f $NVIM_FILE"
  run_command "rm -rf $NVIM_DIR"

  echo "✅ Neovim installed at v$NVIM_VERSION!"
}

install_luarocks_packages() {
  # Ensure luarocks is available
  if ! command -v luarocks &>/dev/null; then
    echo "📦 Luarocks not found, attempting to install..."

    if [[ "$ID" == "almalinux" || "$ID" == "rhel" || "$ID" == "centos" ]]; then
      run_command "sudo dnf install -y luarocks"
    else
      run_command "sudo apt install -y luarocks"
    fi
  fi

  for package in "${LUAROCKS_PACKAGES[@]}"; do
    if luarocks list | grep -q "^$package"; then
      echo "✔ $package is already installed."
    else
      echo "⏳ Installing $package via Luarocks..."
      if luarocks install "$package"; then
        echo "✔ Successfully installed $package."
      else
        echo "❌ Failed to install $package. Check your Luarocks setup." >&2
      fi
    fi
  done

  if ! echo "${LUA_PATH:-}" | grep -q "$HOME/.luarocks/share/lua/5.1"; then
    echo 'export LUA_PATH="$HOME/.luarocks/share/lua/5.1/?.lua;$LUA_PATH"' >>~/.bashrc
    echo 'export LUA_CPATH="$HOME/.luarocks/lib/lua/5.1/?.so;$LUA_CPATH"' >>~/.bashrc
    echo "🔄 Added LUA_PATH and LUA_CPATH to ~/.bashrc"
    source ~/.bashrc
  fi

  echo "🚀 All requested Luarocks packages are installed!"
}

# nvim-treesitter's main branch shells out to the tree-sitter CLI for every
# parser it installs ("generate" then "build"), so this is a hard dependency.
TREE_SITTER_MIN="0.26.1"

treesitter_cli_ok() {
  # Must actually run: npm ships a prebuilt binary that installs fine and then
  # fails on older glibc, so checking the path is not enough.
  local v
  v=$(tree-sitter --version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1) || return 1
  [[ -n "$v" ]] || return 1
  [[ "$(printf '%s\n' "$TREE_SITTER_MIN" "$v" | sort -V | head -n 1)" == "$TREE_SITTER_MIN" ]]
}

install_treesitter_cli() {
  if treesitter_cli_ok; then
    echo "✅ $(tree-sitter --version) already usable."
    return 0
  fi

  # Prebuilt first: seconds instead of minutes, when the binary runs here.
  # The global npm prefix (/usr from the NodeSource install) is root-owned, so
  # -g needs sudo; without it npm dies with EACCES before the binary is tested.
  if command -v npm &>/dev/null; then
    echo "📦 Installing tree-sitter CLI via npm..."
    sudo npm install -g tree-sitter-cli >>"$LOG_FILE" 2>&1 || true
    if treesitter_cli_ok; then
      echo "✅ $(tree-sitter --version) installed."
      return 0
    fi
    echo "⚠️ npm build unusable here, falling back to building from source."
    sudo npm uninstall -g tree-sitter-cli >>"$LOG_FILE" 2>&1 || true
  fi

  if command -v cargo &>/dev/null; then
    echo "📦 Building tree-sitter CLI with cargo (a few minutes)..."
    cargo install tree-sitter-cli >>"$LOG_FILE" 2>&1 || true
    if treesitter_cli_ok; then
      echo "✅ $(tree-sitter --version) installed."
      return 0
    fi
  fi

  echo "❌ Could not get tree-sitter CLI >= $TREE_SITTER_MIN on PATH."
  echo "   nvim-treesitter cannot build parsers without it. Check $LOG_FILE."
  exit 1
}

install_neovim_plugins() {
  echo "📦 Installing Neovim plugins..."

  NVIM_LAZY_PATH="$HOME/.local/share/nvim/lazy/lazy.nvim"
  if [ ! -d "$NVIM_LAZY_PATH" ]; then
    echo "Cloning Lazy.nvim..." >>"$LOG_FILE"
    run_command "git clone --filter=blob:none https://github.com/folke/lazy.nvim.git --branch=stable $NVIM_LAZY_PATH"
  else
    echo "✅ Lazy.nvim is already installed."
  fi

  run_command "nvim --headless '+Lazy! sync' +qall"

  echo "📦 Installing Mason.nvim tools..."
  MASON_INSTALL_CMD="MasonInstall ${MASON_PACKAGES[*]}"
  run_command "nvim --headless -c 'lua require(\"mason-registry\").refresh()' -c '$MASON_INSTALL_CMD' -c 'qall'"

  echo "✅ Neovim plugins and Mason tools installed successfully!"
}

install_neovim
install_treesitter_cli
install_neovim_plugins
#install_luarocks_packages # TODO: luarocks setup on WSL may be broken
