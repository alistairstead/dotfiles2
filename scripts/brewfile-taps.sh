#!/bin/sh
# Single source of truth for which taps a Brewfile depends on. Sourced by
# install.sh (to tap and trust them before brew bundle) and by
# scripts/check-brewfile.sh (to tap them before resolving names), so the two
# cannot disagree about what needs tapping.
#
# A tap is needed either way it can be written:
#
#   tap "rsteube/tap"                    an explicit line, for the bare-name
#   brew "carapace-aws"                  entries that only resolve once tapped
#
#   brew "koekeishiya/formulae/yabai"    tap-qualified, which implies its tap
#   cask "dagger/tap/container-use"      with no separate line
#
# Deriving both forms is what lets the Brewfile drop the redundant tap lines
# without install.sh quietly failing to trust those taps: Homebrew refuses to
# load formulae from an untrusted third-party tap, so a missed one turns into
# "no such formula" on a fresh machine.

# Usage: brewfile_taps [brewfile]
brewfile_taps() {
  _bt_file=${1:-Brewfile}
  [ -r "$_bt_file" ] || return 0

  {
    sed -n 's/^tap "\([^"]*\)".*/\1/p' "$_bt_file"
    sed -n 's/^brew "\([^"]*\)".*/\1/p' "$_bt_file" | sed -n 's|^\([^/]*/[^/]*\)/.*|\1|p'
    sed -n 's/^cask "\([^"]*\)".*/\1/p' "$_bt_file" | sed -n 's|^\([^/]*/[^/]*\)/.*|\1|p'
  } | sort -u

  unset _bt_file
}
