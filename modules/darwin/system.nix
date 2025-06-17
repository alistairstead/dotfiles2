{ config, pkgs, lib , ... }: {
  config = lib.mkIf pkgs.stdenv.isDarwin {
    nix.enable = false;
    # This setting only applies to Darwin, different on NixOS
    nix.gc.interval = {
      Hour = 12;
      Minute = 15;
      Day = 1;
    };

    security.pam.enablePamReattach = true;
    security.pam.services.sudo_local.touchIdAuth = true;
    system.primaryUser = "alistairstead";
  };
}
