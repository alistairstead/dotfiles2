{config, lib, pkgs, ... }: {
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
        pipx
        (lua5_1.withPackages(ps: with ps; [
          luarocks 
          luajit
        ]))
        viu
        stylua
        ripgrep
        nil
      ];

      programs.ripgrep = {
        enable = true;
      };

      home.sessionPath = [
        "$HOME/.cargo/bin"
        "$HOME/.local/share/nvim/mason/bin"
        "$HOME/.local/bin"
      ];
    };
  };
}
