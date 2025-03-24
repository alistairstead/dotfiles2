{ config, lib, pkgs, ... }: let
  dphpunit = pkgs.writeShellScriptBin "dphpunit" ''
    ${builtins.readFile ./dphpunit}
  '';
  dphp = pkgs.writeShellScriptBin "dphp" ''
    ${builtins.readFile ./dphp}
  '';
  dprox = pkgs.writeShellScriptBin "dprox" ''
    ${builtins.readFile ./dprox}
  '';
in {
  options.php.enable = lib.mkEnableOption "PHP tools.";
  config = lib.mkIf config.php.enable {
    home-manager.users.${config.user} = {
      home.packages = [
        dprox
        dphpunit
        dphp
      ];
    };
  };
}
