#!/usr/bin/env bash
# Fail if a command name is defined in more than one place.
#
# zsh expands abbreviations before it looks up functions, and functions before
# it searches PATH. So an abbr named `gc` silently shadows a `gc()` function,
# which silently shadows ~/.local/bin/gc. Nothing errors; the wrong thing just
# runs. This checks the four namespaces against each other.
#
# The declared list in .zshrc is authoritative: it reconciles
# ~/.config/zsh-abbr/user-abbreviations on every startup, erasing anything not
# declared. So checking the repo covers everything that can survive a shell
# restart, and a name removed from the list stops shadowing for real.

set -uo pipefail

cd "$(dirname "$0")/.." || exit 1

ZSHRC="zsh/.zshrc"
ALIASES="shell/.config/shell/aliases.sh"
FUNCTIONS="shell/.config/shell/functions.sh"
BINDIR="bin/.local/bin"

# Names declared in the `typeset -A _abbrs=( name "expansion" ... )` block
abbrs=$(sed -n '/^ *typeset -A _abbrs=(/,/^ *)/p' "$ZSHRC" |
  sed -n 's/^[[:space:]]*\([A-Za-z0-9_-][A-Za-z0-9_-]*\)[[:space:]]*".*/\1/p' | sort -u)

if [ -z "$abbrs" ]; then
  echo "❌ Found no declared abbreviations in $ZSHRC; has the block moved?"
  exit 1
fi
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
