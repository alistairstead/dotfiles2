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
    globals
    inputs.home-manager.darwinModules.home-manager
    ../../modules/common
    ../../modules/darwin
    # inputs.mac-app-util.darwinModules.default
    {
      networking.hostName = "wombat";
      gui.enable = true;
      # charm.enable = true;
      # neovim.enable = true;
      discord.enable = true;
      dotfiles.enable = true;
      # terraform.enable = true;
      aws.enable = true;
      obsidian.enable = true;
      _1password.enable = true;
      slack.enable = true;
      wezterm.enable = true;
      raycast.enable = true;
      devenv.enable = true;
      node.enable = true;
      go.enable = true;
      aerospace.enable = true;
    }
  ];
}
