#!/bin/sh
# Shared PATH configuration for both bash and zsh.
#
# This is the only place PATH is built. Sourced from .zshenv (so every zsh
# shell gets it, interactive or not), .zprofile, .bashrc, and .profile.
#
# Entries are listed lowest priority first; the last prepend wins.
#
# Re-sourcing this file re-asserts that order, and has to: macOS runs
# /usr/libexec/path_helper from /etc/zprofile and /etc/profile, which rebuilds
# PATH with everything in /etc/paths at the front. That runs *after* .zshenv,
# so it demoted /opt/homebrew/bin below /usr/bin and /bin, and `bash` resolved
# to the 3.2.57 macOS ships rather than Homebrew's 5.x. path_prepend therefore
# moves an entry to the front rather than skipping one already present, which
# keeps it idempotent while making a later re-source repair the order.

path_prepend() {
  [ -n "$1" ] || return 0

  # Rebuild PATH without $1 (and without the empty entries a stray colon
  # leaves behind, which mean "the current directory"), then put $1 in front.
  # Done with parameter expansion rather than sed: this runs ~15 times per
  # shell start and forking that often is measurable.
  _pp_out=''
  _pp_rest="$PATH"
  while [ -n "$_pp_rest" ]; do
    case "$_pp_rest" in
      *:*) _pp_entry="${_pp_rest%%:*}"; _pp_rest="${_pp_rest#*:}" ;;
      *) _pp_entry="$_pp_rest"; _pp_rest='' ;;
    esac
    [ -n "$_pp_entry" ] || continue
    [ "$_pp_entry" = "$1" ] && continue
    _pp_out="${_pp_out:+$_pp_out:}$_pp_entry"
  done

  PATH="$1${_pp_out:+:$_pp_out}"
  unset _pp_out _pp_rest _pp_entry
}

# Homebrew first, so anything below can override it.
#
# `brew shellenv` is what defines HOMEBREW_PREFIX, MANPATH and INFOPATH, and
# forking brew is worth doing only once. The prepends sit outside that guard on
# purpose: on a re-source HOMEBREW_PREFIX is already set, so shellenv is skipped,
# and without these the Homebrew directories are the one part of PATH that
# path_helper's reshuffle would never get repaired. That is what put /usr/bin
# ahead of /opt/homebrew/bin.
if [ -z "$HOMEBREW_PREFIX" ] && [ -x /opt/homebrew/bin/brew ]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

if [ -n "$HOMEBREW_PREFIX" ]; then
  path_prepend "$HOMEBREW_PREFIX/sbin"
  path_prepend "$HOMEBREW_PREFIX/bin"
fi

path_prepend "/usr/local/bin"

# Homebrew keg-only tools that need explicit paths
path_prepend "/opt/homebrew/opt/libpq/bin"
path_prepend "/opt/homebrew/opt/icu4c/sbin"
path_prepend "/opt/homebrew/opt/gnu-sed/libexec/gnubin"

# Unversioned python shims (python3 -> python)
for _py in /opt/homebrew/opt/python@*/libexec/bin; do
  [ -d "$_py" ] && path_prepend "$_py"
done
unset _py

# Language and tool installs
path_prepend "$HOME/go/bin"
path_prepend "$HOME/.sst/bin"
path_prepend "$HOME/Library/pnpm"
path_prepend "$HOME/.npm-global/bin"
path_prepend "$HOME/.cargo/bin"
path_prepend "$HOME/.bun/bin"

# GUI apps that ship a CLI
path_prepend "/Applications/Obsidian.app/Contents/MacOS"

# Ours wins
path_prepend "$HOME/bin"
path_prepend "$HOME/.local/bin"

export PATH
