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
        vectorcode
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
      programs.neovim = {
        enable = true;

        plugins = with pkgs.vimPlugins; [
          {
            plugin = sqlite-lua;
            config = "let g:sqlite_clib_path = '${pkgs.sqlite.out}/lib/libsqlite3.dylib'";
          }
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
