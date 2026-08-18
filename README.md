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

Options for setup.sh:

* `packages`
  Install system packages (via apt) and Mason packages for Neovim.
* `tmux`
  Stow tmux configuration and install tmux plugins.
* `nvim`
  Stow Neovim configuration and install Neovim plugins.
* `bash`
  Stow bash configuration and reload `.bashrc` and `.bash_aliases`.
* `zsh`
  Stow zsh configuration, install plugins, and set zsh as the default shell.
* `code`
  Install VS Code if missing, then sync settings, keybindings, and extensions.
* `gitk`
  Install the default gitk config, asking first if the machine already has one.
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
    --output <output file location> \
    --repo <repo name>=<repo path> \
  ```

  The `--repo` argument can be given multiple times. The generated script will create or attach to a tmux session with one `nvim` and one `shell` window for each repository.

---

## Adding Packages

Packages are managed through `scripts/install_packages.sh`.

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
./scripts/stow.sh [nvim|tmux|bash|zsh|gitk]
```

Stow is invoked with `--no-folding`, so every package produces per-file symlinks.
Without it, stow collapses a package into a single directory symlink pointing into
this repo, and anything the application writes into that directory lands in git.

---

## Neovim plugins

Plugin versions are deliberately **not** tracked. lazy.nvim's lockfile lives at
`~/.local/share/nvim/lazy-lock.json`, outside the repo (`init.lua` sets `lockfile`),
so `:Lazy update` can never show up as a repo change and a fresh machine installs
whatever is current.

What is tracked is `nvim/lazy-lock.known-good.json` — a backup you update only when
you want to, not a pin you have to maintain:

```bash
./scripts/nvim_lock.sh save     # bless the current versions once you have used them
./scripts/nvim_lock.sh restore  # put them back and check the plugins out, when an update breaks nvim
```

`restore` copies the known good lockfile into place and runs `:Lazy! restore`, so it
actually downgrades the installed plugins rather than only rewriting a file. It keeps
the lockfile it replaced as `lazy-lock.json.before-restore` in case the rollback was
the mistake.

The file is not under `nvim/.config/`, because anything there gets stowed into
`~/.config/nvim` and would become the live lockfile again.

---

## gitk

gitk stores window geometry in its own config file and rewrites it on exit, so the
file is not stowed — stowing it is what made window-size diffs ride along in
unrelated commits. Instead `scripts/gitk_config.default` is copied to
`~/.config/git/gitk`, and from then on the machine owns that file.

Running `./setup.sh gitk` again will offer to overwrite it — it is an explicit
command, so it is allowed to replace the machine's copy, but it asks first because
doing so discards whatever gitk has saved there. Answering no keeps the existing
file; with no terminal to ask on, it keeps the existing file and says so.

To push a theme change out, edit `scripts/gitk_config.default`, commit, and run
`./setup.sh gitk` on the machines you want updated. The default deliberately
contains no `geometry(*)` or `permviews` lines so gitk picks its own on first run.

Only `gitk/.config/git/ignore` is stowed, since git never writes to it.

---

## VS Code

VS Code rewrites `settings.json` and `keybindings.json` itself, so those files are
**generated** rather than stowed. Three layers feed into them:

| Layer | Location | Tracked |
| --- | --- | --- |
| Baseline | `code/settings.base.jsonc`, `code/keybindings.base.jsonc`, `code/extensions.txt` | yes |
| Machine overlay | `~/.config/personal_setup/vscode/*.local.json`, `extensions.local.txt` | no |
| Snapshot | `~/.config/personal_setup/vscode/.*.snapshot.json` | no |

The snapshot records what was last generated, which makes it the common ancestor for
a three-way merge. On every sync anything that differs between the snapshot and the
live file must have come from this machine, so it is captured into the overlay first
and the result is regenerated from baseline + overlay. Changes made through the VS
Code UI therefore persist, and pulling a new baseline updates every key this machine
has not claimed.

```bash
./scripts/vscode.sh sync            # capture local changes, then regenerate
./scripts/vscode.sh status          # what this machine overrides, and extension drift
./scripts/vscode.sh forget <key>    # drop an override so the baseline applies again
./scripts/vscode.sh target          # print the resolved VS Code User directory
```

The target directory is detected for native Linux, macOS, Git Bash on Windows, and
WSL driving a Windows-host VS Code. Set `VSCODE_USER_DIR` in `~/.bashrc.local` or
`~/.zsh/local.zsh` to override it.

Extensions are the union of `code/extensions.txt` and the machine's
`extensions.local.txt` — put things you only want on some machines, such as Copilot,
in the local list. Nothing is ever uninstalled; `status` reports anything installed
that is on neither list so you can decide where it belongs.

To promote a local override to every machine, move it into the baseline file by hand
and run `forget` on that machine so it stops shadowing.


