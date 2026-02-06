---
name: pr-comments
description: "Use when addressing PR review feedback, resolving comment threads, or checking unresolved comments before merge. Triggers: resolve PR comments, fix pr feedback, pr review threads"
---

# GitHub PR Comments

Work with PR review comments - list unresolved threads and mark resolved after fixing.

## When to Use

- Need to see unresolved review comments on a PR
- Addressing reviewer feedback systematically
- Marking threads resolved after fixing code

**Don't use when:** Just viewing PR diff or general PR info - use `gh pr view` instead.

## Workflow

Scripts located in `~/.claude/skills/gh-pr-comments/scripts/`.

1. List unresolved comments:
   ```bash
   bun run list-comments.ts --unresolved
   ```
2. Plan fixes for each comment (discuss with user which to address)
3. Implement fixes in code
4. Resolve each thread after fixing:
   ```bash
   bun run resolve-comment.ts <thread_id>
   ```

## Quick Reference

| Task | Command |
|------|---------|
| Unresolved comments | `list-comments.ts --unresolved` |
| Exclude bots | `list-comments.ts --no-bots` |
| Specific PR | `list-comments.ts --pr 123` |
| Specific repo | `list-comments.ts --repo owner/name` |
| Resolve thread | `resolve-comment.ts PRRT_xxx` |

Run scripts with `--help` for all options. PR and repo auto-detected from current directory.

## Output Format

With `--unresolved`:
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

## Common Mistakes

- **Resolving before fixing** - Only resolve after code changes are committed
- **Missing thread_id** - Only `--unresolved` returns `thread_id` (required for resolving)
- **Forgetting bots** - Use `--no-bots` to focus on human feedback
