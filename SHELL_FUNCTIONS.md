# Shell Functions & Aliases Documentation

Reference for the custom shell functions and aliases in these dotfiles.

Functions and aliases shared by bash and zsh live in `shell/.config/shell/`.
Anything zsh-only (abbreviations, vi mode, completion styling) lives in
`zsh/.zshrc`.

## Git & VCS Functions

### `g` - Smart git wrapper
```bash
g [args]
```
- Without arguments: Shows `git status --short`
- With arguments: Passes them to git command

### `gc` - Smart git commit
```bash
gc [message]
```
- Without arguments: Opens commit editor with verbose output
- With arguments: Creates commit with provided message

### `jjc` - Smart jj commit
```bash
jjc [message]
```
- Without arguments: Opens the jj commit editor
- With arguments: Commits with the provided message

### `cb` - Checkout recent branch
```bash
cb
```
Interactive branch selector with preview of changes. Zsh only.

### `wt` - Git worktree helper
```bash
wt <feature-name>
```
Creates a worktree beside the repo in `<repo>-worktrees/`, copies `.env`,
`.envrc` and `.claude` into it, and opens it in Zed.

### `jjw` - jj workspace helper
```bash
jjw new <name> [revision]
jjw go <name>
jjw list
```
Creates, enters, and lists jj workspaces under `.workspaces/`, copying env
files and running `direnv allow` on the way in.

## Utility Functions

### `copy` - Copy to clipboard
```bash
copy <file>
```
Copies file contents to system clipboard (macOS).

### `envs` - Source environment file
```bash
envs <env-file>
```
Sources an environment file with automatic export of variables.

## Key Aliases

### Navigation & Listing
- `c` - Clear screen
- `ls` → `eza` - Modern ls replacement
- `l` - Compact listing, respects gitignore
- `ll` - Long listing with headers
- `la` - Detailed listing with all attributes
- `llm` - Long listing sorted by modified time
- `lx` - Long listing with extended attributes
- `lt` - Tree view with icons
- `tree` - Tree view using eza

### Git Shortcuts (zsh abbreviations)
- `ga` - git add
- `gs` - git status
- `gco` - git checkout
- `gd` - git diff

Abbreviations expand before functions and PATH lookup, so nothing here may
share a name with a function in `shell/.config/shell/functions.sh` or a script
in `~/.local/bin`.

### jj Shortcuts (zsh abbreviations)
- `jl`, `jn`, `jc`, `je`, `jd`, `js`, `j`, `jdf` - jj log/new/commit/edit/describe/status/diff
- `jgf`, `jgp` - jj git fetch/push
- `jrs` - jj rebase -d main
- `fetch`, `push`, `squash` - jj equivalents

### Modern Tool Replacements
- `cat` → `bat` - Better file viewer
- `top`, `htop` → `btop` - Better process monitor
- `diff` → `delta` - Better diff viewer
- `rm` → `trash` - Safe delete, zsh interactive only

### Development
- `vim` → `nvim` - Neovim
- `mr`, `mi`, `mu`, `ml`, `mc` - mise run/install/use/list/current

### AWS
- `assume` - AWS credential assumption
- `granted-refresh` - Refresh AWS SSO credentials

## Vi Mode Keybindings
- `jk` - Exit insert mode (ESC alternative)
- `^a` - Beginning of line
- `^e` - End of line

## FZF Integration
- `Ctrl+T` - File picker with preview
- `Ctrl+R` - History search
- `Alt+C` - Directory picker
- Tab completion is routed through fzf-tab, with eza previews for directories

## Tmux Integration
The configuration includes numerous tmux shortcuts mapped through Ghostty. See [CHEAT_SHEET.md](./CHEAT_SHEET.md) for the complete list.

## Performance Notes
- `compinit -C` skips the security check on cached completions
- FZF uses `fd` for better performance
- Zoxide replaces `cd` for smarter navigation
- History search uses substring matching (zsh-history-substring-search)
- PATH is built once in `shell/.config/shell/path.sh`; re-sourcing is a no-op
