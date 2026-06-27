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

# Prefer completion over history for suggestions
ZSH_AUTOSUGGEST_STRATEGY=(completion history)

# Partial accept by word
typeset -ga ZSH_AUTOSUGGEST_PARTIAL_ACCEPT_WIDGETS
ZSH_AUTOSUGGEST_PARTIAL_ACCEPT_WIDGETS+=(forward-word)

# Ignore commands starting with a space
setopt HIST_IGNORE_SPACE
# Create local.zsh for maschine specific conf.
if [[ -f "$HOME/.zsh/local.zsh" ]]; then
    source "$HOME/.zsh/local.zsh"
fi

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
