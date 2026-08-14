# Added by OrbStack: command-line tools and integration
source ~/.orbstack/shell/init.zsh 2>/dev/null || :

# Re-assert the PATH order .zshenv built. /etc/zprofile runs path_helper
# between the two and hoists /etc/paths to the front; see path.sh. Interactive
# shells would get this anyway from the ~/.config/shell/*.sh loop in .zshrc,
# but a login shell that never reads .zshrc (`zsh -lc ...`) would not.
[ -r ~/.config/shell/path.sh ] && source ~/.config/shell/path.sh
