#!/bin/zsh
# Created by Zap installer https://www.zapzsh.org
[ -f "${XDG_DATA_HOME:-$HOME/.local/share}/zap/zap.zsh" ] && source "${XDG_DATA_HOME:-$HOME/.local/share}/zap/zap.zsh"

if [[ -f "/opt/homebrew/bin/brew" ]] then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# Add zsh plugins
plug "zsh-users/zsh-syntax-highlighting" # Command-line syntax highlighting
plug "zsh-users/zsh-completions"
plug "zsh-users/zsh-autosuggestions" # Inline suggestions
plug "Aloxaf/fzf-tab"
plug "zsh-users/zsh-history-substring-search" # History search
# plug "marlonrichert/zsh-edit" # Better keyboard shortcuts
# plug "marlonrichert/zsh-hist" # Edit history from the command line.
# plug "zap-zsh/supercharge"
# plug "zap-zsh/exa"
plug "zap-zsh/vim"
# plug "zap-zsh/fzf"
plug "reegnz/jq-zsh-plugin"

# Configure syntax highlighting styles
ZSH_HIGHLIGHT_STYLES[command]='fg=green'
ZSH_HIGHLIGHT_STYLES[alias]='fg=green'
ZSH_HIGHLIGHT_STYLES[builtin]='fg=green'
ZSH_HIGHLIGHT_STYLES[function]='fg=green'
ZSH_HIGHLIGHT_STYLES[command-error]='fg=red,bold'

# initialise completions with ZSH's compinit
autoload -U +X bashcompinit && bashcompinit

# Lazy load completions for better performance
autoload -Uz compinit
if [[ -n ${ZDOTDIR}/.zcompdump(#qNmh+24) ]]; then
  compinit
else
  compinit -C
fi

complete -C '/opt/homebrew/bin/aws_completer' aws

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

# Fish-like abbreviations (expand on space)
typeset -Ag abbreviations
abbreviations=(
  "g"    "git"
  "ga"   "git add"
  "gc"   "git commit"
  "gco"  "git checkout"
  "gd"   "git diff"
  "gs"   "git status"
  "ll"   "ls -la"
)

# Expand abbreviations
magic-abbrev-expand() {
  local left prefix
  left=$(echo -nE "$LBUFFER" | sed -e "s/[[:space:]]*$//")
  prefix=$(echo -nE "$LBUFFER" | sed -e "s/.*[[:space:]]//")
  if [[ -n "$abbreviations[$prefix]" ]]; then
    LBUFFER=$left" "$abbreviations[$prefix]
  fi
  zle self-insert
}
zle -N magic-abbrev-expand
bindkey " " magic-abbrev-expand

# Completion styling
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'ls --color $realpath'

# Aliases
alias vim='nvim'
alias c='clear'
alias zshrc="vim ~/.zshrc"
alias vimrc="vim ~/.config/nvim"
alias tmuxrc="vim ~/.tmux.conf"
alias pn=pnpm
alias code="cd ~/code"
alias dotfiles="cd ~/dotfiles"
# Remove all items safely, to Trash (`brew install trash`).
if which trash >/dev/null 2>&1; then
  alias rm='trash'
fi
alias ls='eza $eza_params'
alias l='eza --git-ignore $eza_params'
alias ll='eza --all --header --long $eza_params'
alias llm='eza --all --header --long --sort=modified $eza_params'
alias la='eza -lbhHigUmuSa'
alias lx='eza -lbhHigUmuSa@'
alias lt='eza --tree $eza_params'
alias tree='eza --tree $eza_params'
alias ga='git add'
alias gs='git status -sb'
alias gco='git co'
alias push='git push'
alias pull='git pull'
# builtins
alias size="du -sh"
alias cp="cp -i"
alias mkdir="mkdir -p"
alias df="df -h"
alias du="du -sh"
alias del="rm -rf"
alias null="/dev/null"
# overrides
alias cat="bat"
alias top="btop"
alias htop="btop"
alias diff="delta"

alias granted-refresh="granted sso populate --sso-region eu-west-2 https://kodehort.awsapps.com/start"
gi() {
	curl -s "https://www.gitignore.io/api/$*"
}
g() {
	args=$@
	if [[ $# -eq 0 ]]; then
		git status --short
	else
		git $args
	fi
}
gc() {
	args=$@
	if [[ $# -eq 0 ]]; then
		git commit -v
	else
		git commit -m "$args"
	fi
}
alias cb='git branch --sort=-committerdate | fzf --header "Checkout Recent Branch" --preview "git diff --color=always {1} " --pointer="" | xargs git checkout'
function ghpr() {
  GH_FORCE_TTY=100% gh pr list | fzf --query "$1" --ansi --preview 'GH_FORCE_TTY=100% gh pr view {1}' --preview-window down --header-lines 3 | awk '{print $1}' | xargs gh pr checkout -f
}
function ghgist() {
  GH_FORCE_TTY=100% gh gist list --limit 20 | fzf --ansi --preview 'GH_FORCE_TTY=100% gh gist view {1}' --preview-window down | awk '{print $1}' | xargs gh gist edit
}

# Copy to clipboard
copy() {
  cat "$@" | pbcopy
}

# Source environment files
envs() {
  set -a
  source "$1"
  set +a
}


# Shell integrations
eval "$(direnv hook zsh)"
eval "$(starship init zsh)"

# Better vi mode
bindkey -v
bindkey 'jk' vi-cmd-mode
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
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down

# # append completions to fpath
fpath=(${ASDF_DATA_DIR:-$HOME/.asdf}/completions $fpath)
# initialise completions with ZSH's compinit
autoload -Uz compinit && compinit

# Source fzf key bindings (includes Ctrl+R for history search)
[ -f /opt/homebrew/opt/fzf/shell/key-bindings.zsh ] && source /opt/homebrew/opt/fzf/shell/key-bindings.zsh
[ -r ~/private/.zshrc ] && source ~/private/.zshrc

export GIT_EDITOR='nvim'
export VISUAL='nvim'
export EDITOR='nvim'
export VI_MODE_ESC_INSERT="jk"
export TERM=tmux-256color
export ASDF_NODEJS_LEGACY_FILE_DYNAMIC_STRATEGY=latest_installed
export GRANTED_ENABLE_AUTO_REASSUME="true"
export SSH_AUTH_SOCK="$HOME/Library/Group\ Containers/2BUA8C4S2C.com.1password/t/agent.sock";

# Aliases
alias assume=". assume"

# Initialize zoxide (must be at the very end)
eval "$(zoxide init --cmd cd zsh)"
