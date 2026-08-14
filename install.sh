#!/usr/bin/env bash
# Unified Install Script for macOS dotfiles
# Combines setup.sh and install.sh into a single, comprehensive installer
#
# Usage: install.sh [--dry-run]

set -e

DRY_RUN=${DRY_RUN:-}

case "${1:-}" in
  -n | --dry-run)
    DRY_RUN=1
    ;;
  -h | --help)
    cat <<'USAGE'
Usage: install.sh [--dry-run]

  --dry-run, -n  Report what the install would change and change nothing.
                 Uses each tool's own dry run where one exists: `brew bundle
                 check` for packages, `stow --simulate` for symlinks, and
                 macos-setup.sh --dry-run for system defaults.

Environment: DRY_RUN=1 does the same.
USAGE
    exit 0
    ;;
  "") ;;
  *)
    echo "Unknown option: $1" >&2
    exit 1
    ;;
esac

# =====================================
# Helper Functions
# =====================================

# Colour and cursor control only when writing to a terminal. Piped into a file
# or a CI log they are noise, and CI logs are where this output gets read.
if [ -t 1 ]; then
  C_BLUE=$'\033[00;34m'
  C_GREEN=$'\033[00;32m'
  C_RED=$'\033[0;31m'
  C_OFF=$'\033[0m'
  C_LINE=$'\r\033[2K'
else
  C_BLUE=""
  C_GREEN=""
  C_RED=""
  C_OFF=""
  C_LINE=""
fi

info() {
  printf "%s  [ %s..%s ] %s\n" "$C_LINE" "$C_BLUE" "$C_OFF" "$1"
}

success() {
  printf "%s  [ %sOK%s ] %s\n" "$C_LINE" "$C_GREEN" "$C_OFF" "$1"
}

error() {
  printf "%s  [%sFAIL%s] %s\n" "$C_LINE" "$C_RED" "$C_OFF" "$1"
}

fail() {
  error "$1"
  exit 1
}

# =====================================
# Environment Detection
# =====================================

info "macOS Dotfiles Installer"
info "========================"

# Set so `[ -n "$VAR" ]` is safe when they are unset
CI=${CI:-}
DOTFILES_FULL_INSTALL=${DOTFILES_FULL_INSTALL:-}

# Detect if running in CI
if [ -n "$CI" ]; then
  info "Running in CI environment"
else
  info "Running in interactive mode"
fi

# =====================================
# Sudo Setup (skip in CI)
# =====================================

if [ -z "$CI" ] && [ -z "$DRY_RUN" ]; then
  # Keep sudo alive
  sudo -v
  while true; do
    sudo -n true
    sleep 60
    kill -0 "$$" || exit
  done 2>/dev/null &
fi

# =====================================
# 1. Xcode Command Line Tools
# =====================================

if [ -z "$CI" ] && ! xcode-select --print-path &>/dev/null; then
  info "Installing Xcode Command Line Tools..."
  xcode-select --install
  # Wait for installation to complete
  until xcode-select --print-path &>/dev/null; do
    sleep 5
  done
  success "Xcode Command Line Tools installed"
else
  info "Xcode Command Line Tools already installed or running in CI"
fi

# =====================================
# 2. Homebrew Installation
# =====================================

if ! command -v brew &>/dev/null; then
  info "Installing Homebrew..."
  if [ -n "$DRY_RUN" ]; then
    info "  would install Homebrew"
  elif [ -z "$CI" ]; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  else
    NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  fi

  # Add Homebrew to PATH for Apple Silicon Macs
  if [ -f "/opt/homebrew/bin/brew" ]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  fi
  success "Homebrew installed"
elif [ -n "$DRY_RUN" ]; then
  info "Homebrew already installed; would run brew update && brew upgrade"
  info "  outdated: $(brew outdated --quiet | tr '\n' ' ')"
else
  info "Homebrew already installed, updating..."
  brew update
  brew upgrade
fi

# =====================================
# 3. Install Packages from Brewfile
# =====================================

if [ -f "Brewfile" ]; then
  info "Installing packages from Brewfile..."
  # Per-push CI installs a subset to stay fast; the scheduled full-install
  # workflow sets DOTFILES_FULL_INSTALL to exercise the real Brewfile.
  BREWFILE=Brewfile
  if [ -n "$CI" ] && [ -z "$DOTFILES_FULL_INSTALL" ] && [ -f ".github/test/Brewfile.ci" ]; then
    info "Using CI-specific Brewfile"
    BREWFILE=.github/test/Brewfile.ci
  fi

  # Homebrew refuses to load formulae from an untrusted third-party tap. A tap
  # declared in the Brewfile is one you have chosen to use, so trust it here
  # rather than leaving the formulae silently unavailable.
  if brew trust --help >/dev/null 2>&1; then
    while IFS= read -r tap; do
      [ -n "$tap" ] || continue
      if [ -n "$DRY_RUN" ]; then
        info "  would tap and trust $tap"
        continue
      fi
      brew tap "$tap" >/dev/null 2>&1 || error "Could not tap $tap"
      brew trust "$tap" >/dev/null 2>&1 || error "Could not trust $tap"
    done < <(sed -n 's/^tap "\([^"]*\)".*/\1/p' "$BREWFILE")
  fi

  if [ -n "$DRY_RUN" ]; then
    # `check` reports the unmet dependencies without installing any of them
    if brew bundle check --file="$BREWFILE" --verbose; then
      info "  every $BREWFILE dependency is already installed"
    fi
  else
    brew bundle --file="$BREWFILE"
    success "Homebrew packages installed"
  fi
else
  fail "Brewfile not found"
fi

# =====================================
# 4. macOS System Settings
# =====================================

if { [ -z "$CI" ] || [ -n "$DOTFILES_FULL_INSTALL" ]; } && [ -f "scripts/macos-setup.sh" ]; then
  info "Configuring macOS system settings..."
  if [ -n "$DRY_RUN" ]; then
    ./scripts/macos-setup.sh --dry-run
  else
    ./scripts/macos-setup.sh
    success "macOS settings configured"
  fi
else
  info "Skipping macOS system settings (CI environment or script not found)"
fi

# =====================================
# 5. Create Required Directories
# =====================================

info "Creating required directories..."
if [ -n "$DRY_RUN" ]; then
  for dir in ~/.config ~/.local/bin ~/.tmux/plugins; do
    [ -d "$dir" ] || info "  would create $dir"
  done
else
  mkdir -p ~/.config
  mkdir -p ~/.local/bin
  mkdir -p ~/.tmux/plugins
  success "Directories created"
fi

# =====================================
# 6. GNU Stow Setup
# =====================================

if ! command -v stow &>/dev/null; then
  fail "GNU Stow is required but not installed. Please install it via Homebrew."
fi

info "Creating symlinks with GNU Stow..."

# The package list is derived from the directories on disk; see the file for
# what counts as a package and why karabiner and scripts are excluded.
# shellcheck source=scripts/stow-modules.sh
. ./scripts/stow-modules.sh

# Move aside any real file sitting where a package wants a symlink. stow refuses
# to link over a regular file and aborts the whole package, which would fail the
# install outright. Tools that write their own default config on first run hit
# this routinely: atuin creates ~/.config/atuin/config.toml the first time it is
# invoked, so any machine that used the tool before adopting these dotfiles has
# one waiting. The original is kept as .bak rather than deleted; nothing here
# reads it again.
#
# Only regular files are touched. Existing symlinks are left to stow, which
# re-points its own and reports a genuine conflict for anything else.
resolve_stow_conflicts() {
  local folder=$1 rel target moved=0
  while IFS= read -r rel; do
    target="$HOME/${rel#"$folder"/}"
    [ -e "$target" ] || continue
    [ -L "$target" ] && continue
    [ -d "$target" ] && continue
    if [ -n "$DRY_RUN" ]; then
      info "  would back up $target -> $target.bak"
    else
      mv "$target" "$target.bak" || fail "Could not back up $target"
      info "  backed up $target -> $target.bak"
    fi
    moved=$((moved + 1))
  done < <(git ls-files "$folder")
  [ "$moved" -eq 0 ] || info "  $moved pre-existing file(s) moved aside"
}

while IFS= read -r folder; do
  info "Stowing $folder..."
  [ -n "$CI" ] || resolve_stow_conflicts "$folder"
  if [ -n "$DRY_RUN" ]; then
    # --simulate reports the links it would make and touches nothing
    stow --simulate -v "$folder" 2>&1 | sed 's/^/    /' || true
  elif [ -n "$CI" ]; then
    # In CI, adopt existing files to avoid conflicts
    stow -v --adopt "$folder" || fail "Failed to stow $folder"
  else
    stow -v "$folder" || fail "Failed to stow $folder"
  fi
done <<<"$(stow_modules .)"

if [ -n "$CI" ]; then
  # --adopt moves a pre-existing target into the repo and links back to it, so
  # the runner's own dotfiles would silently replace ours and every check
  # afterwards would be testing the wrong content. Restore what is committed;
  # the symlinks stay, now pointing at our files.
  git checkout -- .
fi
success "Dotfiles linked"

# =====================================
# 6b. Compile Claude Code TTS binary
# =====================================

if [ -f "$HOME/.claude/hooks/speak.swift" ]; then
  info "Compiling Claude Code TTS binary..."
  if [ -n "$DRY_RUN" ]; then
    info "  would compile ~/.claude/hooks/speak from speak.swift"
  else
    swiftc -o "$HOME/.claude/hooks/speak" "$HOME/.claude/hooks/speak.swift" -framework AVFoundation 2>/dev/null \
      && success "TTS binary compiled" \
      || error "Failed to compile TTS binary (say fallback will be used)"
  fi
else
  info "Skipping TTS binary (speak.swift not found)"
fi

# =====================================
# 7. Mise Runtime Management
# =====================================

if ! command -v mise &>/dev/null; then
  info "Installing mise..."
  if [ -n "$DRY_RUN" ]; then
    info "  would brew install mise"
  else
    brew install mise
  fi
fi

info "Setting up mise for runtime management..."

# The tools are declared in mise/.config/mise/config.toml, which stow links to
# ~/.config/mise/config.toml. `mise use --global` would rewrite that file, i.e.
# write through the symlink and into this repo, so install what is declared
# rather than redeclaring it here.
if [ -n "$DRY_RUN" ]; then
  # Lists the declared tools and marks the ones not yet installed
  mise ls --missing 2>/dev/null | sed 's/^/    missing: /' || info "  would run mise install"
elif [ -z "$CI" ]; then
  mise install
else
  # In CI, one runtime is enough to prove mise works
  mise install node || true
fi

success "Mise configured - will auto-read .nvmrc, .ruby-version, .tool-versions, etc."

# =====================================
# 8. Tmux Plugin Manager
# =====================================

if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
  info "Installing tmux plugin manager..."
  if [ -n "$DRY_RUN" ]; then
    info "  would clone tpm into ~/.tmux/plugins/tpm and install plugins"
  else
    git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
    ~/.tmux/plugins/tpm/bin/install_plugins || true
  fi
  success "Tmux plugins installed"
else
  info "Tmux plugin manager already installed"
fi

# =====================================
# 9. Shell Configuration
# =====================================

if [ -z "$CI" ] && [ "$SHELL" != "/bin/zsh" ]; then
  info "Setting default shell to zsh..."
  if [ -n "$DRY_RUN" ]; then
    info "  would change the login shell from $SHELL to /bin/zsh"
  else
    chsh -s /bin/zsh
    success "Default shell set to zsh"
  fi
fi

# PATH is not configured here. It is built by shell/.config/shell/path.sh,
# which .zshenv and .profile source. Appending to ~/.zshenv would write
# through the stow symlink and into this repo.

# =====================================
# Final Steps
# =====================================

success "Installation complete!"
echo ""
info "Next steps:"
info "1. Restart your terminal or run: source ~/.zshenv && source ~/.zshrc"
info "2. Run 'mise doctor' to verify runtime management"
info "3. Run '.github/test/validate.sh' to check the install"

