#!/bin/sh
# Usage: sessions-in-dir.sh DIR
# Print the ID of each Rex session with a terminal whose foreground program
# is in DIR (or below it), one per line. Shared by open-session.sh and
# worktree-delete-picker.sh.

dir=$1

rex ls --json | jq -r '.sessions[].session_id' | while read -r s; do
  rex api call -s "$s" session.view |
    jq -r '[.. | objects | select(has("block_id")) | .block_id] | unique | .[]' |
    while read -r b; do
      # -b, not block_id=, which rex do ignores in favour of the focused pane.
      cwd=$(rex do -s "$s" -b "$b" com.superlogical.terminal.process 2>/dev/null |
        jq -r '.foreground.cwd // empty')
      case "$cwd" in
        ("$dir" | "$dir"/*) echo "$s"; break ;;
      esac
    done
done
