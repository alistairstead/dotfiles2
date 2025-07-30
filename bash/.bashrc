#!/bin/bash
# Bash configuration that mirrors essential environment from zsh

# Source shared shell configurations
for file in ~/.config/shell/*.sh; do
  [ -r "$file" ] && source "$file"
done

# =====================================
# SHELL INTEGRATIONS
# =====================================

# Direnv hook (if installed)
if command -v direnv >/dev/null 2>&1; then
  eval "$(direnv hook bash)"
fi

# Carapace completions (if installed)
if command -v carapace >/dev/null 2>&1; then
  source <(carapace _carapace)
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
# BASH-SPECIFIC CONFIGURATION
# =====================================

# Note: Common aliases and functions are now loaded from ~/.config/shell/*.sh

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
  # shellcheck source=/dev/null
  source ~/private/.bashrc
fi

# Initialize atuin for better shell history
if command -v atuin >/dev/null 2>&1; then
  eval "$(atuin init bash)"
fi

. "$HOME/.cargo/env"
