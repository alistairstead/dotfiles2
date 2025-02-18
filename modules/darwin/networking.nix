{ config, pkgs , lib , ... }: {
  config = lib.mkIf pkgs.stdenv.isDarwin {
    networking = {
      knownNetworkServices = [
        "Wi-Fi"
        "Thunderbolt Bridge"
      ];
      dns = [
        "1.1.1.1"
        "8.8.8.8"
      ];
    };

    system.defaults = {
      # firewall settings
      alf = {
        # 0 = disabled 1 = enabled 2 = blocks all connections except for essential services
        globalstate = 1;
        loggingenabled = 0;
        stealthenabled = 0;
      };
    };

    system.activationScripts.hostname.text = ''
      echo >&2 "setting up hostname in /etc/hosts..."
      if grep -q nix-darwin /etc/hosts
      then
          sed -i -e "s/^127.0.0.1 .* # nix-darwin$/127.0.0.1 ${config.networking.hostName} # nix-darwin/" /etc/hosts
      else
          echo "127.0.0.1 ${config.networking.hostName} # nix-darwin" >> /etc/hosts
      fi
    '';
  };
}
