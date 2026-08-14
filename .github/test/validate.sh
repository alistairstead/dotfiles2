#!/usr/bin/env bash
# Validation script for CI testing
# Checks that the installation completed successfully

echo "=== Running Dotfiles Installation Validation ==="

FAILURES=()

# Color functions
success() { echo "✅ $1"; }
error() {
  echo "❌ $1"
  FAILURES+=("$1")
}
info() { echo "ℹ️  $1"; }

# Check required commands
info "Checking required commands..."
REQUIRED_COMMANDS=(
  "brew"
  "git"
  "stow"
  "zsh"
  "bash"
  "mise"
  "nvim"
  "tmux"
)

for cmd in "${REQUIRED_COMMANDS[@]}"; do
  if command -v "$cmd" &>/dev/null; then
    success "$cmd is installed"
  else
    error "$cmd is NOT installed"
  fi
done

# Check every tracked file in every stow package landed in $HOME. The package
# list comes from the same file install.sh uses, so the two cannot drift.
info "Checking stowed modules..."
# shellcheck source=../../scripts/stow-modules.sh
. ./scripts/stow-modules.sh

# Names stow is configured to skip (see .stowrc)
is_ignored() {
  case "$(basename "$1")" in
    README.* | .DS_Store) return 0 ;;
  esac
  return 1
}

