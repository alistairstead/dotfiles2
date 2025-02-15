{ config, pkgs, lib, ... }: {
  options.node.enable = lib.mkEnableOption "Node tools.";
  config = lib.mkIf config.node.enable {
    home-manager.users.${config.user} = {
      home.shellAliases = {
        pn = "pnpm";
      };
      home.packages = with pkgs; [
        nodejs
        corepack
        deno
      ];
    };
  };
}
