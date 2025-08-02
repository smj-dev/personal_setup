# Personal Setup

This repository provides a complete setup for Neovim, tmux, and related tools.
It includes scripts to install packages, configure plugins, and manage sessions.

---

## Usage

Clone the repository and run the setup script. To install everything run:

```bash
git clone https://github.com/smj-dev/personal_setup.git
cd personal_setup
./setup.sh all
```

Options:

* `packages`
  Install system packages (via apt) and Mason packages for Neovim.
* `tmux`
  Stow tmux configuration and install tmux plugins.
* `nvim`
  Stow Neovim configuration and install Neovim plugins.
* `bash`
  Stow bash configuration and reload `.bashrc` and `.bash_aliases`.
* `gitk`
  Apply gitk theme configuration.
* `all`
  Run the full setup: install packages, stow configs, and set up plugins.

Running without arguments will show usage instructions.

---

## Entry Points

* **`setup.sh`**
  Main entry script.
  Handles installing packages and applying configurations.
  All package installation goes through this script — `install_packages.sh` is not meant to be called directly.

* **`scripts/generate_start_scripts.sh`**
  Generates a tmux session start script.
  Example:

  ```bash
  ./scripts/generate_start_scripts.sh \
    --session MySession \
    --output ~/bin \
    --repo personal_setup=~/repos/personal_setup \
    --repo monophon=~/repos/monophon
  ```

  The generated script will create or attach to a tmux session with one `nvim` and one `shell` window for each repository.

---

## Adding Packages

Packages are managed through [`scripts/install_packages.sh`](scripts/install_packages.sh).

* Add **system packages** to the `packages` list.
* Add **Mason packages** (for Neovim) to the `mason_packages` list.

Then run:

```bash
./setup.sh packages
```

or include `packages` in a full setup:

```bash
./setup.sh all
```

---

## Keybindings

All custom keybindings for Neovim and tmux are documented in [keybinds.md](keybinds.md).

The file includes:

* Neovim navigation and editing
* Telescope search bindings
* LSP commands
* tmux prefix, pane, and window navigation
* Plugin‑specific bindings (Visual Multi, Surround, Snippets, etc.)

---

## Restowing Configurations

To update settings without installing packages:

```bash
./scripts/stow.sh [nvim|tmux|bash|gitk]
```

---

## Repository Structure

```
personal_setup/
├── nvim/                 # Neovim configuration
├── tmux/                 # tmux configuration
├── scripts/              # Setup and helper scripts
│   ├── setup.sh
│   ├── generate_start_scripts.sh
│   ├── install_packages.sh
│   └── stow.sh
├── keybinds.md           # Documentation of all keybindings
└── README.md             # This file
```

