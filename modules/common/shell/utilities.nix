{ config, pkgs, ... }:
{

  config = {

    home-manager.users.${config.user} = {

      home.packages = with pkgs; [
        # age # Encryption
        # bc # Calculator
        # difftastic # Other fancy diffs
        # dig # DNS lookup
        fd # find
        htop # Show system processes
        killall # Force quit
        # inetutils # Includes telnet, whois
        # jless # JSON viewer
        # jo # JSON output
        jq # A lightweight and flexible command-line JSON processor
        yq # Command-line YAML/XML/TOML processor - jq wrapper for YAML, XML, TOML documents
        # lf # File viewer
        # qrencode # Generate qr codes
        ripgrep # grep
        # sd # sed
        sesh
        sqlite
        # tealdeer # Cheatsheets
        tree # View directory hierarchy
        unzip # Extract zips
        # dua # File sizes (du)
        # du-dust # Disk usage tree (ncdu)
        # duf # Basic disk information (df)
      ];

      programs.zoxide.enable = true; # Shortcut jump command

      home.file = {
        ".digrc".text = "+noall +answer"; # Cleaner dig commands
      };

      programs.bat = {
        enable = true; # cat replacement
        config = {
          pager = "less -R"; # Don't auto-exit if one screen
        };
      };

      programs.fish.functions = {
        ping = {
          description = "Improved ping";
          argumentNames = "target";
          body = "${pkgs.prettyping}/bin/prettyping --nolegend $target";
        };
      };
    };
  };
}
