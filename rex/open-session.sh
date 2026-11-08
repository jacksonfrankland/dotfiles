#!/bin/sh
# Usage: open-session.sh LABEL DIR
# Show the Rex session labelled LABEL, creating it in DIR if needed.
# Shared by project-picker.sh and worktree-picker.sh.

name=$1
dir=$2

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
fi

rex do session.select session_id="$id" || fail "Couldn't switch to session $name."
