# Shared helpers for herdr-notify (bash 3.2 compatible).
HN_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HN_STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/herdr-notify"
HERDR="${HERDR_BIN_PATH:-herdr}"
HN_SOURCE="herdr-notify"
HN_TOKEN="notify"

hn_sentinel() { printf '%s/%s.watch' "$HN_STATE_DIR" "$1"; }

# Sentinel file names are pane ids; refuse anything with a slash.
hn_valid_pane() { [ -n "$1" ] && case "$1" in */*) return 1 ;; esac; }

hn_set_token() {
  "$HERDR" pane report-metadata "$1" --source "$HN_SOURCE" --token "$HN_TOKEN=⏳" >/dev/null 2>&1
}

hn_clear_token() {
  "$HERDR" pane report-metadata "$1" --source "$HN_SOURCE" --clear-token "$HN_TOKEN" >/dev/null 2>&1
}

# (Re)create the stable symlink the user's zshrc sources.
hn_link_hook() {
  mkdir -p "$HN_STATE_DIR"
  ln -sfn "$HN_ROOT/shell/herdr-notify.zsh" "$HN_STATE_DIR/hook.zsh"
}
