# Process Implementation Tasks

<instructions>
You are an autonomous development agent coordinating with other agents to complete implementation tasks. Execute tasks systematically with comprehensive quality gates and progress tracking.
</instructions>

<execution_framework>
Apply the Saga pattern for distributed task execution:

- Orchestrator coordinates task sequence
- Each task maintains completion state
- Compensating actions handle failures
- Quality gates prevent progression with issues
  </execution_framework>

<arguments>
Phase Number: $ARGUMENTS (e.g., "1", "2", "3", or "all")
</arguments>

## Step 1: Load Task Context and Current State

@tasks/feature-tasks.md
@prds/feature-prd.md

<state_assessment>
Analyzing current project state to determine:

- Which tasks are already completed
- Which tasks are in progress
- What dependencies are satisfied
- What quality gates have been passed
  </state_assessment>

!git status
!git log --oneline -10

## Step 2: Phase Selection and Task Orchestration

<phase_coordination>
Based on the requested phase, I'll:

- Validate all dependencies are satisfied
- Check prerequisite quality gates
- Prepare execution environment
- Initialize progress tracking
  </phase_coordination>

### Initialize TODO Management

Create or update `tasks/todo-active.md`:

```markdown
# Active Task Execution: Phase $ARGUMENTS

## Execution Status: IN_PROGRESS

**Started**: [Current timestamp]
**Phase**: $ARGUMENTS
**Estimated Completion**: [Based on task estimates]

## Task Queue Status

### Ready for Execution

[Tasks with satisfied dependencies]

### Blocked

[Tasks waiting for dependencies]

### In Progress

[Currently executing tasks]

### Completed

[Finished tasks with quality gates passed]

### Failed

[Tasks that failed quality gates or execution]
```

## Step 3: Task Execution Engine

<task_execution>
For each task in the selected phase, I'll:

Verify dependencies and prerequisites
Execute the task implementation
Run quality gates and validation
Update progress and prepare next task
Handle errors with compensating actions
</task_execution>

Execute Task Implementation
For each task, I'll follow this pattern:

```markdown
## Executing Task: [Task ID - Description]

### Pre-Execution Validation

- [ ] Dependencies satisfied
- [ ] Environment ready
- [ ] Resources available
- [ ] Quality gates from previous tasks passed

### Implementation Steps

[Specific steps based on task type]

### Quality Gate Execution

[Run tests, linting, security scans, etc.]

### Progress Update

[Update task status and prepare handoff]
```

## Step 4: Quality Gate Orchestration

<quality_gates>
Implementing comprehensive quality gates based on project standards:

Code quality and formatting
Unit test coverage and passing
Integration test validation
Security scan results
Performance benchmark validation
Documentation completeness
</quality_gates>

Code Quality Gates

```bash
# ESLint/Prettier for code formatting
!bun run lint
!bun run format:check

# TypeScript type checking
!bun run typecheck

# Unit test execution with coverage
!bun run test:coverage

# Integration tests
!bun run test:integration
```

Security and Performance Gates

```bash
# Security vulnerability scanning
!bun audit --audit-level moderate

# Bundle size analysis (if frontend)
!bun run analyze:bundle

# Performance testing (if applicable)
!bun run test:performance
```

Documentation and Deployment Gates

```bash
# Documentation completeness check
!find docs/ -name "*.md" -exec grep -l "TODO\|FIXME\|XXX" {} \;

# Build verification
!bun run build

# Deployment readiness check
!bun run deploy:check
```

## Step 5: Progress Tracking and State Management

<progress_management>
Maintaining detailed progress information for coordination with other agents and team members:

Real-time task completion status
Quality gate results and trends
Blocker identification and resolution
Resource utilization and estimates
</progress_management>

Update Task Status

```markdown
## Task Progress Update

### Task: [Current Task ID]

**Status**: [NOT_STARTED | IN_PROGRESS | BLOCKED | COMPLETED | FAILED]
**Progress**: [Percentage complete]
**Time Spent**: [Actual vs estimated]
**Quality Gates**: [Passed/Failed with details]
**Blockers**: [Any impediments encountered]
**Next Steps**: [What happens next]

### Overall Phase Progress

**Completed Tasks**: X of Y
**Overall Progress**: Z%
**Estimated Completion**: [Updated estimate]
**Risk Level**: [GREEN | YELLOW | RED]
```

## Step 6: Multi-Agent Coordination

<agent_coordination>
Facilitating handoffs and coordination between different agents:

Backend agents for API implementation
Frontend agents for UI development
DevOps agents for infrastructure
QA agents for testing validation
Documentation agents for knowledge capture
</agent_coordination>

Agent Handoff Protocol

```markdown
## Agent Handoff: [From Agent] → [To Agent]

### Context Transfer

- **Completed Work**: [Summary of what was finished]
- **Current State**: [Exact state of code/systems]
- **Quality Status**: [All quality gates and their status]
- **Known Issues**: [Any problems or concerns]
- **Next Actions**: [What the receiving agent should do]

### Verification Checklist

- [ ] All artifacts committed to version control
- [ ] Quality gates documented and accessible
- [ ] Environment state is clean and reproducible
- [ ] Documentation updated with current state
- [ ] Receiving agent has all necessary context
```

## Step 7: Error Handling and Recovery

<error_handling>
Implementing robust error handling with compensating transactions:

Automatic rollback of failed changes
Clear error reporting and diagnosis
Recovery procedures for common failures
Escalation paths for critical issues
</error_handling>

Failure Recovery Protocol

```markdown
## Error Recovery: [Task ID] Failed

### Failure Analysis

**Error Type**: [Compilation | Test | Quality Gate | Integration]
**Root Cause**: [Detailed analysis of what went wrong]
**Impact Assessment**: [What else might be affected]

### Compensating Actions

- [ ] Rollback incomplete changes
- [ ] Restore previous working state
- [ ] Update task status and dependencies
- [ ] Notify dependent agents/tasks

### Recovery Plan

**Immediate Actions**: [Steps to stabilize]
**Resolution Approach**: [How to fix the underlying issue]
**Prevention**: [How to avoid this in the future]
```

## Step 8: Completion and Handoff

<completion_protocol>
Ensuring clean completion with full documentation:

All quality gates passed and documented
Progress tracking updated
Next phase prepared
Knowledge captured for future reference
</completion_protocol>

Phase Completion Report

```markdown
# Phase $ARGUMENTS Completion Report

## Executive Summary

**Phase Status**: [COMPLETED | PARTIALLY_COMPLETED | FAILED]
**Completion Date**: [Timestamp]
**Total Effort**: [Actual vs estimated hours]
**Quality Score**: [Aggregate quality gate results]

## Task Summary

[Detailed breakdown of each task completion status]

## Quality Gate Results

[Comprehensive report of all quality validations]

## Issues and Resolutions

[Any problems encountered and how they were resolved]

## Handoff to Next Phase

**Prerequisites Satisfied**: [All dependencies for next phase]
**Environment State**: [Current state of development environment]
**Known Risks**: [Any concerns for upcoming work]
**Recommendations**: [Suggestions for next phase execution]

## Lessons Learned

[Process improvements and knowledge for future iterations]
```
