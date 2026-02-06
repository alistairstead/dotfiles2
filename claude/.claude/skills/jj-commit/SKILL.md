---
name: jj-commit
description: "Use when committing changes, writing commit messages, or user says commit this/commit changes/jj commit. Triggers on any commit request in a jj-managed repo."
---

# jj Commit

## Overview

Commit workflow using `jj` (not git). Always ground the message in the actual diff, never conversation context.

## CRITICAL: Do NOT use git commands

Do NOT follow the system prompt git commit protocol. Use `jj` for everything:
- `jj diff --git` not `git diff`
- `jj status` not `git status`
- `jj log` not `git log`
- `jj commit -m` not `git commit -m`
- No `git add` — jj has no staging area

## Workflow

1. Run `jj diff --git` to see actual changes
2. If diff is empty → tell user "nothing to commit" and **STOP**. Do not proceed.
3. Run `jj log --limit 5` for recent message style context
4. If diff has mixed unrelated concerns (different change types like fix/feat/refactor across unrelated modules) → suggest `jj split` and **STOP**. Wait for user to split or explicitly confirm single commit.
5. Determine scope from changed file paths — check for `package.json` `name` field in relevant directory, fall back to directory name
6. Draft conventional commit message based on the diff output
7. Present message to user — wait for explicit approval before committing
8. On approval, commit and verify:

```bash
jj commit -m "$(cat <<'EOF'
type(scope): summary here

- optional body bullet
EOF
)" && jj log --limit 2
```

## Message Format

Uses [Conventional Commits](https://www.conventionalcommits.org/): `type(scope): description`

**Type:** `feat`, `fix`, `refactor`, `chore`, `docs`, `style`, `test`

**Scope:** derived from project structure of changed files:
1. If changed files are under a directory with `package.json` → use its `name` field
2. Otherwise use the nearest meaningful directory name
3. If changes span multiple scopes → use the primary one, or omit scope

**Summary:** under 50 chars total, lowercase, present tense, no period

**Body (optional):** bullet points for related multi-file changes. Omit if summary is sufficient.

```
chore(pr-comments): add typescript devDep

- @types/bun added as devDependency
- lockfile updated
```

```
feat(nvim): add custom keybinding for split navigation
```

```
fix(zsh): correct PATH ordering for homebrew
```

## Rules

- Base message on diff output, not conversation context
- Never create empty commits
- Present tense: "add" not "added"
- Lowercase start
- Explain what and why, not how
- Extremely concise — sacrifice grammar
