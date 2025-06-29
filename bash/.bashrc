#!/bin/bash
# Bash configuration that mirrors essential environment from zsh

# =====================================
# ENVIRONMENT VARIABLES
# =====================================

# Disable zoxide doctor warnings when running in bash
export _ZO_DOCTOR=0

# Editor configuration
export GIT_EDITOR='nvim'
export VISUAL='nvim'
export EDITOR='nvim'

# Terminal settings
export TERM=tmux-256color


# AWS Granted settings
export GRANTED_ENABLE_AUTO_REASSUME="true"

# 1Password SSH agent
export SSH_AUTH_SOCK="$HOME/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"

# =====================================
# PATH CONFIGURATION
# =====================================

# Homebrew initialization (if installed)
if [[ -f "/opt/homebrew/bin/brew" ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# Add common development paths
export PATH="/usr/local/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/bin:$PATH"

# npm global binaries (if npm-global exists)
if [[ -d "$HOME/.npm-global/bin" ]]; then
  export PATH="$HOME/.npm-global/bin:$PATH"
fi

# =====================================
# SHELL INTEGRATIONS
# =====================================

# Direnv hook (if installed)
if command -v direnv >/dev/null 2>&1; then
  eval "$(direnv hook bash)"
fi

# Mise version manager (if installed)
if command -v mise >/dev/null 2>&1; then
  eval "$(mise activate bash)"
fi

# AWS CLI completion (if installed)
if command -v aws_completer >/dev/null 2>&1; then
  complete -C '/opt/homebrew/bin/aws_completer' aws
fi

# =====================================
# HISTORY CONFIGURATION
# =====================================

# History settings
HISTSIZE=5000
HISTFILE=~/.bash_history
HISTFILESIZE=5000
HISTCONTROL=ignoreboth:erasedups

# Append to history instead of overwriting
shopt -s histappend

# Save multi-line commands as one command
shopt -s cmdhist

# =====================================
# ALIASES (Essential ones from zsh)
# =====================================

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

# =====================================
# FUNCTIONS
# =====================================

# Simple git wrapper function
g() {
  if [[ $# -eq 0 ]]; then
    git status --short
  else
    git "$@"
  fi
}

# Git commit wrapper
gc() {
  if [[ $# -eq 0 ]]; then
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
  source "$1"
  set +a
}

# =====================================
# PROMPT (Simple version)
# =====================================

# Basic prompt with current directory
PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '

# =====================================
# SHELL OPTIONS
# =====================================

# Enable programmable completion
if [[ -f /opt/homebrew/etc/profile.d/bash_completion.sh ]]; then
  source /opt/homebrew/etc/profile.d/bash_completion.sh
fi

# Case-insensitive globbing
shopt -s nocaseglob

# Autocorrect typos in path names
shopt -s cdspell

# Check window size after each command
shopt -s checkwinsize

# Enable extended globbing
shopt -s extglob

# =====================================
# PRIVATE CONFIGURATION
# =====================================

# Source private configuration if it exists
if [[ -r ~/private/.bashrc ]]; then
  source ~/private/.bashrc
fi

# Initialize atuin for better shell history
if command -v atuin >/dev/null 2>&1; then
  eval "$(atuin init bash)"
fi