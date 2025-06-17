{ config, pkgs , lib , ... }: {
  # Homebrew - Mac-specific packages that aren't in Nix
  config = lib.mkIf pkgs.stdenv.isDarwin {
    # Requires Homebrew to be installed
    # system.activationScripts.preUserActivation.text = ''
    #   if ! xcode-select --version 2>/dev/null; then
    #     $DRY_RUN_CMD xcode-select --install
    #   fi
    #   if ! /opt/homebrew/bin/brew --version 2>/dev/null; then
    #     $DRY_RUN_CMD /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    #   fi
    # '';

    # Add homebrew paths to CLI path
    home-manager.users.${config.user} = {
      home.sessionPath = [
        "/opt/homebrew/bin/" 
        "/opt/homebrew/opt/trash/bin/"
      ];

      home.activation = {
        linkMysqlClient = ''
          run /opt/homebrew/bin/brew link --overwrite --force mysql-client@8.4
        '';
      };

    };

    environment = {
      systemPath = [ "/opt/homebrew/bin" ];
      variables = {
        HOMEBREW_NO_ANALYTICS = "1";
      };
    };


    homebrew = {
      enable = true;
      onActivation = {
        autoUpdate = false;
        cleanup = "zap"; # Uninstall all programs not declared
        upgrade = true;
      };
      global = {
        autoUpdate = false;
        brewfile = true; # Run brew bundle from anywhere
        lockfiles = false; # Don't save lockfile (since running from anywhere)
      };
      taps = [
        "neovim/neovim"
        "oven-sh/bun"
        "common-fate/granted"
        "nikitabobko/tap"
        "1password/tap"
        "koekeishiya/formulae"
      ];
      brews = [
        "coreutils" 
        "automake" 
        "autoconf" 
        "openssl"
        "libyaml" 
        "readline" 
        "libxslt" 
        "libtool" 
        "unixodbc"
        "unzip" 
        "gpg"
        "git"
        "vim"
        "wget"
        "curl"
        "awscli"
        "asdf"
        "bat"
        "btop"
        "direnv"
        "eza"
        "fzf"
        "gum"
        "granted"
        "htop"
        "jq"
        "trash" # Delete files and folders to trash instead of rm
        "mysql-client@8.4" # brew link --overwrite --force mysql-client@8.4
        "sqlite"
        "xh"
        "starship"
        "stow"
        "tmux"
        "neovim"
        "go"
        "gnu-sed"
        "pipx"
        "luarocks"
        "luajit"
        "viu"
        "stylua"
        "ripgrep"
        "nodejs"
        "corepack"
        "deno"
        "bun"
        "terraform"
        "terraform-ls"
        "tflint"
        "diff-so-fancy"
        "lazydocker"
        "lazysql"
        "lazygit"
        "prettierd"
        "yabai"
        "zoxide"
        "curl"
        "fastfetch"
        "fd"
        "fontconfig"
        "gum"
        "imagemagick"
        "yq"
        "ripgrep"
        "sesh"
        "sqlite"
        "tree"
        "unzip"
      ];
      casks = [
        "1password"
        "1password-cli"
        "aerospace"
        "bartender"
        "choosy" # Choose browser
        "cleanmymac" # Clean up macOS
        "cleanshot" # screen shots sorted
        "discord"
        "figma"
        "font-monaspace"
        "font-symbols-only-nerd-font" # Nerd Font with only symbols
        "github@beta"
        "ghostty"
        "google-chrome" # Chrome
        "home-assistant" # Home Assistant
        "inkscape"
        "karabiner-elements"
        "nordvpn"
        "obsidian"
        "orbstack"
        "raycast"
        "readdle-spark"
        "sizzy"
        "slack"
        "todoist"
      ];
      masApps = {
        "1Password for Safari" = 1569813296;
      };
      caskArgs = {
        appdir = "/Applications";
      };
    };
  };
}
