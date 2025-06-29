#!/usr/bin/env bash
# Unified Install Script for macOS dotfiles
# Combines setup.sh and install.sh into a single, comprehensive installer

set -e

# =====================================
# Helper Functions
# =====================================

info() {
  printf "\r  [ \033[00;34m..\033[0m ] %s\n" "$1"
}

success() {
  printf "\r\033[2K  [ \033[00;32mOK\033[0m ] %s\n" "$1"
}

error() {
  printf "\r\033[2K  [\033[0;31mFAIL\033[0m] %s\n" "$1"
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

# Detect if running in CI
if [ -n "$CI" ]; then
  info "Running in CI environment"
else
  info "Running in interactive mode"
fi

# =====================================
# Sudo Setup (skip in CI)
# =====================================

if [ -z "$CI" ]; then
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
  if [ -z "$CI" ]; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  else
    NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  fi

  # Add Homebrew to PATH for Apple Silicon Macs
  if [ -f "/opt/homebrew/bin/brew" ]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  fi
  success "Homebrew installed"
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
  if [ -n "$CI" ]; then
    # In CI, use a minimal Brewfile if it exists
    if [ -f ".github/test/Brewfile.ci" ]; then
      info "Using CI-specific Brewfile"
      brew bundle --file=.github/test/Brewfile.ci
    else
      # Install only essential packages in CI
      brew bundle --file=Brewfile || true
    fi
  else
    brew bundle --file=Brewfile
  fi
  success "Homebrew packages installed"
else
  error "Brewfile not found"
fi

# =====================================
# 4. macOS System Settings
# =====================================

if [ -z "$CI" ] && [ -f "scripts/macos-setup.sh" ]; then
  info "Configuring macOS system settings..."
  ./scripts/macos-setup.sh
  success "macOS settings configured"
else
  info "Skipping macOS system settings (CI environment or script not found)"
fi

# =====================================
# 5. Create Required Directories
# =====================================

info "Creating required directories..."
mkdir -p ~/.config
mkdir -p ~/.local/bin
mkdir -p ~/.tmux/plugins
success "Directories created"

# =====================================
# 6. GNU Stow Setup
# =====================================

if ! command -v stow &>/dev/null; then
  fail "GNU Stow is required but not installed. Please install it via Homebrew."
fi

info "Creating symlinks with GNU Stow..."

# Define stow folders
STOW_FOLDERS=(
  "aerospace"
  "atuin"
  "bash"
  "bin"
  "direnv"
  "gh"
  "git"
  "granted"
  "ghostty"
  "mise"
  "nvim"
  "ssh"
  "starship"
  "tmux"
  "wezterm"
  "yabai"
  "zsh"
)

# Stow each folder
for folder in "${STOW_FOLDERS[@]}"; do
  if [ -d "$folder" ]; then
    info "Stowing $folder..."
    if [ -n "$CI" ]; then
      # In CI, adopt existing files to avoid conflicts
      stow -v --adopt "$folder" || error "Failed to stow $folder"
    else
      stow -v "$folder" || error "Failed to stow $folder"
    fi
  else
    error "Directory $folder not found, skipping..."
  fi
done
success "Dotfiles linked"

# =====================================
# 7. Zap (Zsh Plugin Manager)
# =====================================

if [ ! -d "$HOME/.local/share/zap" ]; then
  info "Installing Zap..."
  if [ -z "$CI" ]; then
    zsh <(curl -s https://raw.githubusercontent.com/zap-zsh/zap/master/install.zsh) --branch release-v1
  else
    zsh <(curl -s https://raw.githubusercontent.com/zap-zsh/zap/master/install.zsh) --branch release-v1 --keep-zshrc || true
  fi
  success "Zap installed"
else
  info "Zap already installed"
fi

# =====================================
# 8. Mise Runtime Management
# =====================================

if ! command -v mise &>/dev/null; then
  info "Installing mise..."
  brew install mise
fi

info "Setting up mise for runtime management..."

# Install common development tools with mise
if [ -z "$CI" ]; then
  mise use --global node@lts
  mise use --global python@latest
  mise use --global ruby@latest
  mise use --global go@latest
  mise use --global pnpm@latest
  mise use --global bun@latest
else
  # In CI, only install essentials
  mise use --global node@lts || true
fi

success "Mise configured - will auto-read .nvmrc, .ruby-version, .tool-versions, etc."

# =====================================
# 9. Tmux Plugin Manager
# =====================================

if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
  info "Installing tmux plugin manager..."
  git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
  ~/.tmux/plugins/tpm/bin/install_plugins || true
  success "Tmux plugins installed"
else
  info "Tmux plugin manager already installed"
fi

# =====================================
# 10. Shell Configuration
# =====================================

if [ -z "$CI" ] && [ "$SHELL" != "/bin/zsh" ]; then
  info "Setting default shell to zsh..."
  chsh -s /bin/zsh
  success "Default shell set to zsh"
fi

# =====================================
# 11. PATH Setup
# =====================================

info "Setting up PATH..."
if ! grep -q "/opt/homebrew/bin" ~/.zshenv 2>/dev/null; then
  cat >>~/.zshenv <<EOF

# Homebrew PATH
eval "\$(/opt/homebrew/bin/brew shellenv)"
export PATH="/opt/homebrew/opt/mysql-client@8.4/bin:\$PATH"
export PATH="/opt/homebrew/opt/trash/bin:\$PATH"
export PATH="\$HOME/.local/bin:\$PATH"
EOF
  success "PATH configured"
else
  info "PATH already configured"
fi

# =====================================
# Final Steps
# =====================================

success "Installation complete!"
echo ""
info "Next steps:"
info "1. Restart your terminal or run: source ~/.zshenv && source ~/.zshrc"
info "2. Run 'mise doctor' to verify runtime management"

# Run validation in CI
if [ -n "$CI" ] && [ -f ".github/test/validate.sh" ]; then
  info "Running CI validation..."
  bash .github/test/validate.sh
fi

