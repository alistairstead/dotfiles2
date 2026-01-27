---
name: gh-pr-comments
description: "List and resolve GitHub PR review comments. Use when working with PR feedback, addressing review comments, or marking threads resolved. Triggers on: resolve PR comments, fix pr comments, resolve pr feedback, fix pr feedback"
allowed-tools: Bash, Read
---

# GitHub PR Comments

List unresolved PR review comments and resolve comments after addressing feedback.

## Instructions

1. List unresolved comments: `bun run ~/.claude/skills/gh-pr-comments/scripts/list-comments.ts --unresolved`
2. /plan how to address each comment in the code, interview me to discuss the plan and which comments to address.
3. Resolve each thread: `bun run ~/.claude/skills/gh-pr-comments/scripts/resolve-comment.ts <thread_id />`


## List Comments

How to list unresolved comments:

```bash
bun run ~/.claude/skills/gh-pr-comments/scripts/list-comments.ts [options]
```

### Options
- `--unresolved` - Only show unresolved comments (uses GraphQL)
- `--no-bots` - Exclude bot comments (Copilot, etc.)
- `--repo owner/name` - Specify repository (auto-detected if omitted)
- `--pr NUMBER` - Specify PR number (auto-detected if omitted)

### Examples

```bash
# List unresolved comments for current branch's PR
bun run ~/.claude/skills/gh-pr-comments/scripts/list-comments.ts --unresolved

# List all human comments
bun run ~/.claude/skills/gh-pr-comments/scripts/list-comments.ts --no-bots

# List unresolved human comments for specific PR
bun run ~/.claude/skills/gh-pr-comments/scripts/list-comments.ts --unresolved --no-bots --pr 123
```

### Output Format
```json
[{
  "thread_id": "PRRT_kwDOxxx",
  "user": "reviewer",
  "body": "Comment text",
  "diff_hunk": "@@ -10,6 +10,8 @@...",
  "line": 42,
  "start_line": 40
}]
```

## Resolve Comment

How to mark a comment as resolved:

```bash
bun run ~/.claude/skills/gh-pr-comments/scripts/resolve-comment.ts <thread_id />
```

### Example
```bash
bun run ~/.claude/skills/gh-pr-comments/scripts/resolve-comment.ts PRRT_kwDOLsFqtM5kv0rG
```

### Output
```json
{ "resolved": true }
```