while IFS= read -r module; do
  linked=0
  missing=0
  while IFS= read -r file; do
    # Still in the index but gone from the worktree; stow cannot link it
    [ -e "$file" ] || continue
    rel=${file#"$module"/}
    is_ignored "$rel" && continue
    if [ ! -e "$HOME/$rel" ]; then
      missing=$((missing + 1))
      error "$module: ~/$rel is missing"
    elif [ ! "$HOME/$rel" -ef "$file" ]; then
      # Same path, different inode: a copy, not a link into the repo. `stow
      # --adopt` produces this when the target already existed, and it means
      # everything below is testing the wrong file.
      missing=$((missing + 1))
      error "$module: ~/$rel is not the repo file"
    else
      linked=$((linked + 1))
    fi
  done < <(git ls-files "$module")

  if [ "$missing" -eq 0 ]; then
    success "$module linked ($linked files)"
  fi
done < <(stow_modules .)

# Test shell configurations
info "Testing shell configurations..."

# Test Zsh config
if zsh -c "source ~/.zshrc"; then
  success "Zsh configuration loads without errors"
else
  error "Zsh configuration has errors"
fi

# Test Bash config
if bash -c "source ~/.bashrc"; then
  success "Bash configuration loads without errors"
else
  error "Bash configuration has errors"
fi

# An interactive shell runs paths a `source` never reaches: compinit, zle,
# bindkey, and the [[ $- == *i* ]] blocks. Only the exit status is meaningful;
# zsh warns "can't change option: zle" with no tty.
if zsh -i -c 'true' 2>/dev/null; then
  success "Interactive zsh starts without errors"
else
  error "Interactive zsh fails to start"
fi


# A fresh login shell, not this one. Inheriting the caller's PATH would hide
# both duplicates and ordering, since path_prepend skips what is already set.
clean_zsh() {
  local env_args
  env_args=(HOME="$HOME" USER="${USER:-$(id -un)}" TERM=dumb
    PATH=/usr/bin:/bin:/usr/sbin:/sbin)
  # Passed through so a caller can point zsh at a throwaway config dir
  [ -n "${XDG_CONFIG_HOME:-}" ] && env_args+=(XDG_CONFIG_HOME="$XDG_CONFIG_HOME")
  env -i "${env_args[@]}" zsh "$@"
}

# PATH should be built once, not re-prepended per source
info "Testing PATH..."
FULL_PATH=$(clean_zsh -c 'source ~/.zshrc >/dev/null 2>&1; printf "%s" "$PATH"')
DOUBLED=$(echo "$FULL_PATH" | tr ':' '\n' | sort | uniq -d)
if [ -z "$DOUBLED" ]; then
  success "PATH has no duplicate entries"
else
  error "PATH has duplicate entries: $(echo "$DOUBLED" | tr '\n' ' ')"
fi

# Order is the property that broke before. Absolute position is not the
# invariant: mise activate legitimately prepends tool shims in .zshrc. What
# must hold is that our own bins outrank the system ones.
path_index() {
  echo "$FULL_PATH" | tr ':' '\n' | grep -nxF "$1" | head -1 | cut -d: -f1
}

check_precedes() {
  local first second
  first=$(path_index "$1")
  second=$(path_index "$2")
  if [ -z "$first" ]; then
    error "PATH is missing $1"
  elif [ -z "$second" ]; then
    info "PATH has no $2 to compare against"
  elif [ "$first" -lt "$second" ]; then
    success "PATH: $1 precedes $2"
  else
    error "PATH: $1 comes after $2"
  fi
}

check_precedes "$HOME/.local/bin" "/opt/homebrew/bin"
check_precedes "$HOME/.local/bin" "/usr/bin"
check_precedes "$HOME/bin" "/usr/bin"

# Aliases, functions and scripts must resolve to what the configs define.
# Each entry is "name<TAB>expected substring of `type` output".
info "Testing command resolution..."
while IFS=$'\t' read -r name expected; do
  [ -n "$name" ] || continue
  resolved=$(clean_zsh -i -c "type $name" 2>/dev/null)
  if [[ "$resolved" == *"$expected"* ]]; then
    success "$name resolves to $expected"
  else
    error "$name resolves to '${resolved:-nothing}', expected $expected"
  fi
done <<EOF
ll	eza
vim	nvim
g	function
gc	function
update	$HOME/.local/bin/update
claude-speak-toggle	$HOME/.local/bin/claude-speak-toggle
EOF

# Abbreviations expand ahead of functions and PATH, so a seeded abbr that
# collides with either silently wins. scripts/check-collisions.sh catches that
# statically; this confirms the seeds actually took effect at runtime.
info "Testing abbreviations..."
if clean_zsh -i -c 'whence -w abbr' >/dev/null 2>&1; then
  seeded=$(clean_zsh -i -c 'abbr list-abbreviations' 2>/dev/null | wc -l | tr -d ' ')
  if [ "$seeded" -gt 0 ]; then
    success "zsh-abbr loaded with $seeded abbreviations"
  else
    error "zsh-abbr loaded but seeded no abbreviations"
  fi

  # The store is machine-local state this repo does not track, so the only way
  # to keep it from accumulating shadowing entries is for .zshrc to reconcile
  # it. Seed a stale abbr into a throwaway store and check it does not survive.
  ABBR_HOME=$(mktemp -d)
  mkdir -p "$ABBR_HOME/zsh-abbr"
  printf 'abbr "gc"="git commit"\nabbr "zzstale"="echo stale"\n' \
    > "$ABBR_HOME/zsh-abbr/user-abbreviations"

  survivors=$(XDG_CONFIG_HOME="$ABBR_HOME" clean_zsh -i -c \
    'abbr list-abbreviations' 2>/dev/null | grep -cE '^(gc|zzstale)$' || true)
  if [ "$survivors" -eq 0 ]; then
    success "Undeclared abbreviations are erased on startup"
  else
    error "$survivors undeclared abbreviation(s) survived startup"
  fi
  rm -rf "$ABBR_HOME"
else
  info "zsh-abbr not installed; abbreviation reconciliation not covered"
fi

# Syntax-checking a config only proves it is well-formed TOML or INI. These
# hand the file to the tool that actually consumes it, which is what catches an
# unknown key, a bad value, or a broken include.
info "Testing configs parse with their own tools..."

if git config --list --file "$HOME/.config/git/config" >/dev/null 2>&1; then
  success "git reads ~/.config/git/config"
else
  error "git cannot read ~/.config/git/config"
fi

# -G resolves the config for a host and prints it; it does not connect
if ssh -G github.com >/dev/null 2>&1; then
  success "ssh reads ~/.ssh/config"
else
  error "ssh cannot read ~/.ssh/config"
fi

if command -v jj >/dev/null 2>&1; then
  if jj config list --user >/dev/null 2>&1; then
    success "jj reads ~/.config/jj/config.toml"
  else
    error "jj cannot read ~/.config/jj/config.toml"
  fi
else
  info "jj not installed; its config is not covered"
fi

# Test mise
info "Testing mise..."
if mise --version &>/dev/null; then
  success "Mise is functional"

  # Check if Node.js was installed
  if mise list | grep -q "node"; then
    success "Node.js is installed via mise"
  else
    info "Node.js not installed (expected in CI)"
  fi
else
  error "Mise is not functional"
fi

# Test tmux configuration
info "Testing tmux..."
if tmux -f ~/.config/tmux/tmux.conf new-session -d -s validate; then
  tmux kill-session -t validate
  success "Tmux configuration is valid"
else
  error "Tmux configuration has errors"
fi

# Test Neovim
info "Testing Neovim..."
if nvim --version &>/dev/null; then
  success "Neovim is installed"

  # Basic config test
  if nvim --headless -c "quit" 2>/dev/null; then
    success "Neovim starts without errors"
  else
    info "Neovim may need plugin installation"
  fi
else
  error "Neovim is not installed"
fi

# Summary
echo ""
if [ ${#FAILURES[@]} -gt 0 ]; then
  echo "❌ ${#FAILURES[@]} validation check(s) failed:"
  for failure in "${FAILURES[@]}"; do
    echo "  - $failure"
  done
  exit 1
fi

success "All validation checks passed!"
echo "The dotfiles installation appears to be successful."
