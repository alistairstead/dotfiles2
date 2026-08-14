#!/bin/zsh

# This file, .zshenv, is the first file sourced by zsh for EACH shell, whether
# it's interactive or not. This includes non-interactive sub-shells, so keep it
# to environment and PATH only.
#
# PATH and exported variables live in ~/.config/shell so bash gets the same
# setup. Both files are idempotent, so .zshrc re-sourcing them is harmless.

for file in ~/.config/shell/path.sh ~/.config/shell/env.sh; do
  [ -r "$file" ] && source "$file"
done
