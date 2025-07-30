#!/bin/bash
# Generic profile file that works with sh/bash
# This ensures compatibility when bash is invoked as sh

# Source .bashrc for bash shells
if [[ -n "$BASH_VERSION" ]]; then
  if [[ -f "$HOME/.bashrc" ]]; then
    source "$HOME/.bashrc"
  fi
fi

# Basic PATH setup for non-bash shells
export PATH="/usr/local/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/bin:$PATH"
export PATH="$HOME/.bun/bin:$PATH"
export PATH="${ASDF_DATA_DIR:-$HOME/.asdf}/shims:$PATH"

# Homebrew for non-bash shells
if [[ -f "/opt/homebrew/bin/brew" ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

. "$HOME/.cargo/env"
