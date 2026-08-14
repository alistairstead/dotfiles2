#!/bin/sh
# Shared PATH configuration for both bash and zsh.
#
# This is the only place PATH is built. Sourced from .zshenv (so every zsh
# shell gets it, interactive or not), .bashrc, and .profile. Sourcing it
# twice is a no-op: path_prepend skips entries already present, so the
# order below is the order you get.
#
# Entries are listed lowest priority first; the last prepend wins.

path_prepend() {
  [ -n "$1" ] || return 0
  case ":$PATH:" in
    *":$1:"*) ;;
    *) PATH="$1:$PATH" ;;
  esac
}

# Homebrew first, so anything below can override it
if [ -z "$HOMEBREW_PREFIX" ] && [ -x /opt/homebrew/bin/brew ]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

path_prepend "/usr/local/bin"

# Homebrew keg-only tools that need explicit paths
path_prepend "/opt/homebrew/opt/libpq/bin"
path_prepend "/opt/homebrew/opt/icu4c/sbin"
path_prepend "/opt/homebrew/opt/gnu-sed/libexec/gnubin"
path_prepend "/opt/homebrew/opt/mysql-client@8.4/bin"

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
path_prepend "$HOME/.turso"
path_prepend "$HOME/.cargo/bin"
path_prepend "$HOME/.bun/bin"

# GUI apps that ship a CLI
path_prepend "/Applications/Obsidian.app/Contents/MacOS"

# Ours wins
path_prepend "$HOME/bin"
path_prepend "$HOME/.local/bin"

export PATH
