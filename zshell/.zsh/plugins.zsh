# ~/.zsh/plugins.zsh

# Where plugins are installed (NOT stowed)
ZSH_PLUGIN_DIR="$HOME/.local/share/zsh/plugins"

# zsh-completions: add to fpath BEFORE compinit
fpath=("$ZSH_PLUGIN_DIR/zsh-completions/src" $fpath)

autoload -Uz compinit
compinit -i

# autosuggestions
source "$ZSH_PLUGIN_DIR/zsh-autosuggestions/zsh-autosuggestions.zsh"

# history substring search + bindings
source "$ZSH_PLUGIN_DIR/zsh-history-substring-search/zsh-history-substring-search.zsh"
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down

# fzf-tab (after compinit)
source "$ZSH_PLUGIN_DIR/fzf-tab/fzf-tab.plugin.zsh"

# syntax highlighting MUST be last
source "$ZSH_PLUGIN_DIR/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
