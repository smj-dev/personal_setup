autoload -Uz colors
colors
setopt PROMPT_SUBST

# Toggle these on when you actually want them
: ${PROMPT_SHOW_DOCKER:=0}
: ${PROMPT_SHOW_KUBE:=0}

_prompt_git() {
  command git rev-parse --is-inside-work-tree >/dev/null 2>&1 || return 0
  local b
  b=$(command git rev-parse --abbrev-ref HEAD 2>/dev/null) || return 0
  print -n " %F{magenta}[$b]%f"
}

_prompt_exit() {
  local code="$1"
  if [[ "$code" -ne 0 ]]; then
    print -n " %F{red}$code%f"
  fi
}

_prompt_docker() {
  (( PROMPT_SHOW_DOCKER )) || return 0
  command -v docker >/dev/null 2>&1 || return 0
  local ctx
  ctx=$(command docker context show 2>/dev/null) || return 0
  [[ -n "$ctx" ]] && print -n " %F{cyan}docker:$ctx%f"
}

_prompt_kube() {
  (( PROMPT_SHOW_KUBE )) || return 0
  command -v kubectl >/dev/null 2>&1 || return 0
  local ctx
  ctx=$(command kubectl config current-context 2>/dev/null) || return 0
  [[ -n "$ctx" ]] && print -n " %F{blue}k8s:$ctx%f"
}

precmd() {
  local last_status=$?
  PROMPT="%F{green}%~%f$(_prompt_git)$(_prompt_docker)$(_prompt_kube)$(_prompt_exit "$last_status")"$'\n'"%F{green}❯%f "
}
