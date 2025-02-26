{ config, lib, pkgs, ... }: let
  dphpunit = pkgs.writeShellScriptBin "dphpunit" ''
    ${builtins.readFile ./dphpunit}
  '';
in {
  options.php.enable = lib.mkEnableOption "PHP tools.";
  config = lib.mkIf config.php.enable {
    home-manager.users.${config.user} = {
      home.packages = [
        dphpunit
      ];
    };
  };
}
