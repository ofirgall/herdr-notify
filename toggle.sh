#!/usr/bin/env bash
# Action: watch the focused pane, or cancel its watch if already watched.
. "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib.sh"
pane="${HERDR_PANE_ID:-}"
hn_valid_pane "$pane" || exit 0
if [ -f "$(hn_sentinel "$pane")" ]; then
  exec bash "$HN_ROOT/cancel.sh"
else
  exec bash "$HN_ROOT/watch.sh"
fi
