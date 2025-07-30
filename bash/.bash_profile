#!/bin/bash
# Bash profile for login shells
# This file is read for login shells. It sources .bashrc for consistency.

# Source .bashrc if it exists
if [[ -f ~/.bashrc ]]; then
  # shellcheck source=/dev/null
  source ~/.bashrc
fi

# Additional login-specific configurations can go here
. "$HOME/.cargo/env"
