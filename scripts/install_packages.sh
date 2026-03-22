#!/bin/bash
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [[ -f "$SCRIPT_DIR/constants.sh" ]]; then
    source "$SCRIPT_DIR/constants.sh"
fi

: "${LOG_FILE:=$SCRIPT_DIR/setup.log}"

if ! declare -F run_command >/dev/null 2>&1; then
    run_command() {
        local command="$1"

        echo "Running: $command"
        eval "$command" >> "$LOG_FILE" 2>&1
    }
fi

FAILED_STEPS=()

record_failure() {
    local step="$1"

    FAILED_STEPS+=("$step")
    echo "❌ Failed: $step"
}

setup_nodesource_repo() {
    if [[ "$ID" == "debian" || "$ID" == "ubuntu" ]]; then
        if run_command "curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -"; then
            echo "✅ NodeSource repository configured."
        else
            record_failure "setup NodeSource repository"
        fi
    else
        if run_command "curl -fsSL https://rpm.nodesource.com/setup_18.x | sudo bash -"; then
            echo "✅ NodeSource repository configured."
        else
            record_failure "setup NodeSource repository"
        fi
    fi
}

install_package_debian() {
    local package="$1"

    if dpkg -s "$package" >/dev/null 2>&1; then
        echo "✅ $package is already installed."
        return 0
    fi

    echo "Installing $package..."
    if run_command "sudo apt-get install -y \"$package\""; then
        echo "✅ Installed $package."
    else
        record_failure "install package $package"
    fi
}

install_package_rhel() {
    local package="$1"

    if rpm -q "$package" >/dev/null 2>&1; then
        echo "✅ $package is already installed."
        return 0
    fi

    echo "Installing $package..."
    if run_command "sudo dnf install --skip-broken -y \"$package\""; then
        echo "✅ Installed $package."
    else
        record_failure "install package $package"
    fi
}

install_with_pip() {
    local package="$1"

    if python3 -m pip show "$package" >/dev/null 2>&1; then
        echo "✅ $package is already installed via pip."
        return 0
    fi

    echo "Installing $package with pip..."
    if run_command "python3 -m pip install --user \"$package\""; then
        echo "✅ Installed $package via pip."
    else
        record_failure "install pip package $package"
    fi
}

if [[ -f /etc/os-release ]]; then
    source /etc/os-release
else
    echo "❌ Unable to determine Linux distribution."
    exit 1
fi

COMMON_PACKAGES=(
    stow
    wget
    curl
    git
    gitk
    unzip
    tmux
    fzf
    ripgrep
    zsh
    python3
    python3-pip
    nodejs
    cargo
    clang
    clang-format
    cmake
    make
    xclip
    bat
    python3-venv
    alsa-utils
)

DEBIAN_PACKAGES=(
    lua5.1
    liblua5.1-0-dev
    libgtk-3-dev
    fd-find
    zoxide
)

RHEL_PACKAGES=(
    lua
    lua-devel
    gtk3-devel
    webkit2gtk3-devel
    fd-find
    zoxide
)

echo "📦 Detected distro: $ID"
echo "📦 Installing system packages..."

if [[ "$ID" == "debian" || "$ID" == "ubuntu" ]]; then
    echo "📦 Running apt update..."
    if run_command "sudo apt-get update"; then
        echo "✅ Package lists updated."
    else
        record_failure "apt-get update"
    fi

    setup_nodesource_repo

    for package in "${COMMON_PACKAGES[@]}" "${DEBIAN_PACKAGES[@]}"; do
        install_package_debian "$package"
    done

    install_with_pip "jrnl"

elif [[ "$ID" == "almalinux" || "$ID" == "rhel" || "$ID" == "centos" || "$ID" == "fedora" ]]; then
    echo "📦 Running dnf update..."
    if run_command "sudo dnf -y update"; then
        echo "✅ System updated."
    else
        record_failure "dnf update"
    fi

    setup_nodesource_repo

    for package in "${COMMON_PACKAGES[@]}" "${RHEL_PACKAGES[@]}"; do
        install_package_rhel "$package"
    done

    install_with_pip "jrnl"

else
    echo "❌ Unsupported distribution: $ID"
    exit 1
fi

echo

if [[ ${#FAILED_STEPS[@]} -gt 0 ]]; then
    echo "⚠️ Completed with failures:"
    printf ' - %s\n' "${FAILED_STEPS[@]}"
    exit 1
fi

echo "✅ Packages installed successfully!"
