#!/usr/bin/env bash
# Action: watch the focused pane ($HERDR_PANE_ID).
. "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib.sh"
pane="${HERDR_PANE_ID:-}"
hn_valid_pane "$pane" || exit 0
hn_link_hook
[ -f "$(hn_sentinel "$pane")" ] && exit 0   # already watched
: > "$(hn_sentinel "$pane")"
hn_set_token "$pane"
exit 0
