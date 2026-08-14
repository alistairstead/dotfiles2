#!/bin/bash
# Bash configuration that mirrors essential environment from zsh

# Source shared shell configurations
for file in ~/.config/shell/*.sh; do
  # shellcheck source=/dev/null
  [ -r "$file" ] && source "$file"
done

# =====================================
# SHELL INTEGRATIONS
# =====================================

# Direnv hook (if installed)
if command -v direnv >/dev/null 2>&1; then
  eval "$(direnv hook bash)"
fi

# Carapace completions. The version guard is load bearing: carapace registers
# its ~650 commands with `complete -o noquote`, and `noquote` arrived in bash
# 4.4. macOS still ships 3.2.57 as /bin/bash, and this box resolves plain `bash`
# to it (/bin precedes /opt/homebrew/bin in $PATH), so without the guard every
# shell start printed `complete: noquote: invalid option name` and bound
# nothing. Under Homebrew's bash 5 the same block works and takes ~650 commands.
#
#   bash -c 'echo $BASH_VERSION'   # < 4.4 means carapace is skipped here
#
# The bash-completion sourced further down does not fight this: it registers
# lazily via `complete -D`, which never displaces an explicit registration.
if command -v carapace >/dev/null 2>&1 &&
  ((BASH_VERSINFO[0] > 4 || (BASH_VERSINFO[0] == 4 && BASH_VERSINFO[1] >= 4))); then
  # shellcheck disable=SC1090
  source <(carapace _carapace bash)
fi

# Mise version manager (if installed)
if command -v mise >/dev/null 2>&1; then
  eval "$(mise activate bash)"
fi

# AWS CLI completion (if installed)
if command -v aws_completer >/dev/null 2>&1; then
  complete -C "$(command -v aws_completer)" aws
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

# =====================================
# ATUIN
# =====================================

# Binds ctrl-r and the up arrow to the shared SQLite history store, the same one
# zsh uses. Must be last: `atuin init bash` loads its bundled bash-preexec,
# which hooks PROMPT_COMMAND and has to see the final value. Sourced mid-file it
# initialises silently and records nothing — `atuin doctor` then reports
# "preexec": "unknown" rather than "bash-preexec".
#
# `?` is left unbound here (--disable-ai): the AI keybinding is worth having in
# zsh, which is the shell actually used, and this file is a mirror kept minimal.
#
# Unverified: bash here is a thin mirror of zsh and nothing drives it
# interactively, so recording has not been confirmed end to end. To check, from
# a real interactive bash in a terminal:
#
#   atuin doctor | rg preexec     # want "bash-preexec", not "unknown"
#
# If it reports "unknown", nothing is being recorded from bash and this block
# can be deleted rather than left as decoration.
if command -v atuin >/dev/null 2>&1; then
  eval "$(atuin init bash --disable-ai)"
fi

# Keep the exit status clean: `source ~/.bashrc` is used as a health check in
# CI, and a trailing conditional would report the missing optional file.
true
