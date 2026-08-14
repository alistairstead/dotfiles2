#!/bin/bash
# Generic profile file that works with sh/bash
# This ensures compatibility when bash is invoked as sh

# PATH and exported variables live in ~/.config/shell so zsh gets the same
# setup. Both files are idempotent, so .bashrc re-sourcing them is harmless.
for file in "$HOME/.config/shell/path.sh" "$HOME/.config/shell/env.sh"; do
  # shellcheck source=/dev/null
  [ -r "$file" ] && . "$file"
done

# Source .bashrc for bash shells
if [[ -n "$BASH_VERSION" ]]; then
  if [[ -f "$HOME/.bashrc" ]]; then
    # shellcheck source=/dev/null
    source "$HOME/.bashrc"
  fi
fi
