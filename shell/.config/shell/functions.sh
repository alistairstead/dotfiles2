#!/bin/sh
# Shared functions for both bash and zsh
# This file contains POSIX-compatible function definitions

# Simple git wrapper function
g() {
  if [ $# -eq 0 ]; then
    git status --short
  else
    git "$@"
  fi
}

# Git commit wrapper
gc() {
  if [ $# -eq 0 ]; then
    git commit -v
  else
    git commit -m "$*"
  fi
}

# Copy to clipboard (macOS)
if command -v pbcopy >/dev/null 2>&1; then
  copy() {
    cat "$@" | pbcopy
  }
fi

# Source environment files
envs() {
  set -a
  # shellcheck source=/dev/null
  . "$1"
  set +a
}