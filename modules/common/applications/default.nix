{ ... }:
{
  config =
    {
      unfreePackages = [
        "1password"
        "_1password-gui"
        "1password-cli"
        "obsidian"
        "slack"
      ];
    };

  imports = [
    ./1password.nix
    ./discord.nix
    ./obsidian.nix
    ./neovim
    ./slack.nix
    ./wezterm
  ];
}
