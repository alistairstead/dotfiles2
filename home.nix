# home.nix
# home-manager switch 

{ config, pkgs, ... }:
{
  programs.home-manager.enable = true;
  home.stateVersion = "24.11"; # Please read the comment before changing.

  # Makes sense for user specific applications that shouldn't be available system-wide
  home.packages = [
    pkgs.git
  ];

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    ".gitconfig".source = ~/dotfiles/git/.gitconfig;
    ".gitignore".source = ~/dotfiles/git/.gitignore;
    # ".zshrc".source = ~/dotfiles/zshrc/.zshrc;
    # ".config/wezterm".source = ~/dotfiles/wezterm;
    # ".config/skhd".source = ~/dotfiles/skhd;
    # ".config/starship".source = ~/dotfiles/starship;
    # ".config/zellij".source = ~/dotfiles/zellij;
    # ".config/nvim".source = ~/dotfiles/nvim;
    # ".config/nix".source = ~/dotfiles/nix;
    # ".config/nix-darwin".source = ~/dotfiles/nix-darwin;
    # ".config/tmux".source = ~/dotfiles/tmux;
  };

  home.sessionVariables = { };

  home.sessionPath = [
    "/run/current-system/sw/bin"
    "$HOME/.nix-profile/bin"
  ];
  programs.zsh = {
    enable = true;
    initExtra = ''
      # Add any additional configurations here
      export PATH=/run/current-system/sw/bin:$HOME/.nix-profile/bin:$PATH
      if [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then
        . '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
      fi
    '';
  };
}
