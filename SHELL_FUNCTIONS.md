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
- `assume` - AWS credential assumption (exports `AWS_PROFILE` for the whole shell)
- `unassume` - Clear the assumed profile from the current shell
- `granted-refresh` - Refresh AWS SSO credentials

### Cloud context (direnv)

`direnv/.config/direnv/direnvrc` adds two `use` helpers so cloud context follows
the project instead of the shell. Each clears the other cloud's variables, which
is what keeps the starship prompt honest.

```sh
# .envrc in an AWS project
use aws kodehort eu-west-2

# .envrc in a GCP project
use gcloud default genie-goals-analytics

# ...impersonating a service account, the gcloud analogue of `assume`
use gcloud default genie-goals-analytics deploy@genie-goals-analytics.iam.gserviceaccount.com
```

`use gcloud <configuration>` takes a name from `gcloud config configurations
list`; it sets `CLOUDSDK_ACTIVE_CONFIG_NAME`, which both the gcloud CLI and the
prompt read, so nothing has to mutate global gcloud state with `gcloud config
set`. Run `direnv allow` after writing an `.envrc`.

Full behaviour, including how the prompt is configured and what to do when a
profile is stuck in a shell: [direnv/README.md](direnv/README.md).

## Vi Mode Keybindings
- `jk` - Exit insert mode (ESC alternative)
- `^a` - Beginning of line
- `^e` - End of line

## FZF Integration
- `Ctrl+T` - File picker with preview
- `Alt+C` - Directory picker
- Tab completion is routed through fzf-tab, with eza previews for directories

## History Search (Atuin)
- `Ctrl+R` / `Up` - Search history in Atuin's TUI, not fzf or zsh
- `Ctrl+R` again, inside the TUI - Cycle filter scope: global → workspace →
  directory → host → session. Workspace means the whole git repo tree, so
  `wt` and `jjw` worktrees of one project share a scope
- `Ctrl+S` - Cycle match mode (fuzzy, prefix, fulltext)
- `Tab` - Put the command on the prompt to edit; `Enter` does the same, by
  choice (`enter_accept = false`)
- `Ctrl+O` - Inspector for the selected entry; `Ctrl+A` then `d` deletes it
- Every entry carries its exit code, duration, directory, host and shell:
  `atuin search --exclude-exit 0 --cwd . --after yesterday`, `atuin stats week`
- Commands run by Claude Code are recorded and tagged, and hidden from
  interactive search. `atuin search --author '$all-agent' -- ''` shows them
- Leading space still keeps a command out, as it always did

Configuration and the reasoning behind each setting: `atuin/.config/atuin/config.toml`.

## Atuin AI
- `?` on an empty prompt (insert mode) - Generate a command, refine it, or ask a
  question. `Enter` runs the suggestion, `Tab` puts it on the prompt. `?` in
  normal mode is still `vi-history-search-forward`
- `/help`, `/new`, `/model`, `/reload` - Slash commands inside the assistant
- Skills in `~/.config/atuin/skills/<name>/SKILL.md` or `.atuin/skills/` register
  as their own slash commands; `TERMINAL.md` supplies standing context
- Requires an Atuin Hub login on first use, separate from the sync account
- What it may do without asking:
  `atuin/.config/atuin/permissions.ai.toml`. Credentials, keys and destructive
  commands are denied; anything unlisted prompts

## Command Output Capture
- `atuin pty-proxy` runs at the very top of `.zshrc` and records what each
  command printed; the daemon holds 1MB per command, last 128 per session, in
  memory only
- Lets `?` and Claude Code answer "why did that fail" from the real error
- `atuin daemon status` to check it; comment out the pty-proxy block at the top
  of `.zshrc` if a terminal ever misbehaves

## Performance Notes
- `compinit -C` skips the security check on cached completions
- FZF uses `fd` for better performance
- Zoxide replaces `cd` for smarter navigation
- `atuin init` is sourced late in `.zshrc`: after the fzf key bindings, which
  also claim `Ctrl+R`, and after `bindkey -v`, which would otherwise discard it
- PATH is built once in `shell/.config/shell/path.sh`; re-sourcing is a no-op
