{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.security.pam;
in
{
  options = {
    security.pam = {
      enablePamReattach = mkEnableOption "" // {
        description = ''
          Enable re-attaching a program to the user's bootstrap session.
          This allows programs like tmux and screen that run in the background to
          survive across user sessions to work with PAM services that are tied to the
          bootstrap session.
          When enabled, this option adds the following line to /etc/pam.d/sudo_local:
          ```
          auth       optional       /path/in/nix/store/lib/pam/pam_reattach.so"
          ```
        '';
      };
    };
  };

  config =
  let
    isPamEnabled = (cfg.enableSudoTouchIdAuth || cfg.enablePamReattach);
  in
  {
    environment.etc."pam.d/sudo_local" = {
      enable = isPamEnabled;
      text = lib.strings.concatStringsSep "\n" [
        (lib.optionalString cfg.enablePamReattach "auth       optional       ${pkgs.pam-reattach}/lib/pam/pam_reattach.so")
        (lib.optionalString cfg.enableSudoTouchIdAuth "auth       sufficient     pam_tid.so")
      ];
    };
  };
}
