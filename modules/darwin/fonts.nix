{ config, pkgs , lib , ... }: {
  home-manager.users.${config.user} = lib.mkIf pkgs.stdenv.isDarwin {
    home.packages = with pkgs; [ monaspace ];

    # programs.alacritty.settings = {
    #   font.normal.family = "Monaspace Neon ExtraLight";
    # };
    #
    # programs.kitty.font = {
    #   package = (pkgs.nerdfonts.override { fonts = [ "Monaspace Neon ExtraLight" ]; });
    #   name = "Monaspace Neon ExtraLight";
    # };
  };
}
