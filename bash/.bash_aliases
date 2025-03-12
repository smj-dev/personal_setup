# ~/.bash_aliases: Custom aliases for Bash

# ======= General Aliases =======
alias ll='ls -alF'  # Long listing format with hidden files
alias la='ls -A'    # Show hidden files, but not . and ..
alias l='ls -CF'    # Compact output format
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'

# ======= Navigation =======
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias ~='cd ~'
alias home='cd ~'

# ======= Git Aliases =======
alias gs='git status'
alias ga='git add'
alias gc='git commit -m'
alias gp='git push'
alias gl='git log --oneline --graph --decorate --all'
alias gco='git checkout'
alias gb='git branch'


# ======= addons =======
alias cat='batcat --paging=never'
