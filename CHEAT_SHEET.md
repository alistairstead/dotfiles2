# Terminal & Tmux Cheat Sheet

Quick reference for Ghostty + tmux key bindings and workflows.

## 🪟 Window & Session Management

| Key Combination | Action | Context |
|-----------------|--------|---------|
| `⌘+1` through `⌘+9` | Switch to tmux window 1-9 | Global |
| `⌘+T` | Create new tmux window | Global |
| `⌘+W` | Close current tmux pane | Global |
| `⌘+⇧+[` | Previous tmux window | Global |
| `⌘+⇧+]` | Next tmux window | Global |
| `⌘+9` | Switch to project root session | Global |
| `⌘+L` | Switch to last tmux session | Global |
| `⌘+⇧+Q` | Kill current tmux session | Global |

## ✂️ Pane Management

| Key Combination | Action | Context |
|-----------------|--------|---------|
| `⌘+N` | Vertical split (tmux `%`) | Global |
| `⌘+⇧+N` | Horizontal split (tmux `"`) | Global |
| `⌘+⇧+B` | Break pane to new window | Global |
| `⌘+⇧+J` | Join pane from window 1 | Global |
| `⌥+←/→/↑/↓` | Navigate between panes | Global |
| `⇧+←/→` | Navigate between windows | Global |
| `⌥+H/L` | Previous/next window | Global |

## 📋 Copy Mode & Text Selection

| Key Combination | Action | Context |
|-----------------|--------|---------|
| `⌘+C` | Enter tmux copy mode | Global |
| `prefix + [` | Enter copy mode | Tmux |
| `prefix + u` | Enter copy mode and scroll up | Tmux |
| `prefix + f` | Enter copy mode with search | Tmux |
| `v` | Start visual selection | Copy Mode |
| `V` | Select entire line | Copy Mode |
| `Ctrl+V` | Rectangle selection | Copy Mode |
| `y` | Yank selection and exit | Copy Mode |
| `Y` | Yank entire line | Copy Mode |
| `Esc` | Exit copy mode | Copy Mode |

### Copy Mode Navigation (Vim-style)

| Key | Action | Key | Action |
|-----|--------|-----|--------|
| `h/j/k/l` | Cursor movement | `w/b/e` | Word movement |
| `0/^/$` | Line start/first non-blank/end | `Ctrl+F/B` | Page down/up |
| `Ctrl+D/U` | Half page down/up | `g/G` | Buffer start/end |
| `//?` | Search forward/backward | `n/N` | Next/previous match |

## 🔍 Session & Project Management

| Key Combination | Action | Context |
|-----------------|--------|---------|
| `⌘+K` | Session picker (sesh) | Global |
| `⌘+⇧+K` | Advanced session picker | Global |
| `⌘+⇧+T` | Session picker with preview | Global |
| `⌘+⇧+Z` | Session popup | Global |
| `prefix + Z` | Enhanced session picker | Tmux |
| `prefix + K` | Full-screen session picker | Tmux |
| `prefix + R` | Root-focused session picker | Tmux |
| `prefix + T` | Compact session picker | Tmux |

## 🛠️ Development Tools

| Key Combination | Action | Context |
|-----------------|--------|---------|
| `⌘+G` | Open Lazygit | Global |
| `⌘+⇧+G` | Open GitHub Dashboard | Global |
| `⌘+D` | Open Lazydocker | Global |
| `⌘+⇧+D` | Development split | Global |
| `⌘+Y` | Script runner (package.json) | Global |
| `⌘+⇧+R` | Rename tmux window | Global |

## 📝 Editor Integration

| Key Combination | Action | Context |
|-----------------|--------|---------|
| `⌘+F` | Grep search (`:Grep`) | Global |
| `⌘+P` | Go to file (`:GotoFile`) | Global |
| `⌘+⇧+P` | Go to command (`:GotoCommand`) | Global |
| `⌘+⇧+O` | Go to symbol (`:GotoSymbol`) | Global |
| `⌘+S` | Save file (`:w`) | Global |
| `⌘+Q` | Quit with escape (`:qa!`) | Global |
| `⌘+[` | Jump back (vim `Ctrl+I`) | Global |
| `⌘+]` | Jump forward (vim `Ctrl+O`) | Global |

## 🔗 External Tools

| Key Combination | Action | Context |
|-----------------|--------|---------|
| `⌘+O` | Open URL (tmux urlview) | Global |
| `⌘+R` | Reload Ghostty config | Global |
| `⇧+↩` | Send newline (Claude Code) | Global |

## 🖱️ Mouse Operations

| Action | Behavior |
|--------|----------|
| **Scroll Up** | Enter copy mode, scroll through history |
| **Scroll Down** | Natural scrolling, exit copy mode at bottom |
| **Click + Drag** | Select text, auto-copy to clipboard |
| **Double Click** | Select word, auto-copy to clipboard |
| **Triple Click** | Select line, auto-copy to clipboard |

## 🎯 Quick Workflows

### Session Management
1. `⌘+K` → Quick session switch
2. `⌘+⇧+T` → Advanced session picker with preview
3. `⌘+9` → Jump to project root
4. `⌘+L` → Toggle between last two sessions

### Development Workflow
1. `⌘+G` → Open git interface
2. `⌘+D` → Monitor containers
3. `⌘+Y` → Run project scripts
4. `⌘+⇧+D` → Open development split

### Text Editing & Search
1. `⌘+C` → Enter copy mode
2. `⌘+F` → Search across files
3. `⌘+P` → Quick file navigation
4. Mouse selection → Instant clipboard copy

### Pane Management
1. `⌘+N` / `⌘+⇧+N` → Split vertically/horizontally
2. `⌥+arrows` → Navigate between panes
3. `⌘+⇧+B` → Break pane to new window
4. `⌘+⇧+J` → Join panes together

## 📚 tmux Prefix Commands

**Prefix:** `Ctrl+B` (already sent by Ghostty key bindings)

| Command | Action |
|---------|--------|
| `prefix + c` | New window |
| `prefix + x` | Kill pane |
| `prefix + &` | Kill window |
| `prefix + d` | Detach session |
| `prefix + s` | Show sessions |
| `prefix + w` | Show windows |
| `prefix + ,` | Rename window |
| `prefix + $` | Rename session |

---

> **Note:** Most common operations are mapped to `⌘` key combinations for seamless macOS integration. The tmux prefix (`Ctrl+B`) is automatically sent by Ghostty for the mapped commands.