#!/bin/sh
# Usage: worktree-picker.sh [CWD] [SESSION_LABEL]
# Pick a worktree of the current project from ~/Code/worktrees/PROJECT/*
# with fzf, then show its Rex session, labelled PROJECT/WORKTREE, creating
# it if needed. Run by the worktree_picker action in init.lua.
#
# The project comes from CWD (the directory of the pane the picker was
# opened from), whether it's the main checkout (~/Code/PROJECT/...) or a
# worktree (~/Code/worktrees/PROJECT/WORKTREE/...). If that doesn't name a
# project with worktrees, the session label is used, up to its first "/".

code="$HOME/Code"
worktrees="$code/worktrees"
cwd=$1
label=$2

project_from_cwd() {
  case "$1" in
    "$worktrees") return ;;
    "$worktrees"/*) p=${1#"$worktrees"/} ;;
    "$code"/*) p=${1#"$code"/} ;;
    *) return ;;
  esac
  echo "${p%%/*}"
}

project=$(project_from_cwd "$cwd")
if [ -z "$project" ] || [ ! -d "$worktrees/$project" ]; then
  project=${label%%/*}
fi

if [ -z "$project" ] || [ ! -d "$worktrees/$project" ]; then
  printf 'No worktrees found for this session (looked in %s).\nPress Enter to close.' \
    "$worktrees/${project:-?}"
  read -r _
  exit 1
fi

dir=$(find "$worktrees/$project" -mindepth 1 -maxdepth 1 -type d ! -name '.*' |
  sort -f |
  fzf --prompt="$project worktree> " --delimiter=/ --with-nth=-2.. --reverse) || exit 0

exec "$(dirname "$0")/open-session.sh" "$project/$(basename "$dir")" "$dir"
