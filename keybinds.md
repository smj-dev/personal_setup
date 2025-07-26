# Keybindings

## Neovim

### General

* **Leader Key:** `<Space>`

### Navigation

*Default Neovim Navigation:*

* **Move left:** `h`
* **Move down:** `j`
* **Move up:** `k`
* **Move right:** `l`
* **Start of line:** `0`
* **First non-blank character:** `^`
* **End of line:** `$`
* **Go to first line:** `gg`
* **Go to last line:** `G`

#### Larger movements

* **Go to beginning of line:** `H`
* **Go to end of line:** `L`
* **Scroll up:** `K`
* **Scroll down:** `J`

#### Jumplist

* **Jump to previous location:** `<C-o>`
* **Jump to next location:** `<C-i>`

#### Navigation in insert mode

* **Move left:** `Alt + h`
* **Move down:** `Alt + j`
* **Move up:** `Alt + k`
* **Move right:** `Alt + l`
* **Word left:** `Alt + K`
* **Word right:** `Alt + L`
* **Half-page down:** `Alt + J`
* **Half-page up:** `Alt + J`
* **Delete previous word:** `Alt + Backspace`

### Visual Multi (vim-visual-multi)

* **Add cursor down:** `Alt + j`
* **Add cursor up:** `Alt + k`
* **Add next match of word under cursor:** `<C-d>`
* **Select all matches of word under cursor:** `<Space>a`
* **Add next match of visual selection:** `<Space>v`
* **Select all matches of visual selection:** `<Space>A`
* **Skip current match:** `<Space>q`
* **Remove last match:** `<Space>Q`

### Searching

* **Fuzzy find files:** `<C-p>` or `<Space>ff`
* **Grep in project:** `<Space>fg`
* **Jump to symbol in file:** `<Space>fs`

*Default Neovim Searching:*

* **Search forward:** `/`
* **Search backward:** `?`
* **Next search result:** `n`
* **Previous search result:** `N`

### File Explorer (Tree)

* **Open sidebar (Neotree):** `<C-n>`

### LSP (Language Server Protocol)

* **Show hover information:** `K`
* **Go to definition:** `gd`
* **Go to declaration:** `gD`
* **Go to implementation:** `gi`
* **Go to references:** `gr`
* **Code action:** `<Space>ca`
* **Rename symbol:** `<Space>rn`

### Undo

* **Toggle undo tree:** `<Space>u`

*Default Neovim Undo:*

* **Undo:** `u`
* **Redo:** `<C-r>`

### Completions (nvim-cmp)

* **Trigger completion:** `<C-m>`
* **Scroll docs:** `<C-b> / <C-f>`
* **Next/Previous suggestion:** `<C-j> / <C-e>`
* **Confirm suggestion:** `<Enter>`

### Commenting (Comment.nvim)

* **Toggle line comment (normal mode):** `gcc`
* **Toggle line comment (visual mode):** `gc`

### Editing

* **Insert new line below (insert mode):** `o`
* **Insert new line above (insert mode):** `O`
* **Create line below (normal mode, stay in normal):** `<Space>o`
* **Create line above (normal mode, stay in normal):** `<Space>O`
* **Move line up (normal):** `Ctrl + Alt + k`
* **Move line down (normal):** `Ctrl + Alt + j`
* **Move selection up (visual):** `Ctrl + Alt + k`
* **Move selection down (visual):** `Ctrl + Alt + j`
* **Indent/unindent line (normal):** `Ctrl + Alt + h / l`
* **Indent/unindent block (visual):** `Ctrl + Alt + h / l`

### Surround (nvim-surround)

* **Add surround:** `ys<motion><char>` (e.g., `ysiw"` → "word")
* **Change surround:** `cs<old><new>` (e.g., `cs"'`)
* **Delete surround:** `ds<char>` (e.g., `ds"`)
* **Visual surround:** `S<char>` (in visual mode)

### Snippet Expansion (LuaSnip)

* **Expand or jump forward:** `<C-K>` (insert/select mode)
* **Jump backward:** `<C-J>` (insert/select mode)
* **Cycle through choices:** `<C-L>` (insert mode)

---

## tmux

### Prefix Key

* **Prefix Key:** `Ctrl+a`

### Session Management

* **Create new session:** `tmux new-session -s name`
* **List sessions:** `tmux ls`
* **Attach session:** `tmux attach -t name`
* **Detach:** `Ctrl+a d`

### Window Management

* **Create new window:** `Ctrl+a t`
* **Rename window:** `Ctrl+a ,`
* **Close window:** `Ctrl+a w`
* **Next/Previous window:** `Ctrl+a n / Ctrl+a p`
* **Last active window:** `Ctrl+a o`

### Pane Management

* **Split horizontally:** `Ctrl+a v`
* **Split vertically:** `Ctrl+a V`
* **Navigate between panes:** `Ctrl+a` + `h/j/k/l`

### Copy Mode

* **Enter copy mode:** `Ctrl+a c`
* **Scroll and copy:** standard copy-mode keys

### Plugins Used

* **TPM:** `tmux-plugins/tpm`
* **Navigator:** `vim-tmux-navigator`
* **Theme:** `catppuccin/tmux`

---

*References:*

* Neovim Default Keybindings: [Neovim Documentation](https://neovim.io/doc/user/quickref.html)
* tmux Keybindings: [tmux man page](https://man7.org/linux/man-pages/man1/tmux.1.html)

