# herdr-notify zsh hook. Source via the stable symlink created by the plugin:
#   [[ -n $HERDR_PANE_ID && -f ${XDG_STATE_HOME:-$HOME/.local/state}/herdr-notify/hook.zsh ]] && source ...
# Per prompt cost: one [[ -f ]]. No-op outside herdr.

[[ -n ${HERDR_PANE_ID:-} ]] || return 0

# Resolve the plugin root through the symlink.
_hn_self="${${(%):-%x}:A}"
_hn_notify="${_hn_self:h:h}/notify.sh"
_hn_state="${XDG_STATE_HOME:-$HOME/.local/state}/herdr-notify"
unset _hn_self
_hn_cmd=""

_hn_preexec() { _hn_cmd="$1" }

_hn_precmd() {
  local _exit=$?
  local _c="$_hn_cmd"
  _hn_cmd=""
  # Only after a recorded command, and only if the pane is watched.
  [[ -n $_c && -f "$_hn_state/$HERDR_PANE_ID.watch" ]] || return 0
  "$_hn_notify" "$_exit" "$_c" &!
}

autoload -Uz add-zsh-hook
add-zsh-hook preexec _hn_preexec
add-zsh-hook precmd _hn_precmd
