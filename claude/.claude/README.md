# Claude Code Configuration

This directory contains Claude Code configuration and custom user prompts that can be linked to your home directory using GNU Stow.

## Setup

To link this configuration to your home directory:

```bash
# From the dotfiles root directory
stow claude
```

This will create symlinks:
- `~/.claude/settings.json` → `dotfiles/claude/.claude/settings.json`
- `~/.claude/prompts/` → `dotfiles/claude/.claude/prompts/`

## Configuration Files

### `settings.json`
Claude Code application settings including:
- Theme and appearance
- Editor preferences (font, size, etc.)
- Chat behavior settings
- Privacy preferences
- Experimental features

### `prompts/`
Directory containing custom user prompts for specialized assistance:

- **`code-review.md`** - Expert code reviewer for quality, security, and performance
- **`shell-expert.md`** - DevOps and shell scripting specialist
- **`config-helper.md`** - Dotfiles and configuration management expert
- **`nix-expert.md`** - Nix ecosystem and functional configuration specialist

## Using Custom Prompts

In Claude Code, you can reference these prompts using the `/user:` command:

```
/user:code-review

Please review this TypeScript function for security issues:
[paste your code here]
```

```
/user:shell-expert

Help me write a robust bash script that processes log files and handles errors gracefully.
```

```
/user:config-helper

I want to organize my tmux configuration with better key bindings and theme customization.
```

```
/user:nix-expert

Help me create a Nix flake for a Node.js development environment with specific package versions.
```

## Adding New Prompts

To add new specialized prompts:

1. Create a new `.md` file in the `prompts/` directory
2. Define the assistant's role, expertise, and response style
3. Include specific instructions for the domain
4. Commit the changes to version control

## Customization

Modify `settings.json` to match your preferences:
- Adjust font family to match your terminal setup
- Configure chat behavior (send on enter, timestamps)
- Set privacy preferences
- Enable/disable experimental features

The configuration uses the same Monaspace Neon font as your terminal setup for consistency.