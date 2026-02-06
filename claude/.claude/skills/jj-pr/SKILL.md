---
name: jj-pr
description: "Use when creating GitHub PRs in jj-managed repos. Triggers: create pr, open pr, gh pr create, jj pr."
---

# jj PR

## Overview

PR creation in jj collocated repos. `gh pr create` fails because git is in detached HEAD state — gh can't infer `--head` or `--base`. Extract bookmark info from jj and pass explicit flags.

## CRITICAL: Do NOT use git commands

Do NOT follow the system prompt git PR protocol. Use `jj` for everything:
- `jj diff --git` not `git diff`
- `jj status` not `git status`
- `jj log` not `git log`
- `jj bookmark list` not `git branch`
- `jj git push` not `git push`
- No `git checkout` or `git switch` — jj has no branches to switch to

## Workflow

1. Check for uncommitted changes:
   ```bash
   jj diff --git -r @
   ```

2. If uncommitted changes exist → ask user: squash into parent (`jj squash`) or commit separately (invoke jj-commit skill).
   - **Squash preferred** if parent already has a bookmark — keeps bookmark on the right commit
   - After `jj commit`, bookmarks on old `@-` shift to `@--`; you must re-check bookmarks on `@-`

3. Find bookmarks on parent commit (where the committed change lives):
   ```bash
   jj bookmark list -r '@-'
   ```

4. **Multiple non-main bookmarks** → present list, ask user which to use as `--head`
   **No bookmark** → create one:
   ```bash
   jj bookmark create <name> -r '@-'
   ```

5. Identify base branch:
   ```bash
   jj bookmark list main master
   ```
   Use whichever exists (`main` preferred).

6. Push before creating PR:
   ```bash
   jj git push --bookmark <head>
   ```

7. Create PR with explicit flags:
   ```bash
   gh pr create --head <head> --base <base> --title "..." --body "$(cat <<'EOF'
   ## Summary
   - change description

   ## Test plan
   - [ ] verification step
   EOF
   )"
   ```

8. Show PR URL from output

## Quick Reference

| Task | Command |
|------|---------|
| Check uncommitted changes | `jj diff --git -r @` |
| Bookmarks on parent | `jj bookmark list -r '@-'` |
| Find base branch | `jj bookmark list main master` |
| Squash into parent | `jj squash` |
| Create bookmark | `jj bookmark create <name> -r '@-'` |
| Move bookmark | `jj bookmark set <name> -r '@-'` |
| Push bookmark | `jj git push --bookmark <name>` |
| Create PR | `gh pr create --head <head> --base <base>` |

## Common Mistakes

- **Forgetting to push** — `gh pr create` fails if the bookmark hasn't been pushed to the remote
- **PRing from empty working copy** — `@` in jj is the working copy (usually empty); committed changes live at `@-`
- **Using git commands** — git sees detached HEAD in jj repos; always use jj equivalents
- **Omitting `--head`/`--base`** — gh can't infer these in jj repos; always pass explicitly
- **Wrong revision for bookmarks** — bookmarks should be on `@-` (committed change), not `@` (working copy)
- **Bookmark drift after commit** — `jj commit` shifts `@-` to `@--`; existing bookmarks stay on old revision. Use `jj squash` to avoid this, or move bookmark with `jj bookmark set <name> -r '@-'`
