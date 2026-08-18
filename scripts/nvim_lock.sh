#!/usr/bin/env bash
set -euo pipefail

source "$(dirname "$0")/constants.sh"

LIVE="${XDG_DATA_HOME:-$HOME/.local/share}/nvim/lazy-lock.json"
KNOWN_GOOD="$REPO_DIR/nvim/lazy-lock.known-good.json"

usage() {
  cat <<EOF
Usage: $(basename "$0") [save|restore]

  save     copy the live lockfile over the known good one, for you to commit
           once you have actually used the current plugin versions for a while
  restore  put the known good lockfile back and check the plugins out at those
           commits, for when an update breaks nvim

Plugin updates are never tracked: the live lockfile is $LIVE,
outside the repo. Nothing forces you to run save.
EOF
  exit 1
}

# Unique plugin names differing either way, so a removal counts and a changed
# commit counts once rather than twice.
changed_count() {
  local a="$1" b="$2"
  [[ -f "$a" ]] || a=/dev/null
  [[ -f "$b" ]] || b=/dev/null
  { diff <(sort "$a") <(sort "$b") 2>/dev/null || true; } |
    grep -oE '^[<>] +"[^"]+"' | sed 's/^[<>] *//' | sort -u | wc -l || true
}

cmd_save() {
  if [[ ! -f "$LIVE" ]]; then
    echo "❌ No live lockfile at $LIVE. Start nvim once to create it." >&2
    exit 1
  fi

  if [[ -f "$KNOWN_GOOD" ]] && cmp -s "$LIVE" "$KNOWN_GOOD"; then
    echo "✅ Known good is already identical to the live lockfile."
    return 0
  fi

  local n
  n=$(changed_count "${KNOWN_GOOD:-/dev/null}" "$LIVE")
  cp "$LIVE" "$KNOWN_GOOD"
  echo "✅ Saved $n changed plugin(s) to $KNOWN_GOOD"
  echo "   Commit it to make this the state you can fall back to."
}

cmd_restore() {
  if [[ ! -f "$KNOWN_GOOD" ]]; then
    echo "❌ No known good lockfile at $KNOWN_GOOD." >&2
    exit 1
  fi

  if [[ -f "$LIVE" ]]; then
    if cmp -s "$LIVE" "$KNOWN_GOOD"; then
      echo "ℹ️  Live lockfile already matches the known good one."
    else
      echo "↩️  Rolling back $(changed_count "$LIVE" "$KNOWN_GOOD") plugin(s)."
    fi
    # In case the rollback is the actual mistake.
    cp "$LIVE" "$LIVE.before-restore"
  fi

  mkdir -p "$(dirname "$LIVE")"
  cp "$KNOWN_GOOD" "$LIVE"
  nvim --headless '+Lazy! restore' +qall
  echo "✅ Plugins checked out at the known good commits."
}

case "${1:-}" in
save) cmd_save ;;
restore) cmd_restore ;;
*) usage ;;
esac
