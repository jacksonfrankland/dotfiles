#!/bin/sh
# Pick an open informed365 Jira ticket that you're assigned to or are the
# code reviewer of, then show its worktree's Rex session, creating the
# worktree and session if needed. Run by the ticket_picker action in
# init.lua, inside a floating pane.
#
# Worktrees follow the jw/jcr naming: ~/Code/worktrees/informed365/
# ps-1234-summary-slug, on branch feature/PS-1234-summary-slug (or hotfix/).
# The directory name is also the Herd site name, so it's capped to fit a
# Herd certificate (64 characters including ".test") at a word boundary.
#
# 1. A worktree that already exists for the ticket is reused as it is.
# 2. Otherwise a branch named after the ticket is checked out, such as the
#    one under review. If there are several, you pick one.
# 3. Otherwise (your own tickets only) a new feature/ or hotfix/ branch is
#    made from a base branch you pick (main by default) and pushed.
# A new session runs `worktree-setup` (composer, `php artisan
# worktree:setup`, npm; see shell/.functions) then `herd secure`.
#
# requires: `acli jira auth login --web` to have been run once

repo="$HOME/Code/informed365"
project=$(basename "$repo")
worktrees="$HOME/Code/worktrees/$project"
here=$(dirname "$0")

fail() {
  printf '\n%s\nPress Enter to close.' "$1"
  read -r _
  exit 1
}

# key<TAB>summary<TAB>status for a JQL query
search() {
  acli jira workitem search --jql "$1" --fields "key,summary,status" --json |
    jq -r '.[] | [(.key // .fields.key), (.summary // .fields.summary), (.fields.status.name // "")] | @tsv'
}

