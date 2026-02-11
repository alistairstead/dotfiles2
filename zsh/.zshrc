#!/bin/zsh

# Source shared shell configurations
for file in ~/.config/shell/*.sh; do
  [ -r "$file" ] && source "$file"
done

# Initialize completion system
autoload -Uz compinit && compinit -C
zmodload zsh/complist
bindkey -M menuselect '^?' backward-delete-char 2>/dev/null || true

# Zsh plugins (via Homebrew)
source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source /opt/homebrew/share/zsh-history-substring-search/zsh-history-substring-search.zsh
source /opt/homebrew/share/zsh-abbr/zsh-abbr.zsh
fpath=(/opt/homebrew/share/zsh-completions $fpath)

# Configure syntax highlighting styles
ZSH_HIGHLIGHT_STYLES[command]='fg=green'
ZSH_HIGHLIGHT_STYLES[alias]='fg=green'
ZSH_HIGHLIGHT_STYLES[builtin]='fg=green'
ZSH_HIGHLIGHT_STYLES[function]='fg=green'
ZSH_HIGHLIGHT_STYLES[command-error]='fg=red,bold'

# initialise bash completions
autoload -U +X bashcompinit && bashcompinit

complete -C '/opt/homebrew/bin/aws_completer' aws

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

# Abbreviations (managed by zsh-abbr, persist in ~/.config/zsh-abbr/user-abbreviations)
# Seed defaults on first run — zsh-abbr skips duplicates
abbr -q g=git
abbr -q ga="git add"
abbr -q gc="git commit"
abbr -q gco="git checkout"
abbr -q gd="git diff"
abbr -q gs="git status"
abbr -q ll="eza --all --header --long"
abbr -q jl="jj log"
abbr -q jn="jj new"
abbr -q jc="jj commit"
abbr -q je="jj edit"
abbr -q jd="jj describe"
abbr -q js="jj status"
abbr -q jdf="jj diff"
abbr -q jgf="jj git fetch"
abbr -q jgp="jj git push"
abbr -q jrs="jj rebase -d main"

# Completion styling
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no

# ZSH-specific aliases
alias zshrc="vim ~/.zshrc"
alias vimrc="vim ~/.config/nvim"
alias tmuxrc="vim ~/.tmux.conf"
# Remove all items safely, to Trash (`brew install trash`).
if which trash >/dev/null 2>&1; then
  alias rm='trash'
fi
# Eza defaults and aliases
eza_params="--group-directories-first --icons"
alias l='eza --git-ignore $eza_params'
alias llm='eza --all --header --long --sort=modified $eza_params'
alias lx='eza -lbhHigUmuSa@'
alias lt='eza --tree $eza_params'
# ZSH-specific git alias
alias gco='git co'
# ZSH-specific overrides
alias size="du -sh"
alias cp="cp -i"
alias del="rm -rf"
alias null="/dev/null"

# ZSH-specific functions
alias granted-refresh="granted sso populate --sso-region eu-west-2 https://kodehort.awsapps.com/start"
alias cb='git branch --sort=-committerdate | fzf --header "Checkout Recent Branch" --preview "git diff --color=always {1} " --pointer="" | xargs git checkout'

# Shell integrations
eval "$(direnv hook zsh)"
eval "$(starship init zsh)"

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
[ -f /opt/homebrew/opt/fzf/shell/completion.zsh ] && source /opt/homebrew/opt/fzf/shell/completion.zsh
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


eval "$(ww init zsh)"


# bun completions
[ -s "/Users/alistairstead/.bun/_bun" ] && source "/Users/alistairstead/.bun/_bun"

. "$HOME/.turso/env"
