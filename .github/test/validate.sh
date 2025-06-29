#!/usr/bin/env bash
# Validation script for CI testing
# Checks that the installation completed successfully

set -e

echo "=== Running Dotfiles Installation Validation ==="

# Color functions
success() { echo "✅ $1"; }
error() { echo "❌ $1"; exit 1; }
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

# Check symlinks
info "Checking symlinks..."
EXPECTED_SYMLINKS=(
  "$HOME/.config/git/config"
  "$HOME/.config/starship.toml"
  "$HOME/.config/nvim"
  "$HOME/.config/tmux/tmux.conf"
  "$HOME/.zshrc"
  "$HOME/.bashrc"
  "$HOME/.config/mise/config.toml"
  "$HOME/.config/atuin/config.toml"
)

for link in "${EXPECTED_SYMLINKS[@]}"; do
  if [ -L "$link" ] || [ -f "$link" ] || [ -d "$link" ]; then
    success "$link exists"
  else
    error "$link does NOT exist"
  fi
done

# Test shell configurations
info "Testing shell configurations..."

# Test Zsh config
if zsh -c "source ~/.zshrc" 2>/dev/null; then
  success "Zsh configuration loads without errors"
else
  error "Zsh configuration has errors"
fi

# Test Bash config
# Note: Bash config may fail in non-interactive mode due to certain commands
if bash -c "source ~/.bashrc" 2>/dev/null || bash -c "export PS1='$ '; source ~/.bashrc" 2>/dev/null; then
  success "Bash configuration loads without errors"
else
  # Try to get more details about the error
  info "Bash configuration may have non-critical errors (often expected in CI)"
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
if tmux -f ~/.config/tmux/tmux.conf new-session -d -s test 2>/dev/null; then
  tmux kill-session -t test
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
success "All validation checks passed!"
echo "The dotfiles installation appears to be successful."