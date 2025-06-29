# Shell Functions & Aliases Documentation

This document provides a reference for custom shell functions and aliases defined in the dotfiles.

## Git Functions

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

### `cb` - Checkout recent branch
```bash
cb
```
Interactive branch selector with preview of changes.

### `ghpr` - GitHub PR browser
```bash
ghpr [query]
```
Browse and checkout GitHub pull requests interactively.

### `ghgist` - GitHub Gist browser
```bash
ghgist
```
Browse and edit your GitHub gists interactively.

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

### `gi` - Generate .gitignore
```bash
gi <language/framework>
```
Generates a .gitignore file for the specified language or framework.

## Key Aliases

### Navigation & Listing
- `c` - Clear screen
- `ls` → `eza` - Modern ls replacement
- `ll` - Long listing with headers
- `la` - Detailed listing with all attributes
- `tree` - Tree view using eza

### Git Shortcuts
- `ga` - git add
- `gs` - git status (short)
- `gco` - git checkout
- `push` - git push
- `pull` - git pull

### Modern Tool Replacements
- `cat` → `bat` - Better file viewer
- `top` → `btop` - Better process monitor
- `diff` → `delta` - Better diff viewer

### Development
- `vim` → `nvim` - Neovim
- `pn` → `pnpm` - Package manager shortcut

### AWS
- `assume` - AWS credential assumption
- `granted-refresh` - Refresh AWS SSO credentials

## Configuration Shortcuts
- `zshrc` - Edit ~/.zshrc
- `vimrc` - Edit Neovim config
- `tmuxrc` - Edit tmux config

## Vi Mode Keybindings
- `jk` - Exit insert mode (ESC alternative)
- `^a` - Beginning of line
- `^e` - End of line

## FZF Integration
- `Ctrl+T` - File picker with preview
- `Alt+C` - Directory picker

## Atuin (Enhanced History)
- `Ctrl+R` - Interactive history search (replaces default)
- `↑` - Search history in current directory
- `ah` - List history
- `as` - Search history
- `ai` - Import history from shell
- `ast` - Show history statistics

## Tmux Integration
The configuration includes numerous tmux shortcuts mapped through Ghostty. See [CHEAT_SHEET.md](./CHEAT_SHEET.md) for the complete list.

## Performance Notes
- Completions are lazy-loaded for faster startup
- FZF uses `fd` for better performance
- Zoxide replaces `cd` for smarter navigation
- History search is optimized with substring matching