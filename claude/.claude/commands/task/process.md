# Process Implementation Tasks

<instructions>
You are an autonomous development agent executing implementation tasks. Process tasks systematically, ensure tests pass, and update task status for coordination with other agents.
</instructions>

<arguments>
Task file path or name: $ARGUMENTS
</arguments>

## Step 1: Load Task File and Assess Status

<input_handling>
- If $ARGUMENTS contains "/" or ends with ".md", treat as file path
- If $ARGUMENTS is a name, look for `docs/tasks/$ARGUMENTS-tasks.md` or `docs/tasks/$ARGUMENTS.md`
- If file not found, prompt for correct task file path
- Load task file and parse current task statuses
</input_handling>

@$ARGUMENTS

## Step 2: Analyze Task Dependencies and Status

**Parse task information:**
- Identify all tasks with current status (pending, in_progress, completed, blocked)
- Map dependency relationships between tasks
- Find tasks ready for execution (dependencies satisfied + status = pending)
- Verify no tasks are already in_progress by other agents

**Current project state:**
!git status
!git log --oneline -5

## Step 3: Select and Execute Available Task

**Task selection criteria:**
- Status must be "pending"
- All dependency tasks must be "completed"
- No conflicting in_progress tasks

**Task execution workflow:**
1. **Update task status to in_progress** in task file
2. **Execute task implementation** following TDD approach
3. **Run quality gates** (tests, linting, type checking)
4. **Update task status** based on results (completed/blocked)
5. **Commit changes** if task completed successfully

### Task Implementation Pattern

For the selected task:

```markdown
## Executing Task: [task-id] - [description]

### Pre-execution
- [x] Dependencies satisfied: [list dependency task IDs]
- [x] Status updated to in_progress
- [x] Environment ready

### TDD Implementation
1. **Write failing tests** (Red phase)
   - Create test files as specified in task deliverables
   - Implement test cases covering acceptance criteria
   - Verify tests fail as expected

2. **Implement minimal code** (Green phase)
   - Write code to make tests pass
   - Focus on meeting acceptance criteria
   - Create deliverable files as specified

3. **Refactor and improve** (Refactor phase)
   - Improve code quality while keeping tests green
   - Follow project conventions and patterns
   - Optimize for readability and performance

### Quality Gates
- [ ] All new tests pass
- [ ] Existing tests still pass
- [ ] Linting rules pass
- [ ] Type checking passes (if applicable)
- [ ] Deliverables created at specified paths

### Status Update
Task status: [completed | blocked | needs_review]
Completion notes: [Brief summary of work done]
```

## Step 4: Essential Quality Validation

Run essential quality gates before marking task complete:

**Core validation:**
!npm run test || bun run test || yarn test
!npm run lint || bun lint || yarn lint
!npm run typecheck || bun typecheck || yarn typecheck

**Build verification:**
!npm run build || bun run build || yarn build

## Step 5: Update Task File Status

**For completed tasks:**
- Change status from "in_progress" to "completed"
- Add completion timestamp
- Note any deviations from original specifications

**For blocked tasks:**
- Change status from "in_progress" to "blocked"
- Document specific blocker and resolution needed
- Identify which agent or action can resolve blocker

**Status update format:**
```markdown
- **Status**: completed
- **Completed**: [timestamp]
- **Agent**: [agent identifier]
- **Notes**: [brief completion summary]
```

## Step 6: Progress Assessment and Next Steps

**After task completion:**
- Identify next available tasks (newly unblocked by completion)
- Commit all changes with descriptive commit message
- Report progress: completed task and next available tasks

**If no more tasks available:**
- Report all remaining tasks and their blocking dependencies
- Suggest next actions for project continuation

**If tasks blocked:**
- Document specific blockers and required resolutions
- Identify which specialist agents could resolve blockers
- Suggest alternative tasks that could proceed in parallel

## Error Handling

**If task execution fails:**
1. Rollback any partial changes (git checkout)
2. Update task status to "blocked" with failure reason
3. Document specific error and potential solutions
4. Identify if issue requires different agent expertise

**If tests fail:**
1. Do not mark task as completed
2. Document failing tests and error messages
3. Keep status as "in_progress" for retry or "blocked" if unable to resolve
4. Suggest next steps for resolution

**Quality gate failures:**
- Document specific quality issues (linting errors, type errors)
- Fix issues or mark task as blocked if resolution unclear
- Ensure all quality gates pass before completion

IMPORTANT: Always update the task file with current status. Other agents depend on accurate status information for coordination and preventing duplicate work.
