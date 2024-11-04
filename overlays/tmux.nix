inputs: final: prev: 
{
  tmuxPlugins = prev.tmuxPlugins // {
    sensible = prev.tmuxPlugins.sensible.overrideAttrs (prev: {
      postInstall = prev.postInstall + ''
        sed -e 's:\$SHELL:${final.fish}/bin/fish:g' -i $target/sensible.tmux
      '';
    });
  };
}
