#!/usr/bin/env bash
# Usage: notify.sh <exit_status> <command>   (pane from $HERDR_PANE_ID)
. "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib.sh"
status="${1:-?}"
cmd="${2-}"
pane="${HERDR_PANE_ID:-}"
hn_valid_pane "$pane" || exit 0

# Remove the sentinel up front so a slow notification path can't double-fire.
rm -f "$(hn_sentinel "$pane")"
hn_clear_token "$pane"

ws_label=""
tab_label=""
if command -v jq >/dev/null 2>&1; then
  pjson="$("$HERDR" pane get "$pane" 2>/dev/null)"
  tab_id="$(printf '%s' "$pjson" | jq -r '.result.pane.tab_id // empty')"
  ws_id="$(printf '%s' "$pjson" | jq -r '.result.pane.workspace_id // empty')"
  [ -n "$tab_id" ] && tab_label="$("$HERDR" tab get "$tab_id" 2>/dev/null | jq -r '.result.tab.label // empty')"
  [ -n "$ws_id" ] && ws_label="$("$HERDR" workspace get "$ws_id" 2>/dev/null | jq -r '.result.workspace.label // empty')"
fi
[ -n "$ws_label" ] || ws_label="herdr"
[ -n "$tab_label" ] || tab_label="$pane"
title="$ws_label|$tab_label"
if [ -n "$cmd" ]; then body="$cmd finished (exit $status)"; else body="finished (exit $status)"; fi

# OS notification
case "$(uname -s)" in
  Darwin)
    if command -v notify-macos >/dev/null 2>&1; then
      notify-macos -u critical "$title" "$body" >/dev/null 2>&1
    else
      # pass text as argv, not interpolated into the script
      osascript -e 'on run argv' -e 'display notification (item 2 of argv) with title (item 1 of argv)' -e 'end run' "$title" "$body" >/dev/null 2>&1
    fi ;;
  *)
    command -v notify-send >/dev/null 2>&1 && notify-send -u critical "$title" "$body" >/dev/null 2>&1 ;;
esac

# herdr toast
"$HERDR" notification show "$title" --body "$body" --sound done >/dev/null 2>&1
exit 0
