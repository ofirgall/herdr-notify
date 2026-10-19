#!/usr/bin/env bash
# cleanup.sh startup : link the zsh hook, remove all stale sentinels
# cleanup.sh event   : remove the sentinel of the pane in HERDR_PLUGIN_EVENT_JSON
. "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib.sh"

if [ "${1:-}" = "startup" ]; then
  hn_link_hook
  for f in "$HN_STATE_DIR"/*.watch; do
    [ -f "$f" ] || continue
    p="$(basename "$f" .watch)"; ws="$(head -n1 "$f")"
    rm -f "$f"
    hn_clear_token "$p" "$ws"
  done
  exit 0
fi

pane=""
json="${HERDR_PLUGIN_EVENT_JSON:-}"
if [ -n "$json" ]; then
  if command -v jq >/dev/null 2>&1; then
    pane="$(printf '%s' "$json" | jq -r '[.. | objects | .pane_id? // empty][0] // empty' 2>/dev/null)"
  else
    pane="$(printf '%s' "$json" | sed -n 's/.*"pane_id"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' | head -n1)"
  fi
fi
[ -n "$pane" ] || pane="${HERDR_PANE_ID:-}"
hn_valid_pane "$pane" || exit 0
ws="$(hn_sentinel_ws "$pane")"
rm -f "$(hn_sentinel "$pane")"
hn_clear_token "$pane" "$ws"
exit 0
