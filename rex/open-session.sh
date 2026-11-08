#!/bin/sh
# Usage: open-session.sh LABEL DIR [SETUP]
# Show the Rex session labelled LABEL, creating it in DIR if needed.
# When the session is created, SETUP (a shell command line) is typed into
# its terminal, so it runs where you can watch it.
# Shared by project-picker.sh, worktree-picker.sh and ticket-picker.sh.

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

if [ -z "$id" ]; then
  id=$(rex new "$name" --cwd "$dir" --json | jq -r '.session_id')
  [ -n "$id" ] || fail "Couldn't create session $name."
  if [ -n "$setup" ]; then
    printf '%s\n' "$setup" | rex send -s "$id" || fail "Couldn't start setup in $name."
  fi
fi

rex do session.select session_id="$id" || fail "Couldn't switch to session $name."
