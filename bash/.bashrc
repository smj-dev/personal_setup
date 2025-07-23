# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# Define colors
RESET="\[\e[0m\]"
FG_BLUE="\[\e[38;5;110m\]"      # Muted blue
FG_GREEN="\[\e[38;5;108m\]"     # Muted green
FG_LAVENDER="\[\e[38;5;141m\]"  # Soft lavender
FG_ROSEWATER="\[\e[38;5;217m\]" # Rosewater for git branch

# Function to show Git branch dynamically with proper color handling
git_branch() {
    local branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
    if [ -n "$branch" ]; then
        echo -n " \[\e[38;5;217m\]($branch)\[\e[0m\]"
    fi
}

# Don't put duplicate lines or lines starting with space in the history.
HISTCONTROL=ignoreboth

# Append to the history file, don't overwrite it
shopt -s histappend

# For setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# Check the window size after each command and update LINES and COLUMNS
shopt -s checkwinsize

# Enable pathname expansion with "**" to match files and subdirectories
# shopt -s globstar

# Make less more friendly for non-text input files
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# Identify the chroot environment
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# Check if the terminal supports color
case "$TERM" in
    xterm-color|*-256color) color_prompt=yes;;
esac

# Enable ls color support and add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# Some more ls aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# Alert alias for long-running commands
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"' 

# Load bash aliases if the file exists
if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# Enable programmable completion features
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

update_prompt() {
    export PS1="${FG_LAVENDER}\u${FG_GREEN}:\w$(git_branch)${RESET}\$ "
}

# Set the dynamic prompt before every command
PROMPT_COMMAND=update_prompt

# Set terminal title in xterm/rxvt
case "$TERM" in
    xterm*|rxvt*)
        PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u: \w\a\]$PS1"
        ;;
esac

# Add custom paths
export PATH="$PATH:/opt/nvim/"
export PATH="$PATH:$HOME/.local/bin"

export EDITOR=vim
export VISUAL=vim

export LUA_PATH="$HOME/.luarocks/share/lua/5.1/?.lua;$LUA_PATH"
export LUA_CPATH="$HOME/.luarocks/lib/lua/5.1/?.so;$LUA_CPATH"
export JUCE_AUDIODEVICETYPE=PULSE
