#!/bin/zsh

# Source shared shell configurations
for file in ~/.config/shell/*.sh; do
  [ -r "$file" ] && source "$file"
done

# Initialize completion system
autoload -Uz compinit && compinit -C
zmodload zsh/complist
bindkey -M menuselect '^?' backward-delete-char 2>/dev/null || true

# Zsh plugins (via Homebrew). Guarded so a missing plugin degrades the shell
# instead of erroring, e.g. before brew bundle has run on a fresh machine.
for plugin in \
  /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh \
  /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh \
  /opt/homebrew/share/zsh-history-substring-search/zsh-history-substring-search.zsh \
  /opt/homebrew/share/zsh-abbr/zsh-abbr.zsh \
  /opt/homebrew/opt/fzf-tab/share/fzf-tab/fzf-tab.zsh; do
  [ -r "$plugin" ] && source "$plugin"
done
unset plugin

[ -d /opt/homebrew/share/zsh-completions ] && fpath=(/opt/homebrew/share/zsh-completions $fpath)

# Syntax highlighting styles, only if the plugin loaded
if (( ${+ZSH_HIGHLIGHT_STYLES} )); then
  # Highlight abbreviations as valid commands
  (( ${#ABBR_REGULAR_USER_ABBREVIATIONS} )) && {
    ZSH_HIGHLIGHT_HIGHLIGHTERS+=(regexp)
    ZSH_HIGHLIGHT_REGEXP=('^[[:blank:][:space:]]*('${(j:|:)${(Qk)ABBR_REGULAR_USER_ABBREVIATIONS}}')$' fg=green)
    ZSH_HIGHLIGHT_REGEXP+=('[[:<:]]('${(j:|:)${(Qk)ABBR_GLOBAL_USER_ABBREVIATIONS}}')$' fg=blue)
  }

  ZSH_HIGHLIGHT_STYLES[command]='fg=green'
  ZSH_HIGHLIGHT_STYLES[alias]='fg=green'
  ZSH_HIGHLIGHT_STYLES[builtin]='fg=green'
  ZSH_HIGHLIGHT_STYLES[function]='fg=green'
  ZSH_HIGHLIGHT_STYLES[command-error]='fg=red,bold'
fi

# initialise bash completions
autoload -U +X bashcompinit && bashcompinit

if command -v aws_completer >/dev/null 2>&1; then
  complete -C "$(command -v aws_completer)" aws
fi

# Carapace completions (if installed)
if command -v carapace >/dev/null 2>&1; then
  source <(carapace _carapace zsh)
fi

# History
HISTSIZE=5000
HISTFILE=~/.zsh_history
SAVEHIST=$HISTSIZE
HISTDUP=erase
setopt appendhistory
setopt sharehistory
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_ignore_dups
setopt hist_find_no_dups

# Fish-like directory navigation
setopt AUTO_CD              # Type directory name to cd
setopt AUTO_PUSHD           # Push directories onto stack
setopt PUSHD_IGNORE_DUPS    # Don't duplicate directories
setopt PUSHD_MINUS          # Use - for previous directory

# Better completion behavior
setopt MENU_COMPLETE        # Tab cycles through options
setopt AUTO_LIST            # List choices on ambiguous completion
setopt COMPLETE_IN_WORD     # Complete from cursor position

# Abbreviations. zsh-abbr persists these to ~/.config/zsh-abbr/user-abbreviations,
# which is machine-local state this repo does not track. That store is
# append-only by default: seeding with `abbr -q` never removes anything, so a
# name deleted from here used to live on and keep shadowing whatever it hid.
# Abbreviations expand ahead of functions and PATH, so a stale `gc` silently
# beats the gc() function and ~/.local/bin/gc, with no error.
#
# This block is therefore declarative: the list below is the source of truth
# and the store is reconciled to it on every startup. Anything not declared
# here is erased. That means `abbr add` at the prompt lasts for the session
# only; to keep an abbreviation, add it here.
#
# Nothing here may shadow a function in ~/.config/shell/functions.sh or a
# script in ~/.local/bin; scripts/check-collisions.sh enforces that.
if (( $+functions[abbr] )); then
  typeset -A _abbrs=(
    ga     "git add"
    gco    "git checkout"
    gd     "git diff"
    gs     "git status"
    jl     "jj log"
    jn     "jj new"
    jc     "jj commit"
    je     "jj edit"
    jd     "jj describe"
    js     "jj status"
    j      "jj status"
    jdf    "jj diff"
    jgf    "jj git fetch"
    jgp    "jj git push"
    jrs    "jj rebase -d main"
    squash "jj squash"
    fetch  "jj git fetch"
    push   "jj git push"
  )

  # zsh-abbr stores keys and values with literal quotes; strip them to compare
  typeset -A _stored=()
  typeset _k _v _name
  for _k _v in ${(kv)ABBR_REGULAR_USER_ABBREVIATIONS}; do
    _stored[${(Q)_k}]=${(Q)_v}
  done

  for _name in ${(k)_stored}; do
    (( ${+_abbrs[$_name]} )) || abbr erase "$_name" >/dev/null 2>&1
  done

  # Only write when something actually differs; each add rewrites the store
  for _name in ${(k)_abbrs}; do
    [[ ${_stored[$_name]-} == "${_abbrs[$_name]}" ]] && continue
    abbr --add --force --quiet "$_name=${_abbrs[$_name]}" >/dev/null 2>&1
  done

  unset _abbrs _stored _k _v _name
fi

# Completion styling
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no
# fzf-tab directory preview
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza --color=always --icons --group-directories-first $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'eza --color=always --icons --group-directories-first $realpath'
zstyle ':fzf-tab:*' fzf-flags --height 40% --layout=reverse --border --inline-info

# ZSH-specific aliases
# Remove all items safely, to Trash (`brew install trash`).
if [[ $- == *i* ]]; then
    if which trash >/dev/null 2>&1; then
    alias rm='trash'
    fi
fi


# ZSH-specific overrides
alias size="du -sh"
alias granted-refresh="granted sso populate --sso-region eu-west-2 https://kodehort.awsapps.com/start"
alias cb='git branch --sort=-committerdate | fzf --header "Checkout Recent Branch" --preview "git diff --color=always {1} " --pointer="" | xargs git checkout'

# Shell integrations
command -v direnv >/dev/null 2>&1 && eval "$(direnv hook zsh)"
command -v starship >/dev/null 2>&1 && eval "$(starship init zsh)"

# Vi mode
bindkey -v
bindkey -M viins 'jk' vi-cmd-mode
bindkey '^a' beginning-of-line
bindkey '^e' end-of-line

# Visual feedback for vi mode
function zle-keymap-select {
  if [[ ${KEYMAP} == vicmd ]] || [[ $1 = 'block' ]]; then
    echo -ne '\e[1 q'  # block cursor
  elif [[ ${KEYMAP} == main ]] || [[ ${KEYMAP} == viins ]] || [[ ${KEYMAP} = '' ]] || [[ $1 = 'beam' ]]; then
    echo -ne '\e[5 q'  # beam cursor
  fi
}
zle -N zle-keymap-select

# Fix backspace in vi mode
bindkey "^?" backward-delete-char

# History substring search bindings
bindkey "$terminfo[kcuu1]" history-substring-search-up
bindkey "$terminfo[kcud1]" history-substring-search-down

# Initialize mise (if installed)
if command -v mise >/dev/null 2>&1; then
  eval "$(mise activate zsh)"
fi

# Source fzf key bindings (includes Ctrl+R for history search)
[ -f /opt/homebrew/opt/fzf/shell/key-bindings.zsh ] && source /opt/homebrew/opt/fzf/shell/key-bindings.zsh
[ -r ~/private/.zshrc ] && source ~/private/.zshrc

# Performance optimizations
export KEYTIMEOUT=1  # Faster vi mode switching
export ZSH_AUTOSUGGEST_MANUAL_REBIND=1  # Better performance for autosuggestions
export ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20  # Limit suggestion buffer size

# Better FZF defaults
export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border --inline-info'
export FZF_CTRL_T_OPTS="--preview 'bat --color=always --style=numbers --line-range=:500 {}'"
export FZF_CTRL_R_OPTS="--preview 'echo {}' --preview-window down:3:hidden:wrap --bind '?:toggle-preview'"


# Mise aliases (if installed)
if command -v mise >/dev/null 2>&1; then
  alias mr='mise run'
  alias mi='mise install'
  alias mu='mise use'
  alias ml='mise list'
  alias mc='mise current'
fi


# Initialize zoxide (must be at the very end)
if [[ $- == *i* ]]; then
  eval "$(zoxide init zsh --cmd cd)"
fi


# Wispr Flow (if installed)
if command -v ww >/dev/null 2>&1; then
  eval "$(ww init zsh)"
fi

# bun completions
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"

# Keep the exit status clean: `source ~/.zshrc` is used as a health check in
# CI, and a trailing conditional would report the missing optional file.
true
