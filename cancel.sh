#!/usr/bin/env bash
# Action: stop watching the focused pane without notifying.
. "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib.sh"
pane="${HERDR_PANE_ID:-}"
hn_valid_pane "$pane" || exit 0
rm -f "$(hn_sentinel "$pane")"
hn_clear_token "$pane"
exit 0
