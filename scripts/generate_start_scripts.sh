#!/usr/bin/env bash
set -euo pipefail

print_usage() {
  echo "Usage: $0 --session NAME --output PATH --repo name=path [--repo name=path ...]"
  echo ""
  echo "Options:"
  echo "  --session    Name of the tmux session to create"
  echo "  --output     Directory where the start script will be written"
  echo "  --repo       Repo mapping in the form name=path (can be repeated)"
  exit 1
}

SESSION_NAME=""
OUTPUT_PATH=""
REPOS=()

# Parse named arguments
while [[ $# -gt 0 ]]; do
  case "${1:-}" in
  --session)
    SESSION_NAME="${2:-}"
    shift 2
    ;;
  --output)
    OUTPUT_PATH="${2:-}"
    shift 2
    ;;
  --repo)
    REPOS+=("${2:-}")
    shift 2
    ;;
  *)
    echo "❌ Unknown argument: ${1:-}"
    print_usage
    ;;
  esac
done

if [[ -z "$SESSION_NAME" || -z "$OUTPUT_PATH" || ${#REPOS[@]} -eq 0 ]]; then
  echo "❌ Missing required arguments"
  print_usage
fi

OUTPUT_PATH="${OUTPUT_PATH%/}"
SCRIPT_BASENAME="$(echo "$SESSION_NAME" | tr '[:upper:]' '[:lower:]' | tr ' ' '_')"
SCRIPT_PATH="$OUTPUT_PATH/${SCRIPT_BASENAME}_start_session.sh"

cat >"$SCRIPT_PATH" <<EOF
#!/usr/bin/env bash
set -euo pipefail

SESSION="${SESSION_NAME}"
new_session=true

if [[ "\${1:-}" == "--add" ]]; then
    new_session=false
    SESSION=\$(tmux display-message -p '#S')
fi

if \$new_session; then
    if tmux has-session -t "\$SESSION" 2>/dev/null; then
        echo "ℹ️ Session '\$SESSION' already exists. Attaching..."
        exec tmux attach -t "\$SESSION"
    fi
    tmux new-session -d -s "\$SESSION" -c "${REPOS[0]#*=}" -n "nvim: ${REPOS[0]%%=*}" "nvim ."
else
    tmux new-window -d -t "\$SESSION" -c "${REPOS[0]#*=}" -n "nvim: ${REPOS[0]%%=*}" "nvim ."
fi

tmux new-window -t "\$SESSION" -c "${REPOS[0]#*=}" -n "shell: ${REPOS[0]%%=*}"
EOF

for repo in "${REPOS[@]:1}"; do
  name="${repo%%=*}"
  path="${repo#*=}"
  cat >>"$SCRIPT_PATH" <<EOF
tmux new-window -t "\$SESSION" -c "$path" -n "nvim: $name" "nvim ."
tmux new-window -t "\$SESSION" -c "$path" -n "shell: $name"
EOF
done

cat >>"$SCRIPT_PATH" <<'EOF'

if $new_session; then
    tmux attach -t "$SESSION"
fi
EOF

chmod +x "$SCRIPT_PATH"
echo "✅ Generated: $SCRIPT_PATH"
