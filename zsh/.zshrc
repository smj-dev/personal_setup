# only run in interactive shells
[[ -o interactive ]] || return

# history
HISTFILE="$HOME/.zsh_history"
HISTSIZE=10000
SAVEHIST=10000
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt INC_APPEND_HISTORY

# load modules
source "$HOME/.zsh/env.zsh"
source "$HOME/.zsh/aliases.zsh"
source "$HOME/.zsh/keybinds.zsh"
source "$HOME/.zsh/completions.zsh"
source "$HOME/.zsh/plugins.zsh"
source "$HOME/.zsh/prompt.zsh"
