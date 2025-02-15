{ config, pkgs, ... }: {
  config = {
    home-manager.users.root.programs.git = {
      enable = true;
      extraConfig.safe.directory = config.dotfilesPath;
    };

    home-manager.users.${config.user} = {
      programs.git = {
        enable = true;
        userName = config.gitName;
        userEmail = config.gitEmail;
        extraConfig = {
          alias = {
            co = "checkout";

            # View abbreviated SHA, description, and history graph of the latest 20 commits
            l = "log --pretty=oneline -n 40 --graph --abbrev-commit";
            la = "log --pretty=custom -n 40 --graph --abbrev-commit";

            # View the current working tree status using the short format
            s = "status -s";
            st = "status";

            # Show verbose output about tags, branches or remotes
            tags = "tag -l";
            branches = "branch -a";
            remotes = "remote -v";

            undo = "reset --soft HEAD^";
          };
          core = {
            pager = "delta";
          };
          interactive = {
            difffilter = "delta --color-only";
          };
          delta = {
            navigate = true;
            light = false;
          };
          apply = {
            whitespace = "fix";
          };
          push = {
            default = "current";
            autoSetupRemote = true;
          };
          init = {
            defaultBranch = "main";
          };
          merge = {
            conflictStyle = "diff3";
          };
          rebase = {
            updateRefs = true;
            autosquash = true;
            autostash = true;
            stat = true;
          };
          rerere = {
            autoupdate = true;
            enabled = true;
          };
          help = {
            autocorrect = "1";
          };
          user = {
            # This is not evaluated as a sub-shell but it is public so can include the value
            # signingkey = ''$(op item get "SSH Key" --fields label="public key")'';
            signingkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICqsrSxLYhMuCdzuO6pra5QulC8SKN19v1AUjh7wqUZq";
          };
          gpg = {
            format = "ssh";
            ssh.program = "/Applications/1Password.app/Contents/MacOS/op-ssh-sign";
          };
          commit = {
            gpgsign = "true";
          };
          pretty = {
            # custom = "%Cred%h%Creset %an: %s - %Creset %C(yellow)%d%Creset %Cgreen(%cr)%Creset"
            custom = "%C(magenta)%h%C(red)%d %C(yellow)%ar %C(green)%s %C(yellow)(%an)";
            #                     │        │            │            │             └─ author name
            #                     │        │            │            └─ message
            #                     │        │            └─ date (relative)
            #                     │        └─ decorations (branch, heads or tags)
            #                     └─ hash (abbreviated)
          };
        };
        ignores = [
          ".AppleDouble"
          ".LSOverride"
          "Icon"
          # Thumbnails
          "._*"
          # Files that might appear on external disk
          ".Spotlight-V100"
          ".Trashes"
          "tags"
          "vendor-tags"
          "_ide_helper.php"
          ".lvimrc"
          ".projections.json"
          ".cache/"
          ".DS_Store"
          ".idea/"
          "*.swp"
          ".direnv/"
          "node_modules"
          "result"
          "result-*"
          ".devenv/"
          ".direnv/"
          ".devenv.flake.nix"
          ".envrc"
          "devenv.lock"
          "devenv.nix"
          "devenv.yaml"
        ];
      };

      # Required for git config
      home.packages = with pkgs; [
        delta
      ];

    };
  };
}
