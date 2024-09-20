{ config
, pkgs
, lib
, ...
}:

let
  home-packages = config.home-manager.users.${config.user}.home.packages;
in
{

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
          rebase = {
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
          ".direnv/**"
        ];
      };


      programs.fish.shellAbbrs = {
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
      };

      # Required for fish commands
      home.packages = with pkgs; [
        fish
        fzf
        bat
        delta
      ];

      programs.fish.functions =
        lib.mkIf (builtins.elem pkgs.fzf home-packages && builtins.elem pkgs.bat home-packages)
          {
            # git = {
            #   body = builtins.readFile ./fish/functions/git.fish;
            # };
            # git-add-fuzzy = {
            #   body = builtins.readFile ./fish/functions/git-add-fuzzy.fish;
            # };
            # git-fuzzy-branch = {
            #   argumentNames = "header";
            #   body = builtins.readFile ./fish/functions/git-fuzzy-branch.fish;
            # };
            # git-checkout-fuzzy = {
            #   body = ''
            #     set branch (git-fuzzy-branch "checkout branch...")
            #     and git checkout $branch
            #   '';
            # };
            # git-delete-fuzzy = {
            #   body = ''
            #     set branch (git-fuzzy-branch "delete branch...")
            #     and git branch -d $branch
            #   '';
            # };
            # git-force-delete-fuzzy = {
            #   body = ''
            #     set branch (git-fuzzy-branch "force delete branch...")
            #     and git branch -D $branch
            #   '';
            # };
            # git-merge-fuzzy = {
            #   body = ''
            #     set branch (git-fuzzy-branch "merge from...")
            #     and git merge $branch
            #   '';
            # };
            # git-show-fuzzy = {
            #   body = builtins.readFile ./fish/functions/git-show-fuzzy.fish;
            # };
            # git-commits = {
            #   body = builtins.readFile ./fish/functions/git-commits.fish;
            # };
            # git-history = {
            #   body = builtins.readFile ./fish/functions/git-history.fish;
            # };
            # uncommitted = {
            #   description = "Find uncommitted git repos";
            #   body = builtins.readFile ./fish/functions/uncommitted.fish;
            # };
          };
    };
  };
}
