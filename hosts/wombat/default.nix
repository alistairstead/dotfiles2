# Wombat
# System configuration for my Macbook

{ inputs
, globals
, ...
}:

inputs.darwin.lib.darwinSystem {
  system = "aarch64-darwin";
  specialArgs = { };
  modules = [
    {
      config = {
        # minimal configuration for nix-darwin
        system = {
          stateVersion = 5;
        };
      };
    }
    ../../modules/common
    ../../modules/darwin
    globals
    inputs.home-manager.darwinModules.home-manager
    # inputs.mac-app-util.darwinModules.default
    {
      networking.hostName = "wombat";
      gui.enable = true;
      # atuin.enable = true;
      # charm.enable = true;
      # neovim.enable = true;
      discord.enable = true;
      dotfiles.enable = true;
      # terraform.enable = true;
      # python.enable = true;
      # rust.enable = true;
      # lua.enable = true;
      obsidian.enable = true;
      # 1Password is managed by Homebrew as it will not run on MacOS 
      # when installed from  Nix-pkgs
      # _1password.enable = true;
      slack.enable = true;
      wezterm.enable = true;
      raycast.enable = true;
    }
  ];
}
