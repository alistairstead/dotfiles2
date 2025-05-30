{ config
, lib
, ...
}:
{
  options = {
    granted = {
      enable = lib.mkEnableOption {
        description = "Enable Granted.";
        default = false;
      };
    };
  };

  config = lib.mkIf (!config.ci.enable && config.gui.enable && config.granted.enable) {
    home-manager.users.${config.user} = {
      home.sessionVariables = {
        GRANTED_ENABLE_AUTO_REASSUME = "true";
      };

      programs.granted = {
        enable = true;
        enableZshIntegration = true;
        enableFishIntegration = true;
      };

      home.shellAliases = {
        granted-refresh = "granted sso populate --sso-region eu-west-2 https://kodehort.awsapps.com/start";
      };

      # xdg.configFile."granted/config".text = ''
      #   DefaultBrowser = "CHROME"
      #   CustomBrowserPath = "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
      #   CustomSSOBrowserPath = "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
      #   Ordering = "Alphabetical"
      #   ExportCredentialSuffix = ""
      #   DefaultExportAllEnvVar = true
      #   CredentialProcessAutoLogin = true
      #
      #   [Keyring]
      #     Backend = "keychain"
      #
      #   [ProfileRegistry]
      #     PrefixAllProfiles = true
      #     PrefixDuplicateProfiles = true
      # '';

    };
  };
}
