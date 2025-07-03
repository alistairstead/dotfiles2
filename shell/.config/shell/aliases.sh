#!/bin/sh
# Shared aliases for both bash and zsh
# This file contains POSIX-compatible alias definitions

# Editor
alias vim='nvim'

# Navigation
alias c='clear'
alias ll='ls -la'

# Git shortcuts
alias g='git'
alias ga='git add'
alias gs='git status -sb'
alias gco='git checkout'
alias push='git push'
alias pull='git pull'

# Common command improvements
alias mkdir="mkdir -p"
alias df="df -h"
alias du="du -sh"

# Use modern replacements if available
if command -v bat >/dev/null 2>&1; then
  alias cat="bat"
fi

if command -v eza >/dev/null 2>&1; then
  alias ls='eza'
  alias ll='eza --all --header --long'
  alias la='eza -lbhHigUmuSa'
  alias tree='eza --tree'
fi

if command -v btop >/dev/null 2>&1; then
  alias top="btop"
  alias htop="btop"
fi

if command -v delta >/dev/null 2>&1; then
  alias diff="delta"
fi

# AWS Granted
alias assume=". assume"

# Claude notify wrapper
alias claude-notify="~/dev/personal/dotfiles/scripts/claude-notify"

# Atuin aliases (if installed)
if command -v atuin >/dev/null 2>&1; then
  alias ah='atuin history list'
  alias as='atuin search'
  alias ai='atuin import auto'
  alias ast='atuin stats'
fi