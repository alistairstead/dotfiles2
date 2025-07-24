import { rule, map, to$, withModifier } from 'karabiner.ts'

export function hyperLayer() {
  return [
    // Navigation across all applications (vim-style)
    rule('Hyper Navigation').manipulators([
      withModifier(['shift', 'control', 'option', 'command'])({
        // Tmux-aware navigation (sends Ctrl+key for tmux integration)
        h: { key_code: 'h', modifiers: ['control'] },
        j: { key_code: 'j', modifiers: ['control'] },
        k: { key_code: 'k', modifiers: ['control'] },
        l: { key_code: 'l', modifiers: ['control'] },
        
        // Word-wise navigation
        b: { key_code: 'left_arrow', modifiers: ['option'] },
        w: { key_code: 'right_arrow', modifiers: ['option'] },
        
        // Line navigation
        0: { key_code: 'left_arrow', modifiers: ['command'] },
        4: { key_code: 'right_arrow', modifiers: ['command'] }, // $ in vim
        
        // Page navigation
        d: { key_code: 'page_down' },
        u: { key_code: 'page_up' },
        
        // Delete operations
        x: { key_code: 'delete_forward' },
        
        // For tmux integration - send the tmux prefix
        spacebar: to$('tmux send-keys C-b'),
      }),
    ]),
    
    // Quick app switching
    rule('Hyper App Switching').manipulators([
      withModifier(['shift', 'control', 'option', 'command'])({
        t: { shell_command: 'open -a "Ghostty"' },
        c: { shell_command: 'open -a "Google Chrome"' },
        s: { shell_command: 'open -a "Slack"' },
        z: { shell_command: 'open -a "Zed"' },
        n: { shell_command: 'open -a "Obsidian"' },
        m: { shell_command: 'open -a "Mail"' },
        f: { shell_command: 'open -a "Finder"' },
      }),
    ]),
    
    // Window management shortcuts
    rule('Hyper Window Management').manipulators([
      withModifier(['shift', 'control', 'option', 'command'])({
        // Split windows (for apps that support it)
        v: { key_code: 'v', modifiers: ['command', 'shift'] }, // Vertical split
        '\\': { key_code: 'backslash', modifiers: ['command', 'shift'] }, // Horizontal split
        
        // Close operations
        q: { key_code: 'w', modifiers: ['command'] }, // Close tab/window
        
        // Tab navigation
        '[': { key_code: 'open_bracket', modifiers: ['command', 'shift'] }, // Previous tab
        ']': { key_code: 'close_bracket', modifiers: ['command', 'shift'] }, // Next tab
      }),
    ]),
  ]
}