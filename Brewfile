# Homebrew Bundle file
# Run with: brew bundle

# Taps. install.sh taps and `brew trust`s each of these before running
# brew bundle: declaring a tap here is the decision to use it, and Homebrew
# refuses to load formulae from an untrusted third-party tap.
#
# Only taps whose packages are referenced by a bare name need a line here.
# dagger/tap and koekeishiya/formulae are absent on purpose: their entries are
# written tap-qualified further down, which implies the tap on its own.
tap "common-fate/granted"
tap "olets/tap"
tap "rsteube/tap" # carapace extensions

# Core utilities
brew "coreutils"
brew "autoconf"
brew "openssl"
brew "readline"
brew "libtool"
brew "unixodbc"
brew "unzip"
brew "gpg"
brew "bison"
brew "cmake"

# Development tools
brew "git"
brew "git-delta"
brew "git-filter-repo"
brew "gh"
brew "vim"
brew "neovim"
brew "wget"
brew "curl"
brew "act"       # Run GitHub Actions locally

# Cloud and infrastructure
brew "awscli"
brew "granted"
brew "railway"

# Terminal tools
brew "atuin"     # Shell history in SQLite; owns ctrl-r and the up arrow
brew "bash"      # macOS ships 3.2; carapace in .bashrc needs >= 4.4
brew "bat"
brew "btop"
brew "direnv"
brew "eza"
brew "fzf"
brew "gum"
brew "jq"
brew "trash"
brew "starship"
brew "stow"
brew "terminal-notifier"
brew "zoxide"
brew "fd"
brew "ripgrep"
brew "tree"
brew "yq"
brew "tldr"
brew "navi"    # Interactive cheatsheet

# Zsh plugins (via Homebrew)
brew "zsh-syntax-highlighting"
brew "zsh-completions"
brew "zsh-autosuggestions"
brew "zsh-abbr"
brew "fzf-tab"

# Enhanced shell tools
brew "just"      # Modern command runner
brew "carapace"  # Multi-shell command argument completion
# Carapace extensions. Nothing sources these: carapace-bin does an exec.LookPath
# for each and delegates over its bridge protocol when the binary is on PATH, so
# installing is the whole setup. carapace-aws parses botocore service definitions
# for real descriptions and falls back to aws_completer; carapace-magick covers
# magick, montage, mogrify, compare and identify.
brew "carapace-aws"
brew "carapace-magick"

# Database tools
brew "sqlite"

# Development utilities
brew "gnu-sed"
brew "stylua"
brew "taplo"     # TOML formatter and language server
brew "d2"        # Diagram scripting language
brew "jj"
brew "jjui"
brew "lazydocker"
brew "lazygit"
brew "fontconfig"
brew "imagemagick"
brew "sox"       # Audio processing, used by claude speak hooks
brew "whisper-cpp" # Local speech-to-text
# Not declared: omihirofumi/tap/ww, the Wispr Flow CLI that zsh/.zshrc evals as
# `ww init zsh`. The formula builds from source and does not compile against zig
# 0.16, so declaring it fails `brew bundle` outright. The .zshrc block is guarded
# on the binary, so a machine without it just has no Wispr Flow integration.
# Restore the line once the formula builds again.
brew "shellcheck"
brew "uv"
brew "pipx"      # Backs the pipx: backend in mise/config.toml
brew "nmap"

# Languages and runtimes not managed by mise
brew "zig"
brew "luarocks"
brew "playwright-cli"

# Advanced development tools
brew "mise"

# Window management
brew "koekeishiya/formulae/yabai"
brew "sleepwatcher"

# Casks (GUI applications)
cask "1password@beta"
cask "1password-cli@beta"
cask "bartender"
cask "choosy"
cask "cleanmymac"
cask "cleanshot"
cask "dagger/tap/container-use"
cask "discord"
cask "dockdoor"
cask "figma"
cask "font-fira-code-nerd-font"
cask "font-monaspace"
cask "font-symbols-only-nerd-font"
cask "font-victor-mono"
cask "gcloud-cli"
cask "ghostty"
cask "github@beta"
cask "google-chrome"
cask "home-assistant"
cask "inkscape"
cask "jordanbaird-ice"
# Wired into git/config as difftool and mergetool (ksdiff). The copy on this
# machine was installed by hand; brew bundle passes --adopt, so it takes it over
cask "kaleidoscope"
cask "karabiner-elements"
cask "linearmouse"
cask "nordvpn"
cask "obsidian"
cask "orbstack"
cask "raycast"
cask "readdle-spark"
cask "sizzy"
cask "slack"
cask "todoist-app"
cask "typewhisper"
cask "zed"
cask "zed@preview"
# Clock screensaver
cask "fliqlo"

# Mac App Store apps
mas "1Password for Safari", id: 1569813296
