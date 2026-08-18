#!/usr/bin/env bash
set -euo pipefail

source "$(dirname "$0")/constants.sh"

MERGE="$SCRIPT_DIR/lib/vscode_merge.mjs"
LOCAL_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/personal_setup/vscode"

usage() {
  cat <<EOF
Usage: $(basename "$0") [sync|status|forget <key>|target]

  sync            capture this machine's changes into the local overlay, then
                  regenerate settings.json/keybindings.json from baseline+overlay
  status          show which keys the local overlay is shadowing, and how the
                  installed extensions compare to the lists
  forget <key>    drop a key from the local overlay so the baseline applies again
  target          print the resolved VS Code User directory

Set VSCODE_USER_DIR to override target detection.
EOF
  exit 1
}

resolve_user_dir() {
  if [[ -n "${VSCODE_USER_DIR:-}" ]]; then
    echo "$VSCODE_USER_DIR"
    return
  fi

  case "$(uname -s)" in
  Darwin)
    echo "$HOME/Library/Application Support/Code/User"
    ;;
  MINGW* | MSYS* | CYGWIN*)
    echo "${APPDATA:-$HOME/AppData/Roaming}/Code/User"
    ;;
  *)
    if [[ -d "$HOME/.config/Code/User" ]]; then
      echo "$HOME/.config/Code/User"
    elif grep -qi microsoft /proc/version 2>/dev/null && command -v wslpath >/dev/null 2>&1; then
      local appdata
      appdata=$(powershell.exe -NoProfile -NonInteractive -Command 'Write-Output $env:APPDATA' 2>/dev/null | tr -d '\r')
      if [[ -z "$appdata" ]]; then
        echo "❌ Could not resolve APPDATA from Windows. Set VSCODE_USER_DIR." >&2
        exit 1
      fi
      echo "$(wslpath "$appdata")/Code/User"
    else
      echo "$HOME/.config/Code/User"
    fi
    ;;
  esac
}

# Strips comments and blank lines. Trailing `|| true` keeps an empty result from
# tripping pipefail, since the local list is optional.
normalize_list() {
  sed 's/#.*//' | tr -d ' \r' | tr '[:upper:]' '[:lower:]' | grep -v '^$' | sort -u || true
}

baseline_extensions() {
  normalize_list <"$REPO_DIR/code/extensions.txt"
}

local_extensions() {
  [[ -f "$LOCAL_DIR/extensions.local.txt" ]] || return 0
  normalize_list <"$LOCAL_DIR/extensions.local.txt"
}

installed_extensions() {
  code --list-extensions 2>/dev/null | normalize_list
}

cmd_sync() {
  local user_dir
  user_dir=$(resolve_user_dir)
  mkdir -p "$user_dir" "$LOCAL_DIR"

  for pair in "settings:settings.json" "keybindings:keybindings.json"; do
    local name="${pair%%:*}" file="${pair##*:}"
    local snapshot="$LOCAL_DIR/.$name.snapshot.json"

    # Without a snapshot there is no common ancestor, so the live file cannot be
    # attributed to this machine. Keep a copy rather than silently discarding it.
    if [[ -f "$user_dir/$file" && ! -f "$snapshot" ]]; then
      cp "$user_dir/$file" "$user_dir/$file.pre-sync"
      echo "ℹ️  No snapshot yet; previous $file saved as $file.pre-sync"
    fi

    local captured
    captured=$(node "$MERGE" "sync-$name" \
      "base=$REPO_DIR/code/$name.base.jsonc" \
      "local=$LOCAL_DIR/$name.local.json" \
      "snapshot=$snapshot" \
      "live=$user_dir/$file")

    if [[ -n "$captured" ]]; then
      echo "📥 Captured into the $name overlay:"
      echo "$captured" | sed 's/^/    /'
    fi
  done

  echo "✅ Wrote settings.json and keybindings.json to $user_dir"

  if command -v code >/dev/null 2>&1; then
    local missing count=0
    missing=$(comm -23 <( (baseline_extensions; local_extensions) | sort -u) <(installed_extensions))
    while read -r ext; do
      [[ -z "$ext" ]] && continue
      count=$((count + 1))
      echo "⬇️  Installing $ext"
      code --install-extension "$ext" --force >/dev/null 2>&1 ||
        echo "⚠️  Failed to install $ext"
    done <<<"$missing"
    echo "✅ Extensions up to date ($count installed)"
  else
    echo "⚠️  'code' not on PATH, skipping extensions."
  fi
}

cmd_status() {
  local user_dir
  user_dir=$(resolve_user_dir)
  echo "Target: $user_dir"
  echo "Overlay: $LOCAL_DIR"
  echo

  for name in settings keybindings; do
    if [[ -f "$LOCAL_DIR/$name.local.json" ]]; then
      echo "── $name overrides ──"
      node "$MERGE" status \
        "base=$REPO_DIR/code/$name.base.jsonc" \
        "local=$LOCAL_DIR/$name.local.json" |
        node -e '
          const rows = JSON.parse(require("fs").readFileSync(0, "utf8"));
          if (!rows.length) console.log("  (none)");
          for (const r of rows) {
            console.log(`  ${r.shadowing ? "⚠ " : "+ "}${r.key}`);
            console.log(`      local:    ${r.local}`);
            console.log(`      baseline: ${r.base}`);
          }
        '
      echo
    fi
  done

  if command -v code >/dev/null 2>&1; then
    echo "── extensions ──"
    local installed baseline local_list
    installed=$(installed_extensions)
    baseline=$(baseline_extensions)
    local_list=$(local_extensions)

    echo "  from baseline, missing here:"
    comm -23 <(echo "$baseline") <(echo "$installed") | grep . | sed 's/^/    - /' || echo "    (none)"
    echo "  from local list:"
    echo "$local_list" | grep . | sed 's/^/    + /' || echo "    (none)"
    echo "  installed but on neither list:"
    comm -23 <(echo "$installed") <( (echo "$baseline"; echo "$local_list") | grep . | sort -u) |
      grep . | sed 's/^/    ? /' || echo "    (none)"
  fi
}

cmd_forget() {
  local key="${1:-}"
  [[ -z "$key" ]] && usage

  for name in settings keybindings; do
    local overlay="$LOCAL_DIR/$name.local.json"
    [[ -f "$overlay" ]] || continue
    if node "$MERGE" forget "local=$overlay" "key=$key"; then
      echo "🗑️  Removed '$key' from $name overlay. Run 'sync' to apply the baseline."
      return
    fi
  done
  echo "'$key' is not in the local overlay."
}

case "${1:-sync}" in
sync) cmd_sync ;;
status) cmd_status ;;
forget) cmd_forget "${2:-}" ;;
target) resolve_user_dir ;;
*) usage ;;
esac
