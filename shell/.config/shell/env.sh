#!/bin/sh
# Shared environment variables for both bash and zsh
# This file contains POSIX-compatible environment variable definitions

# Editor configuration
export GIT_EDITOR='zed-preview --wait'
export VISUAL='zed-preview --wait'
export EDITOR='zed-preview --wait'

# Terminal settings
export TERM=tmux-256color

# AWS Granted settings
export GRANTED_ENABLE_AUTO_REASSUME="true"

# 1Password SSH agent
export SSH_AUTH_SOCK="$HOME/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"

# Disable zoxide doctor warnings
export _ZO_DOCTOR=0
