#!/bin/sh
# Usage: open-session.sh LABEL DIR [SETUP]
# Show the Rex session labelled LABEL, creating it in DIR if needed.
# When the session is created, SETUP (a shell command line) is typed into
# its terminal, so it runs where you can watch it.
# Shared by project-picker.sh, worktree-picker.sh and ticket-picker.sh.
#
# Each switch is logged to recent-sessions.sh's file, since Rex doesn't
# record when a session was last shown. The worktree picker sorts by it.

name=$1
dir=$2
setup=$3

fail() {
  # The picker runs in a floating pane that closes when this exits,
  # so wait long enough for the error to be read.
  printf '\n%s\nPress Enter to close.' "$1"
  read -r _
  exit 1
}

# Labels match case-insensitively, the same way rex targets do.
id=$(rex ls --json | jq -r --arg n "$name" \
  '.sessions[] | select((.label | ascii_downcase) == ($n | ascii_downcase)) | .session_id' |
  head -n 1)

# Otherwise reuse a session with a terminal already in DIR (or below it),
# whatever it's called, so a session made some other way isn't duplicated.
if [ -z "$id" ]; then
  id=$(rex ls --json | jq -r '.sessions[].session_id' | while read -r s; do
    rex api call -s "$s" session.view |
      jq -r '[.. | objects | select(has("block_id")) | .block_id] | unique | .[]' |
      while read -r b; do
        # -b, not block_id=, which rex do ignores in favour of the focused pane.
        cwd=$(rex do -s "$s" -b "$b" com.superlogical.terminal.process 2>/dev/null |
          jq -r '.foreground.cwd // empty')
        case "$cwd" in
          ("$dir" | "$dir"/*) echo "$s" ;;
        esac
      done
  done | head -n 1)
fi

if [ -z "$id" ]; then
  id=$(rex new "$name" --cwd "$dir" --json | jq -r '.session_id')
  [ -n "$id" ] || fail "Couldn't create session $name."
  if [ -n "$setup" ]; then
    printf '%s\n' "$setup" | rex send -s "$id" || fail "Couldn't start setup in $name."
  fi
fi

# A session whose tabs have all been closed shows nothing, so give it one.
if [ "$(rex session inspect "$id" --json | jq '.windows | length')" = 0 ]; then
  rex window new -s "$id" -c "$dir" >/dev/null || fail "Couldn't open a tab in $name."
fi

rex do session.select session_id="$id" || fail "Couldn't switch to session $name."
"$(dirname "$0")/recent-sessions.sh" touch "$name"
