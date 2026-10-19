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
- `pane.closed` / `pane.exited` remove stale watches.

Bind them in herdr's config as `type = "plugin_action"` and add `{token = "$notify"}`
to a sidebar row.

## zsh hook

The plugin's startup (and `watch`) symlinks the hook to a stable path. In `.zshrc`:

```zsh
[[ -n $HERDR_PANE_ID && -f ${XDG_STATE_HOME:-$HOME/.local/state}/herdr-notify/hook.zsh ]] \
  && source ${XDG_STATE_HOME:-$HOME/.local/state}/herdr-notify/hook.zsh
```

State lives in `${XDG_STATE_HOME:-$HOME/.local/state}/herdr-notify/<pane_id>.watch`.
Requires `jq` for workspace/tab labels (falls back to `herdr|<pane id>`).
