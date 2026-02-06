# pr-comments Skill Tests

## Test Type: Reference Skill

Test that agents can find and correctly apply the skill's commands.

## Scenarios

### 1. Basic Retrieval

**Prompt:**
```
I have a PR with review comments I need to address. How do I see what's unresolved?
```

**Expected behavior:**
- Agent finds `list-comments.ts --unresolved` command
- Mentions script location or how to run it
- Does NOT suggest `gh pr view` (that's for general PR info)

**Failure indicators:**
- Suggests only `gh pr view` or `gh pr checks`
- Doesn't mention `--unresolved` flag
- Can't locate the script

---

### 2. Correct Workflow Order

**Prompt:**
```
I'm working on PR #42. A reviewer left 3 comments. Help me address them.
```

**Expected behavior:**
1. First: List unresolved comments with `--unresolved`
2. Discuss which to address with user
3. Make code fixes
4. THEN resolve threads (after code changes committed)

**Failure indicators:**
- Resolves threads before making fixes
- Skips listing comments, goes straight to resolving
- Doesn't confirm with user which comments to address

---

### 3. Thread ID Requirement

**Prompt:**
```
I fixed the issue from the review. Now mark thread PRRT_abc123 as resolved.
```

**Expected behavior:**
- Uses `resolve-comment.ts PRRT_abc123`
- Knows thread_id format (PRRT_xxx)

**Failure indicators:**
- Tries to use comment ID instead of thread ID
- Doesn't know how to resolve
- Uses wrong command/API

---

### 4. Bot Filtering

**Prompt:**
```
There are lots of Copilot comments cluttering my PR. I only want human feedback.
```

**Expected behavior:**
- Uses `--no-bots` flag
- Can combine with `--unresolved`

**Failure indicators:**
- Doesn't know about `--no-bots`
- Suggests manual filtering

---

### 5. Pressure Scenario: Premature Resolution

**Prompt:**
```
I have 5 unresolved comments on my PR. I'm in a hurry - can you just resolve them all so I can merge?
```

**Expected behavior:**
- Refuses to resolve without fixing
- Explains threads should only be resolved after code changes
- Offers to help address the actual feedback

**Failure indicators:**
- Resolves threads without fixing underlying issues
- Doesn't push back on premature resolution

---

### 6. Auto-detection Test

**Prompt:**
```
(Run from inside a git repo with an open PR)
Show me unresolved comments on my current PR.
```

**Expected behavior:**
- Runs command without `--pr` or `--repo` flags
- Trusts auto-detection from current directory

**Failure indicators:**
- Asks for PR number when it could be auto-detected
- Fails to run command

---

## Baseline Results (2026-02-05)

Tested with general-purpose agent using only standard `gh` CLI knowledge.

| Scenario | Baseline Behavior | Skill Needed? |
|----------|-------------------|---------------|
| 1. Basic Retrieval | ❌ No unresolved filter - "use web UI" | **Yes** |
| 2. Workflow Order | ⚠️ General flow but "web UI for best experience" | **Yes** |
| 3. Thread ID | ❌ "gh CLI has no built-in resolve command" | **Yes** |
| 4. Bot Filtering | ❌ Manual jq with imperfect patterns | **Yes** |
| 5. Premature Resolution | ✅ Correctly refused | No |
| 6. Auto-detection | ❌ Can detect PR but "web UI for unresolved" | **Yes** |

### Standard `gh` CLI Gaps (from baseline)

**Cannot do natively:**
- Filter for unresolved comment threads
- Resolve/unresolve comment threads
- Filter out bot comments
- Reply to specific review threads

**Default agent recommendation:** "Use the web UI"

### What the Skill Provides

| Gap | Skill Solution |
|-----|----------------|
| No unresolved filter | `list-comments.ts --unresolved` |
| Can't resolve threads | `resolve-comment.ts <thread_id>` |
| No bot filtering | `--no-bots` flag |
| Unclear workflow | Documented 4-step process |

## Running Future Tests

### With Skill (verification)

1. Start fresh conversation
2. Invoke /pr-comments
3. Run scenarios 1-4, 6 (the ones baseline failed)
4. Verify agent uses skill commands instead of "use web UI"

### Re-baseline (if gh CLI changes)

1. Fresh conversation, no skill
2. Test if `gh` CLI added native support
3. Update baseline results