# Cap a slug at MAX characters, cutting at the last "-" within the limit.
cap() {
  s=$1
  max=$2
  if [ ${#s} -gt "$max" ]; then
    s=$(printf '%s' "$s" | cut -c1-$((max + 1)))
    s=${s%-*}
    s=$(printf '%s' "$s" | cut -c1-"$max")
  fi
  printf '%s' "$s" | sed -E 's/-+$//'
}

# Lines on stdin that mention KEY as a whole ticket key (PS-25 not PS-2500).
mentions() {
  grep -iE "(^|[^a-z0-9])$1([^0-9]|$)"
}

printf 'Loading tickets…'
mine=$(search 'assignee = currentUser() AND statusCategory != Done ORDER BY updated DESC') ||
  fail "Couldn't search Jira. Run: acli jira auth login --web"
reviews=$(search '"Code review" = currentUser() AND statusCategory != Done ORDER BY updated DESC') ||
  fail "Couldn't search Jira. Run: acli jira auth login --web"
printf '\r\033[K'

# One line per ticket: key, role, status, summary. A ticket in both lists
# is listed once, as "assigned+review".
tickets=$(
  {
    printf '%s\n' "$mine" | awk -F'\t' 'NF { print $1 "\tassigned\t" $3 "\t" $2 }'
    printf '%s\n' "$reviews" | awk -F'\t' 'NF { print $1 "\treview\t" $3 "\t" $2 }'
  } | awk -F'\t' -v OFS='\t' '
    !($1 in role) { order[++n] = $1; status[$1] = $3; summary[$1] = $4; role[$1] = $2; next }
    { role[$1] = role[$1] "+" $2 }
    END {
      # Pad role and status so the columns line up in fzf.
      for (i = 1; i <= n; i++) {
        k = order[i]
        if (length(role[k]) > rw) rw = length(role[k])
        if (length(status[k]) > sw) sw = length(status[k])
      }
      for (i = 1; i <= n; i++) {
        k = order[i]
        print k, sprintf("%-" rw "s", role[k]), sprintf("%-" sw "s", status[k]), summary[k]
      }
    }'
)
[ -n "$tickets" ] || fail "No open tickets are assigned to you or waiting on your review."

selected=$(printf '%s\n' "$tickets" |
  fzf --prompt='ticket> ' --delimiter='\t' --tabstop=2 --reverse) || exit 0

key=$(printf '%s' "$selected" | cut -f1)
role=$(printf '%s' "$selected" | cut -f2)
summary=$(printf '%s' "$selected" | cut -f4-)
lkey=$(printf '%s' "$key" | tr '[:upper:]' '[:lower:]')

cd "$repo" || fail "No checkout at $repo."

# 1. A worktree that already exists for this ticket, by directory or branch.
existing=$(git worktree list --porcelain | awk -v wt="$worktrees/" '
  /^worktree / { path = substr($0, 10) }
  /^branch /   { if (index(path, wt) == 1) print path "\t" substr($0, 19) }' |
  while IFS="$(printf '\t')" read -r wt_path wt_branch; do
    # The leading "(" lets bash 3.2's sh parse a case inside $( ).
    case "$(basename "$wt_path")" in
      ("$lkey" | "$lkey"-*) echo "$wt_path" ;;
      (*) printf '%s\n' "$wt_branch" | mentions "$key" >/dev/null && echo "$wt_path" ;;
    esac
  done | head -n 1)

if [ -n "$existing" ]; then
  exec "$here/open-session.sh" "$project/$(basename "$existing")" "$existing"
fi

# The directory: ps-1234-summary-slug, short enough for a Herd certificate.
tld=$(jq -r '.tld // empty' "$HOME/Library/Application Support/Herd/config/valet/config.json" 2>/dev/null)
tld=${tld:-test}
slug="$key-$(printf '%s' "$summary" | tr '[:upper:]' '[:lower:]' | sed -E 's/[^a-z0-9]+/-/g; s/^-+|-+$//g')"
name=$(cap "$(printf '%s' "$slug" | tr '[:upper:]' '[:lower:]')" $((64 - 1 - ${#tld})))
dir="$worktrees/$name"
[ -e "$dir" ] && fail "$dir already exists but isn't a worktree of $project."

echo "Fetching origin…"
git fetch --prune origin || fail "git fetch failed."

# 2. Branches named after the ticket, local or on origin.
branches=$(git for-each-ref --format='%(refname:lstrip=2)' refs/heads refs/remotes/origin |
  sed 's|^origin/||' | grep -vx HEAD | mentions "$key" | sort -u)
count=$(printf '%s' "$branches" | grep -c .)
branch=

if [ "$count" -eq 1 ]; then
  branch=$branches
elif [ "$count" -gt 1 ]; then
  branch=$(printf '%s\n' "$branches" | fzf --prompt="$key branch> " --reverse) || exit 0
fi

mkdir -p "$worktrees"

if [ -n "$branch" ]; then
  # Checks out the local branch, or makes one tracking origin's.
  git worktree add "$dir" "$branch" || fail "Couldn't create the worktree on $branch."
else
  # 3. A new branch, for your own tickets only.
  case "$role" in
    *assigned*) ;;
    *) fail "No branch mentions $key yet, so there's nothing to review." ;;
  esac
  type=$(printf 'feature\nhotfix\n' | fzf --prompt='type> ' --reverse) || exit 0
  # The base branch: any of origin's, with main (origin's default) listed
  # first so Enter picks it.
  default=$(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's|^refs/remotes/origin/||')
  default=${default:-main}
  base=$(
    {
      echo "$default"
      git for-each-ref --sort=-committerdate --format='%(refname:lstrip=3)' refs/remotes/origin |
        grep -vx -e HEAD -e "$default"
    } | fzf --prompt='base> ' --header="Enter for $default" --reverse
  ) || exit 0
  branch="$type/$slug"
  git worktree add -b "$branch" "$dir" "origin/$base" ||
    fail "Couldn't create the worktree on a new $branch."
  git -C "$dir" push -u origin HEAD || fail "Created $dir, but couldn't push $branch."
fi

exec "$here/open-session.sh" "$project/$name" "$dir" "worktree-setup && herd secure '$name'"
