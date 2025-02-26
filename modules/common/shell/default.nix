{ pkgs, lib, config, ... }: {
  imports = [
    ./zsh
    ./bash
    ./fish
    # ./charm.nix
    ./direnv.nix
    ./editorconfig.nix
    ./eza.nix
    ./fzf.nix
    ./git.nix
    ./github.nix
    ./nixpkgs.nix
    ./starship.nix
    ./tmux
    ./zoxide.nix
  ];
  config = {
    home-manager.users.${config.user} = { pkgs, lib, ... }: {
      programs = {
        home-manager.enable = true;

        # shell integrations are enabled by default
        jq.enable = true; # json parser
        bat = {
          enable = true; # cat replacement
          config = {
            pager = "less -R"; # Don't auto-exit if one screen
          };
        };
        btop.enable = true; # htop alternative

        htop = {
          enable = true;
          settings = {
            tree_view = true;
            show_cpu_frequency = true;
            show_cpu_usage = true;
            show_program_path = false;
          };
        };

      };
      home = {
        sessionVariables =
        {
          EDITOR = "nvim";
          GIT_EDITOR = "nvim";
          VISUAL = "nvim";
          FONTCONFIG_FILE = "${pkgs.fontconfig.out}/etc/fonts/fonts.conf";
        };

        packages = with pkgs; [ 
          # age # Encryption
          # bc # Calculator
          # difftastic # Other fancy diffs
          curl 
          dig # DNS lookup
          fastfetch
          fd # find
          fontconfig
          gum
          inkscape # Vector
          imagemagick # Image manipulation
          killall # Force quit
          inetutils # Includes telnet, whois
          # jless # JSON viewer
          # jo # JSON output
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



        shellAliases = {

          # Vim (overwritten by Neovim)
          v = "nvim";
          vim = "nvim";
          vl = "vim -c 'normal! `0'";

          # git
          g = "git status";
          gd = "git diff";
          gds = "git diff --staged";
          gdp = "git diff HEAD^";
          ga = "git add";
          gaa = "git add -A";
          gac = "git commit -am";
          gc = "git commit -m";
          gca = "git commit --amend --no-edit";
          gcae = "git commit --amend";
          gu = "git pull";
          gp = "git push";
          gl = "git log --graph --decorate --oneline -20";
          gll = "git log --graph --decorate --oneline";
          gco = "git checkout";
          gcom = ''git switch (git symbolic-ref refs/remotes/origin/HEAD | cut -d"/" -f4)'';
          gcob = "git switch -c";
          gb = "git branch";
          gpd = "git push origin -d";
          gbd = "git branch -d";
          gbD = "git branch -D";
          gr = "git reset";
          grh = "git reset --hard";
          gm = "git merge";
          gcp = "git cherry-pick";
          cdg = "cd (git rev-parse --show-toplevel)";

          # builtins
          size = "du -sh";
          cp = "cp -i";
          mkdir = "mkdir -p";
          df = "df -h";
          du = "du -sh";
          del = "rm -rf";
          null = "/dev/null";

          # overrides
          cat = "bat";
          top = "btop";
          htop = "btop";
          # ping = "gping";
          diff = "delta";

          # programs
          d = "docker";
          dc = "docker-compose";
          tf = "terraform";

          # Version of bash which works much better on the terminal
          bash = "${pkgs.bashInteractive}/bin/bash";

          # Move files to XDG trash on the commandline
          trash = lib.mkIf pkgs.stdenv.isLinux "${pkgs.trash-cli}/bin/trash-put";

        };
      };

      home.file = {
        ".digrc".text = "+noall +answer"; # Cleaner dig commands
      };

    };
  };
}
