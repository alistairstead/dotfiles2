#!/bin/bash
# Disable zoxide doctor warnings when running in bash
export _ZO_DOCTOR=0

# This prevents the zoxide error when Claude Code runs bash commands
# since it inherits SHELL=/bin/zsh but executes in bash