{ config, lib, pkgs, ... }:
{
  options = {
    neovim = {
      enable = lib.mkEnableOption {
        description = "Enable neovim.";
        default = false;
      };
    };
  };
  config = lib.mkIf (!config.ci.enable && config.gui.enable && config.neovim.enable) {
    home-manager.users.${config.user} = {
      home.packages = with pkgs; [
        go
        cargo
      ];

      programs.ripgrep = {
        enable = true;
      };
      programs.neovim = {
        extraPackages = with pkgs; [
          # LazyVim
          stylua
          # Telescope
          ripgrep
          nil
        ];

        plugins = with pkgs.vimPlugins; [
          lazy-nvim
        ];
      };

      home.sessionPath = [
        "$HOME/.cargo/bin"
        "$HOME/.local/share/nvim/mason/bin"
      ];

      # Normal LazyVim config here, see https://github.com/LazyVim/starter/tree/main/lua
      xdg.configFile."nvim/lua".source = ./lua;
      xdg.configFile."nvim/init.lua".source = ./init.lua;

    };
  };
}
