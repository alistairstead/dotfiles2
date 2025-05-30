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
        bun
      ];
      home.sessionVariables = {
        NPM_CONFIG_PREFIX = "$HOME/.npm-global";
      };

      home.file.".npmrc".text = "prefix=${config.homePath}/.npm-global";

      home.sessionPath = [
        "$HOME/.npm-global/bin"
      ];
    };
  };
}
