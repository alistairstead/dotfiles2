#!/usr/bin/env bash
# Fail if a command name is defined in more than one place.
#
# zsh expands abbreviations before it looks up functions, and functions before
# it searches PATH. So an abbr named `gc` silently shadows a `gc()` function,
# which silently shadows ~/.local/bin/gc. Nothing errors; the wrong thing just
# runs. This checks the four namespaces against each other.
#
# Limit: seeded abbrs are checked, but zsh-abbr persists them to
# ~/.config/zsh-abbr/user-abbreviations. An abbr seeded once and later removed
# from .zshrc still lives in that file, and no repo-level check can see it.
# Use `abbr erase <name>` to clear those.

set -uo pipefail

cd "$(dirname "$0")/.." || exit 1

ZSHRC="zsh/.zshrc"
ALIASES="shell/.config/shell/aliases.sh"
FUNCTIONS="shell/.config/shell/functions.sh"
BINDIR="bin/.local/bin"

abbrs=$(sed -n "s/^[[:space:]]*abbr -q \([A-Za-z0-9_-]*\)=.*/\1/p" "$ZSHRC" | sort -u)
aliases=$(sed -n "s/^[[:space:]]*alias \([A-Za-z0-9_-]*\)=.*/\1/p" "$ALIASES" "$ZSHRC" | sort -u)
functions=$(sed -n "s/^\([A-Za-z0-9_-]*\)() *{.*/\1/p" "$FUNCTIONS" | sort -u)
scripts=$(find "$BINDIR" -maxdepth 1 -type f -perm -u+x -exec basename {} \; | sort -u)

status=0
report() {
  echo "❌ '$1' is defined as both $2 and $3"
  status=1
}

overlap() {
  comm -12 <(echo "$1") <(echo "$2")
}

while read -r name; do
  [ -n "$name" ] && report "$name" "a zsh abbreviation" "an alias"
done <<<"$(overlap "$abbrs" "$aliases")"

while read -r name; do
  [ -n "$name" ] && report "$name" "a zsh abbreviation" "a function"
done <<<"$(overlap "$abbrs" "$functions")"

while read -r name; do
  [ -n "$name" ] && report "$name" "a zsh abbreviation" "a script in $BINDIR"
done <<<"$(overlap "$abbrs" "$scripts")"

while read -r name; do
  [ -n "$name" ] && report "$name" "an alias" "a function"
done <<<"$(overlap "$aliases" "$functions")"

while read -r name; do
  [ -n "$name" ] && report "$name" "an alias" "a script in $BINDIR"
done <<<"$(overlap "$aliases" "$scripts")"

while read -r name; do
  [ -n "$name" ] && report "$name" "a function" "a script in $BINDIR"
done <<<"$(overlap "$functions" "$scripts")"

if [ "$status" -eq 0 ]; then
  echo "✅ No shadowed command names"
fi
exit "$status"
