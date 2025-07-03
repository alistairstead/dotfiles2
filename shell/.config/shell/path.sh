#!/bin/sh
# Shared PATH configuration for both bash and zsh
# This file contains POSIX-compatible PATH setup

# Add common development paths
export PATH="/usr/local/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/bin:$PATH"

# npm global binaries (if npm-global exists)
if [ -d "$HOME/.npm-global/bin" ]; then
  export PATH="$HOME/.npm-global/bin:$PATH"
fi

# Homebrew initialization (if installed)
if [ -f "/opt/homebrew/bin/brew" ]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi