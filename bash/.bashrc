# ~/.bashrc: executed by bash(1) for non-login shells.

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# ======= History Settings =======
HISTCONTROL=ignoreboth      # Don't put duplicate lines or lines starting with space in history
shopt -s histappend         # Append to the history file, don't overwrite it
HISTSIZE=1000
HISTFILESIZE=2000

# ======= Shell Behavior =======
shopt -s checkwinsize       # Check the window size after each command

# ======= Lesspipe (for better file viewing) =======
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# ======= Detect Chroot =======
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# ======= Prompt Setup =======
case "$TERM" in
    xterm-color|*-256color) color_prompt=yes;;
esac

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
        color_prompt=yes
    else
        color_prompt=
    fi
fi

# Load Git bash prompt support (if available)
if [ -f /usr/share/git-core/contrib/completion/git-prompt.sh ]; then
    source /usr/share/git-core/contrib/completion/git-prompt.sh
elif [ -f /etc/bash_completion.d/git-prompt ]; then
    source /etc/bash_completion.d/git-prompt
fi

# Customize PS1 to include Git branch
export GIT_PS1_SHOWDIRTYSTATE=1
export GIT_PS1_SHOWUNTRACKEDFILES=1
export GIT_PS1_SHOWSTASHSTATE=1
export GIT_PS1_SHOWUPSTREAM="auto"

if [ "$color_prompt" = yes ]; then
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]$(__git_ps1 " (%s)")\$ '
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w$(__git_ps1 " (%s)")\$ '
fi

unset color_prompt force_color_prompt

# ======= XTerm Title =======
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac

# ======= Source Aliases =======
if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# ======= Enable Bash Completion =======
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

# ======= Custom Paths =======
export PATH="$PATH:/opt/nvim/"
export PATH="$PATH:$HOME/.local/bin"
