# herdr-notify

Herdr plugin: get notified (OS notification + herdr toast) when the current zsh
command in a pane finishes.

Inspired by [tmux-notify](https://github.com/rickstaa/tmux-notify) (its shell-hook mode).


## Usage

- `herdr-notify.watch` marks the focused pane (sidebar token `$notify` shows ⏳).
  The next command that finishes in it fires the notification
  `<workspace>|<tab>` / `<cmd> finished (exit N)`, then the watch clears.
  Watching an idle prompt fires after the *next* command finishes.
- `herdr-notify.cancel` stops watching without notifying.
- `herdr-notify.toggle` watches the pane, or cancels if it is already watched (one key for both).
- `pane.closed` / `pane.exited` remove stale watches.

Bind them in herdr's config as `type = "plugin_action"` and add `{token = "$notify"}`
to a sidebar row. The token is set on both the pane (agent rows) and its
workspace (`[ui.sidebar.spaces]` rows); the workspace token clears once no
watched pane is left in it.

## zsh hook

The plugin's startup (and `watch`) symlinks the hook to a stable path. In `.zshrc`:

```zsh
[[ -n $HERDR_PANE_ID && -f ${XDG_STATE_HOME:-$HOME/.local/state}/herdr-notify/hook.zsh ]] \
  && source ${XDG_STATE_HOME:-$HOME/.local/state}/herdr-notify/hook.zsh
```

State lives in `${XDG_STATE_HOME:-$HOME/.local/state}/herdr-notify/<pane_id>.watch` (contents: the workspace id).
Requires `jq` for workspace/tab labels (falls back to `herdr|<pane id>`).
