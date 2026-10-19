# Shared helpers for herdr-notify (bash 3.2 compatible).
HN_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HN_STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/herdr-notify"
HERDR="${HERDR_BIN_PATH:-herdr}"
HN_SOURCE="plugin:herdr-notify"   # same convention as other plugins
HN_TOKEN="notify"
HN_GLYPH=""   # sidebar glyph for a watched pane/workspace

hn_sentinel() { printf '%s/%s.watch' "$HN_STATE_DIR" "$1"; }

# Sentinel file names are pane ids; refuse anything with a slash.
hn_valid_pane() { [ -n "$1" ] && case "$1" in */*) return 1 ;; esac; }

# Workspace id of a pane, from `herdr pane get` (jq, else sed).
hn_ws_of() {
  local json
  json="$("$HERDR" pane get "$1" 2>/dev/null)" || return 0
  if command -v jq >/dev/null 2>&1; then
    printf '%s' "$json" | jq -r '.result.pane.workspace_id // empty'
  else
    printf '%s' "$json" | sed -n 's/.*"workspace_id"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p'
  fi
}

# Workspace id recorded in a pane's sentinel (empty if none).
hn_sentinel_ws() { [ -f "$(hn_sentinel "$1")" ] && head -n1 "$(hn_sentinel "$1")"; }

# The pane token shows in agent rows; the workspace token is what
# [ui.sidebar.spaces] rows render, so set both.
hn_set_token() {
  "$HERDR" pane report-metadata "$1" --source "$HN_SOURCE" --token "$HN_TOKEN=$HN_GLYPH" >/dev/null 2>&1
  [ -n "${2:-}" ] && "$HERDR" workspace report-metadata "$2" --source "$HN_SOURCE" --token "$HN_TOKEN=$HN_GLYPH" >/dev/null 2>&1
  return 0
}

# Clear the pane token, and the workspace token once no other watched pane in
# that workspace remains. Call after the pane's sentinel is removed.
hn_clear_token() {
  "$HERDR" pane report-metadata "$1" --source "$HN_SOURCE" --clear-token "$HN_TOKEN" >/dev/null 2>&1
  [ -n "${2:-}" ] || return 0
  grep -qxF "$2" "$HN_STATE_DIR"/*.watch 2>/dev/null && return 0
  "$HERDR" workspace report-metadata "$2" --source "$HN_SOURCE" --clear-token "$HN_TOKEN" >/dev/null 2>&1
  return 0
}

# (Re)create the stable symlink the user's zshrc sources.
hn_link_hook() {
  mkdir -p "$HN_STATE_DIR"
  ln -sfn "$HN_ROOT/shell/herdr-notify.zsh" "$HN_STATE_DIR/hook.zsh"
}
