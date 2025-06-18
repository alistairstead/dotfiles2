#!/usr/bin/env bash
# Unified Setup Script for macOS dotfiles

set -e

# Color output helpers
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

# Keep sudo alive
sudo -v
while true; do
  sudo -n true
  sleep 60
  kill -0 "$$" || exit
done 2>/dev/null &

info "Starting dotfiles setup..."

# 1. Install Xcode Command Line Tools (if not in CI)
if [ -z "$CI" ] && ! xcode-select --print-path &>/dev/null; then
  info "Installing Xcode Command Line Tools..."
  xcode-select --install
  # Wait for installation to complete
  until xcode-select --print-path &>/dev/null; do
    sleep 5
  done
  success "Xcode Command Line Tools installed"
fi

# 2. Install Homebrew
if ! command -v brew &>/dev/null; then
  info "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

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

# 3. Install packages from Brewfile
if [ -f "Brewfile" ]; then
  info "Installing packages from Brewfile..."
  brew bundle --file=Brewfile
  success "Homebrew packages installed"
else
  error "Brewfile not found"
fi

# 4. Run macOS system setup
if [ -f "scripts/macos-setup.sh" ]; then
  info "Configuring macOS system settings..."
  ./scripts/macos-setup.sh
  success "macOS settings configured"
fi

# 5. Create necessary directories
info "Creating directories..."
mkdir -p ~/.config
mkdir -p ~/.local/bin
mkdir -p ~/.tmux/plugins

# 6. Install GNU Stow if not already installed
if ! command -v stow &>/dev/null; then
  fail "GNU Stow is required but not installed. Please install it via Homebrew."
fi

# 7. Stow dotfiles
info "Creating symlinks with GNU Stow..."
STOW_FOLDERS=(
  "aerospace"
  "direnv"
  "gh"
  "git"
  "granted"
  "ghostty"
  "nvim"
  "ssh"
  "starship"
  "tmux"
  "wezterm"
  "yabai"
  "zsh"
)

for folder in "${STOW_FOLDERS[@]}"; do
  if [ -d "$folder" ]; then
    info "Stowing $folder..."
    stow -v "$folder"
  else
    error "Directory $folder not found, skipping..."
  fi
done
success "Dotfiles linked"

# 8. Install Zap (Zsh plugin manager)
if [ ! -d "$HOME/.local/share/zap" ]; then
  info "Installing Zap..."
  zsh <(curl -s https://raw.githubusercontent.com/zap-zsh/zap/master/install.zsh) --branch release-v1
  success "Zap installed"
fi

# 9. Setup asdf plugins
if command -v asdf &>/dev/null; then
  info "Setting up asdf plugins..."

  # Create completions directory
  mkdir -p "${ASDF_DATA_DIR:-$HOME/.asdf}/completions"
  asdf completion zsh >"${ASDF_DATA_DIR:-$HOME/.asdf}/completions/_asdf"

  # Add plugins (ignore if already installed)
  plugins=(erlang elixir nodejs pnpm bun postgres direnv)
  for plugin in "${plugins[@]}"; do
    if ! asdf plugin list | grep -q "^$plugin$"; then
      info "Adding asdf plugin: $plugin"
      asdf plugin add "$plugin"
    fi
  done
  success "asdf plugins configured"
fi

# 10. Install tmux plugin manager
if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
  info "Installing tmux plugin manager..."
  git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
  ~/.tmux/plugins/tpm/bin/install_plugins
  success "tmux plugins installed"
fi

# 11. Set default shell to zsh (if not already)
if [ "$SHELL" != "/bin/zsh" ]; then
  info "Setting default shell to zsh..."
  chsh -s /bin/zsh
  success "Default shell set to zsh"
fi

# 12. Final PATH setup
info "Setting up PATH..."
if ! grep -q "/opt/homebrew/bin" ~/.zshenv 2>/dev/null; then
  cat >>~/.zshenv <<EOF

# Homebrew PATH
eval "\$(/opt/homebrew/bin/brew shellenv)"
export PATH="/opt/homebrew/opt/mysql-client@8.4/bin:\$PATH"
export PATH="/opt/homebrew/opt/trash/bin:\$PATH"
EOF
fi

success "Setup complete! Please restart your terminal or run: source ~/.zshenv"

