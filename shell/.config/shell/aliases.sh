#!/bin/sh
# Shared aliases for both bash and zsh
# This file contains POSIX-compatible alias definitions

# Editor
alias vim='nvim'

# Navigation
alias c='clear'

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
    alias l='eza --git-ignore --icons'
    alias ll='eza --all --header --long'
    alias la='eza -lbhHigUmuSa'
    alias llm='eza --all --header --long --sort=modified --icons'
    alias lx='eza -lbhHigUmuSa@'
    alias lt='eza --tree --icons'
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
# Both must be sourced: they mutate the current shell's environment.
alias assume=". assume"
alias unassume=". assume --unset"
alias granted-refresh='granted sso populate --sso-region "$KODEHORT_SSO_REGION" "$KODEHORT_SSO_START_URL"'
