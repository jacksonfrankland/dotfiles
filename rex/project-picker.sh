#!/bin/sh
# Pick a project from ~/Code with fzf, then show its Rex session,
# creating the session (labelled after the directory) if needed.
# Run by the project_picker action in init.lua, inside a floating pane.

dir=$(find "$HOME/Code" -mindepth 1 -maxdepth 1 -type d ! -name '.*' |
  sort -f |
  fzf --prompt='project> ' --delimiter=/ --with-nth=-1 --reverse) || exit 0

exec "$(dirname "$0")/open-session.sh" "$(basename "$dir")" "$dir"
