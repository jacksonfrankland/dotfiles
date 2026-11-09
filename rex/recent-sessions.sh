#!/bin/sh
# Usage: recent-sessions.sh touch LABEL
#        recent-sessions.sh sort PROJECT [CURRENT_LABEL] < DIRS
# Rex doesn't say when a session was last shown, so open-session.sh logs
# each switch here, as "EPOCH<tab>LABEL" lines (only switches made through
# the pickers are seen).
#
# sort reads worktree directories (one per line), whose sessions are
# labelled PROJECT/BASENAME, and prints them most recently opened first,
# then the rest alphabetically. CURRENT_LABEL's worktree goes last.

log="${XDG_STATE_HOME:-$HOME/.local/state}/rex/recent-sessions"

case "$1" in
  touch)
    mkdir -p "$(dirname "$log")"
    # Keep only the latest line per label, so the file stays small.
    {
      [ -f "$log" ] && awk -F '\t' -v l="$2" 'tolower($2) != tolower(l)' "$log"
      printf '%s\t%s\n' "$(date +%s)" "$2"
    } > "$log.tmp" && mv "$log.tmp" "$log"
    ;;
  sort)
    awk -F '\t' -v project="$2" -v current="$3" '
      FILENAME != "-" { seen[tolower($2)] = $1; next }
      {
        n = split($0, parts, "/")
        label = tolower(project "/" parts[n])
        if (label == tolower(current)) ts = -1
        else ts = (label in seen) ? seen[label] : 0
        printf "%s\t%s\t%s\n", ts, tolower(parts[n]), $0
      }
    ' "$( [ -f "$log" ] && echo "$log" || echo /dev/null )" - |
      sort -t "$(printf '\t')" -k1,1nr -k2,2 |
      cut -f 3-
    ;;
  *)
    echo "usage: $0 touch LABEL | sort PROJECT [CURRENT_LABEL]" >&2
    exit 2
    ;;
esac
