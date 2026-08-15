#!/usr/bin/env bash
# Verify every name in the Brewfile still resolves to something Homebrew knows.
#
# The full `brew bundle` only ever runs on a real machine; CI installs a small
# subset. So a formula that gets renamed, deprecated into oblivion, or moved
# between taps stays invisible until the next time you set up a laptop. This
# resolves names against Homebrew's metadata. Nothing is installed.

set -uo pipefail

cd "$(dirname "$0")/.." || exit 1

BREWFILE=${1:-Brewfile}
status=0

names() { sed -n "s/^$1 \"\([^\"]*\)\".*/\1/p" "$BREWFILE"; }

# Taps first: most entries are short names that only resolve once their tap is
# installed, and a tap-qualified name (user/repo/formula) implies its own tap.
taps=()
while IFS= read -r tap; do
  [ -n "$tap" ] && taps+=("$tap")
done < <({
  names tap
  names brew | sed -n 's|^\([^/]*/[^/]*\)/.*|\1|p'
  names cask | sed -n 's|^\([^/]*/[^/]*\)/.*|\1|p'
} | sort -u)

for tap in "${taps[@]}"; do
  brew tap "$tap" >/dev/null 2>&1 || {
    echo "❌ tap '$tap' could not be tapped"
    status=1
    continue
  }
  # Homebrew refuses to load formulae from an untrusted third-party tap.
  # install.sh trusts every tap the Brewfile declares, so on a set-up machine
  # this is already done. Trusting is still a persistent machine-level change
  # and this script is a validator, so it only does it on an ephemeral runner;
  # locally it reports instead, below.
  if [ -n "${CI:-}" ]; then
    brew trust "$tap" >/dev/null 2>&1 || echo "⚠️  could not trust tap '$tap'"
  fi
done
echo "✅ ${#taps[@]} taps available"

resolve() {
  local kind=$1
  shift
  [ $# -gt 0 ] || return 0

  if brew info --json=v2 "$kind" "$@" >/dev/null 2>&1; then
    echo "✅ $# ${kind#--} names resolve"
    return 0
  fi

  # A batch stops at the first bad name, so re-check one by one to list them all
  local bad=0 name err
  for name in "$@"; do
    if err=$(brew info --json=v2 "$kind" "$name" 2>&1 >/dev/null); then
      continue
    fi
    case "$err" in
      *"untrusted tap"*)
        # CI trusts every declared tap, so this should not survive there
        if [ -n "${CI:-}" ]; then
          echo "❌ ${kind#--} '$name' is in a tap that could not be trusted"
          bad=1
        else
          echo "⚠️  ${kind#--} '$name' is in an untrusted tap, so it was not checked"
          echo "    brew will not load it either; run ./install.sh, or brew trust <tap>"
        fi
        ;;
      *)
        echo "❌ ${kind#--} '$name' does not resolve"
        bad=1
        ;;
    esac
  done
  return "$bad"
}

formulae=()
while IFS= read -r name; do
  [ -n "$name" ] && formulae+=("$name")
done < <(names brew)

casks=()
while IFS= read -r name; do
  [ -n "$name" ] && casks+=("$name")
done < <(names cask)

resolve --formula "${formulae[@]}" || status=1
resolve --cask "${casks[@]}" || status=1

exit "$status"
