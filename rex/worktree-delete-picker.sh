#!/bin/sh
# Pick an informed365 worktree (~/Code/worktrees/informed365/*) with fzf and
# delete it, after a confirmation, along with its Rex sessions and Herd site.
# Run by the delete_worktree action in init.lua, inside a floating pane.
#
# A worktree's sessions are the one labelled informed365/WORKTREE and any
# with a terminal in the worktree (see sessions-in-dir.sh). Its Herd site is
# any link in Herd's Sites directory pointing at it (made by `php artisan
# worktree:setup`), which is unlinked and has its certificate removed. Its
# APP_URL is removed from 1Password, where run-i365 adds it.
#
# The branch is kept, so the worktree can be made again from it. Uncommitted
# changes are discarded, but the confirmation says so first.
#
# If the session you opened the picker from is one of them, it's killed
# last, which closes the picker too.

repo="$HOME/Code/informed365"
project=$(basename "$repo")
worktrees="$HOME/Code/worktrees/$project"
here=$(dirname "$0")
herd_config="$HOME/Library/Application Support/Herd/config/valet"

fail() {
  printf '\n%s\nPress Enter to close.' "$1"
  read -r _
  exit 1
}

cd "$repo" || fail "No checkout at $repo."

# NAME<TAB>BRANCH<TAB>PATH for each worktree under $worktrees, most recently
# opened first (see recent-sessions.sh).
list=$(git worktree list --porcelain | awk -v wt="$worktrees/" '
  /^worktree / { path = substr($0, 10); branch = "(detached)" }
  /^branch /   { branch = substr($0, 19) }
  /^$/         { if (index(path, wt) == 1) print path "\t" branch }
  END          { if (index(path, wt) == 1) print path "\t" branch }')
[ -n "$list" ] || fail "No worktrees of $project in $worktrees."

selected=$(printf '%s\n' "$list" | cut -f1 |
  "$here/recent-sessions.sh" sort "$project" |
  while read -r p; do
    printf '%s\t%s\t%s\n' "$(basename "$p")" \
      "$(printf '%s\n' "$list" | awk -F'\t' -v p="$p" '$1 == p { print $2 }')" "$p"
  done |
  fzf --prompt="delete $project worktree> " --delimiter='\t' --with-nth=1,2 \
    --tabstop=2 --reverse) || exit 0

name=$(printf '%s' "$selected" | cut -f1)
branch=$(printf '%s' "$selected" | cut -f2)
dir=$(printf '%s' "$selected" | cut -f3)

printf 'Finding sessions…'
sessions=$(
  {
    rex ls --json | jq -r --arg n "$project/$name" \
      '.sessions[] | select((.label | ascii_downcase) == ($n | ascii_downcase)) | .session_id'
    "$here/sessions-in-dir.sh" "$dir"
  } | sort -u
)
labels=$(rex ls --json | jq -r --arg ids "$sessions" \
  '($ids | split("\n")) as $ids | .sessions[] | select(.session_id | IN($ids[])) | .label')
printf '\r\033[K'

# Herd sites linked to this worktree.
sites=$(find "$herd_config/Sites" -mindepth 1 -maxdepth 1 -type l 2>/dev/null |
  while read -r link; do
    [ "$(readlink "$link")" = "$dir" ] && basename "$link"
  done)

changes=$(git -C "$dir" status --porcelain 2>/dev/null | grep -c .)

# The URL run-i365 added to 1Password, read the same way it does.
url=$(sed -n 's/^APP_URL=//p' "$dir/.env" 2>/dev/null | tr -d "\"'" | head -n 1)

header=$(
  echo "Delete $name?"
  echo "  branch $branch is kept"
  [ "$changes" -gt 0 ] && echo "  $changes uncommitted change(s) will be LOST"
  printf '%s\n' "$labels" | sed '/^$/d; s/^/  kill session: /'
  printf '%s\n' "$sites" | sed '/^$/d; s/^/  unlink Herd site: /'
  [ -n "$url" ] && echo "  remove $url from 1Password, if it's there"
)
answer=$(printf 'No\nYes, delete it\n' |
  fzf --prompt='confirm> ' --header="$header" --header-first --reverse) || exit 0
[ "$answer" = "Yes, delete it" ] || exit 0

# Kill the other sessions first, so nothing is left running in the worktree.
# The one the picker is running in waits until the end.
current=
for s in $sessions; do
  if [ "$s" = "$REX_SESSION" ]; then
    current=$s
  else
    rex kill "$s" || fail "Couldn't kill session $s."
  fi
done

tld=$(jq -r '.tld // empty' "$herd_config/config.json" 2>/dev/null)
tld=${tld:-test}
for site in $sites; do
  if [ -e "$herd_config/Certificates/$site.$tld.crt" ]; then
    herd unsecure "$site" || fail "Couldn't remove the certificate for $site.$tld."
  fi
  herd unlink "$site" || fail "Couldn't unlink the Herd site $site."
done

# _i365_1password_remove_url (shell/.functions) needs an interactive zsh for
# it and I365_1PASSWORD_ITEM. A failure here shouldn't stop the deletion.
if [ -n "$url" ]; then
  zsh -ic '_i365_1password_remove_url "$1"' zsh "$url" || {
    printf '1Password: couldn'\''t remove %s. Press Enter to carry on.' "$url"
    read -r _
  }
fi

echo "Removing $dir…"
git worktree remove --force "$dir" || fail "Couldn't remove the worktree $dir."

[ -n "$current" ] && exec rex kill "$current"
exit 0
