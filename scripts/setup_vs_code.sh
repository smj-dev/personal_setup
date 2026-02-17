#!/usr/bin/env bash
set -euo pipefail

EXTENSIONS=(
  catppuccin.catppuccin-vsc
  haskell.haskell
  justusadam.language-haskell
  ms-python.black-formatter
  ms-python.debugpy
  ms-python.python
  ms-python.vscode-pylance
  ms-python.vscode-python-envs
  vscodevim.vim
  yzhang.markdown-all-in-one
)

# Detect distro
. /etc/os-release

install_code_debian() {
    if command -v code >/dev/null 2>&1; then
        return
    fi

    sudo install -d -m 0755 /etc/apt/keyrings

    curl -fsSL https://packages.microsoft.com/keys/microsoft.asc \
        | sudo gpg --dearmor -o /etc/apt/keyrings/microsoft.gpg

    echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/microsoft.gpg] https://packages.microsoft.com/repos/code stable main" \
        | sudo tee /etc/apt/sources.list.d/vscode.list >/dev/null

    sudo apt-get update
    sudo apt-get install -y code
}

install_code_rhel() {
    if command -v code >/dev/null 2>&1; then
        return
    fi

    sudo tee /etc/yum.repos.d/vscode.repo >/dev/null <<'EOF'
[code]
name=Visual Studio Code
baseurl=https://packages.microsoft.com/yumrepos/vscode
enabled=1
gpgcheck=1
gpgkey=https://packages.microsoft.com/keys/microsoft.asc
EOF

    sudo dnf install -y code
}

case "$ID" in
    ubuntu|debian)
        install_code_debian
        ;;
    rhel|centos|almalinux|rocky|fedora)
        install_code_rhel
        ;;
    *)
        echo "Unsupported distro: $ID"
        exit 1
        ;;
esac

# install extensions
for ext in "${EXTENSIONS[@]}"; do
    code --install-extension "$ext" --force >/dev/null
done

echo "VS Code + extensions installed."

