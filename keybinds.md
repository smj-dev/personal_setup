# Keybindings

## Neovim

### General
- **Leader Key:** `<Space>`

### Navigation
- **Go to beginning of line:** `H`
- **Go to end of line:** `L`

*Default Neovim Navigation:*
- **Move left:** `h`
- **Move down:** `j`
- **Move up:** `k`
- **Move right:** `l`
- **Start of line:** `0`
- **First non-blank character:** `^`
- **End of line:** `$`
- **Go to first line:** `gg`
- **Go to last line:** `G`

### Searching
- **Fuzzy find files:** `<Space>f`
- **Grep in file:** `<Space>g`

*Default Neovim Searching:*
- **Search forward:** `/`
- **Search backward:** `?`
- **Next search result:** `n`
- **Previous search result:** `N`

### File Explorer (Tree)
- **Open sidebar:** `<C-P>`
- **Select file:** `Enter`
- **Add file/dir:** `a`
- **Delete file/dir:** `d`

### LSP (Language Server Protocol)
- **Show definition:** `K`
- **Code action:** `<Space>ca`
- **Go to definition:** `gd`
- **Show hover information:** `K`
- **Go to declaration:** `gD`
- **Go to implementation:** `gi`
- **Go to references:** `gr`

### Undo
- **Undo:** `u`
- **Access undo tree:** `<Space>u`

*Default Neovim Undo:*
- **Undo:** `u`
- **Redo:** `<C-r>`

### Completions
- **Next suggestion:** `<Tab>`
- **Select suggestion:** `<Enter>`

*Default Neovim Completions:*
- **Trigger completion:** `<C-n>` (next), `<C-p>` (previous)
- **Confirm completion:** `<Enter>`

---

## tmux

### Prefix Key
- **Prefix Key:** `Ctrl+b` (or customized key if changed)

### Session Management
- **Create new session:** `tmux new-session -s session_name`
- **List sessions:** `tmux ls`
- **Attach to session:** `tmux attach-session -t session_name`
- **Detach from session:** `Ctrl+b d`

### Window Management
- **Create new window:** `Ctrl+b c`
- **Rename current window:** `Ctrl+b ,`
- **Close current window:** `Ctrl+b &`
- **Navigate to next window:** `Ctrl+b n`
- **Navigate to previous window:** `Ctrl+b p`
- **Select window by number (0-9):** `Ctrl+b [0-9]`

### Pane Management
- **Split pane horizontally:** `Ctrl+b "` (double quotes)
- **Split pane vertically:** `Ctrl+b %`
- **Navigate between panes:** `Ctrl+b` followed by arrow keys
- **Resize pane:** `Ctrl+b` followed by arrow keys
- **Toggle pane zoom:** `Ctrl+b z`
- **Close current pane:** `Ctrl+b x`

### Copy Mode
- **Enter copy mode:** `Ctrl+b [`
- **Scroll up/down:** Use arrow keys or `PgUp`/`PgDn`
- **Start selection:** `Space`
- **Copy selection:** `Enter`
- **Paste buffer:** `Ctrl+b ]`

---

*References:*
- Neovim Default Keybindings: [Neovim Documentation](https://neovim.io/doc/user/quickref.html)
- tmux Default Keybindings: [tmux man page](https://man7.org/linux/man-pages/man1/tmux.1.html)

