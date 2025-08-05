# Orchestrate Multi-Agent Task Execution

<instructions>
You are a task orchestration agent coordinating specialist sub-agents to execute implementation tasks in parallel. Route tasks to appropriate agents based on their expertise and manage concurrent execution.
</instructions>

<arguments>
Task file path or name: $ARGUMENTS
</arguments>

## Step 1: Load Task File and Parse Agent Assignments

<input_handling>
- If $ARGUMENTS contains "/" or ends with ".md", treat as file path
- If $ARGUMENTS is a name, look for `docs/tasks/$ARGUMENTS-tasks.md` or `docs/tasks/$ARGUMENTS.md`
- If file not found, prompt for correct task file path
- Load task file and parse task statuses and agent assignments
</input_handling>

@$ARGUMENTS

## Step 2: Analyze Tasks for Parallel Execution

**Parse task information:**
- Identify all tasks with current status (pending, in_progress, completed, blocked)
- Map dependency relationships between tasks
- Group tasks by agent type for routing
- Find tasks ready for parallel execution (no conflicting dependencies)

**Parallel execution analysis:**
- Tasks with no dependencies can start immediately
- Tasks with same dependencies can run in parallel
- Different agent types can work simultaneously on independent tasks

**Current project state:**
!git status
!git log --oneline -5

## Step 3: Route Tasks to Specialist Agents

**Agent routing approach:**
- Route tasks to sub agents based on **Agent** field specified in each task
- Sub agent types are determined by the task requirements and project context
- Common sub agent specializations include backend, frontend, fullstack, qa, devops, security, performance, and technical writing roles
- Sub agent definitions are created contextually using the `task agents` command when needed

**Dynamic agent discovery:**
!ls ~/.claude/agents/ 2>/dev/null || echo "No agents directory found - agents will be created as needed"

**Task routing strategy:**
1. **Group available tasks by agent type** (from **Agent** field in tasks)
2. **Identify parallel execution opportunities** (tasks with satisfied dependencies)
3. **Route tasks to appropriate specialist agents** (matching agent type or general-purpose fallback)
4. **Coordinate execution timing based on dependencies** (respect prerequisite chains)

### Agent Task Assignment

For each available task:

```markdown
## Task Routing: [task-id] - [description]

### Agent Assignment
- **Assigned Agent**: [agent-type from task]
- **Backup Agent**: general-purpose (if specialist unavailable)
- **Dependencies**: [list of prerequisite task IDs]
- **Parallel Group**: [tasks that can run simultaneously]

### Execution Coordination
- **Start Condition**: Dependencies [task-ids] completed
- **Parallel With**: [other task-ids that can run concurrently]
- **Blocks**: [task-ids that depend on this completion]
```

## Step 4: Coordinate Parallel Execution

**Execution orchestration:**

1. **Identify parallel execution groups**:
   - Tasks with no dependencies (can start immediately)
   - Tasks with identical satisfied dependencies
   - Tasks assigned to different agent types

2. **Launch specialist agents concurrently**:
   - Route each task to appropriate agent using Task tool
   - Provide agent with specific task context and requirements
   - Monitor execution status across all agents

3. **Manage execution coordination**:
   - Track completion status across all agents
   - Update task file as agents complete work
   - Unblock dependent tasks as prerequisites complete

### Multi-Agent Task Execution

Use Task tool to launch specialist agents:

```markdown
## Launching Parallel Agent Execution

### Backend Tasks (backend-engineer agent)
- [task-id-1]: Database schema implementation
- [task-id-3]: API endpoint development
- [task-id-5]: Business logic implementation

### Frontend Tasks (frontend-engineer agent)
- [task-id-2]: Component development
- [task-id-4]: UI implementation
- [task-id-6]: User interaction handling

### QA Tasks (qa-engineer agent)
- [task-id-7]: Test implementation
- [task-id-8]: Performance validation
- [task-id-9]: Quality gates verification
```

## Step 5: Agent Coordination and Status Management

**Real-time coordination:**

1. **Launch agents for parallel execution**:
   - Use Task tool with appropriate subagent_type
   - Provide each agent with task-specific context
   - Include dependency information and completion criteria

2. **Monitor execution progress**:
   - Track status updates from each agent
   - Coordinate task file updates
   - Manage dependency chains as tasks complete

3. **Handle agent coordination**:
   - Resolve conflicts between agents
   - Coordinate shared resource access
   - Manage git merge conflicts from parallel work

### Agent Communication Protocol

**Task assignment format for sub-agents:**
```
Agent: [agent-type]
Task: [task-id] - [description]
Context: Load task file $ARGUMENTS and execute task [task-id]
Requirements:
- Update task status to in_progress before starting
- Follow TDD approach (tests first, then implementation)
- Run quality gates before marking complete
- Update task status with completion details
- Commit changes with descriptive message
Dependencies: [prerequisite task-ids must be completed]
```

## Step 6: Dependency Resolution and Flow Control

**Dependency management:**

1. **Track completion events**:
   - Monitor when prerequisite tasks complete
   - Automatically unblock dependent tasks
   - Launch newly available tasks to appropriate agents

2. **Handle blocking scenarios**:
   - If task blocks, determine impact on dependent tasks
   - Reroute parallel work to unblocked tasks
   - Escalate blockers requiring manual resolution

3. **Coordinate completion**:
   - Ensure all parallel work integrates properly
   - Run integration tests after parallel completion
   - Validate no conflicts from concurrent development

### Parallel Execution Monitoring

**Progress tracking:**
- Track completion percentage across all parallel streams
- Identify bottlenecks in dependency chains
- Report overall progress and estimated completion
- Highlight any blockers requiring attention

**Quality coordination:**
- Ensure all agents follow same quality standards
- Coordinate test execution to avoid conflicts
- Manage shared resources (databases, environments)
- Validate integration after parallel work

## Step 7: Integration and Completion

**Final coordination:**

1. **Integration validation**:
   - Run full test suite after all parallel work
   - Validate no conflicts from concurrent development
   - Ensure all deliverables integrate properly

2. **Quality gates**:
   - All tests pass across all components
   - No integration conflicts or failures
   - All quality standards met

3. **Progress reporting**:
   - Summary of completed tasks by agent
   - Overall feature completion status
   - Next steps or remaining work

**Completion criteria:**
- All tasks marked as completed or appropriately blocked
- No integration conflicts from parallel development
- All quality gates passed
- Task file updated with final status

## Error Handling and Recovery

**Multi-agent error management:**

1. **Agent failure recovery**:
   - If specialist agent fails, fall back to general-purpose agent
   - Reroute blocked tasks to available agents
   - Maintain execution momentum despite individual failures

2. **Conflict resolution**:
   - Handle git merge conflicts from parallel work
   - Coordinate shared resource access
   - Resolve integration issues between parallel streams

3. **Dependency chain failures**:
   - If blocking task fails, pause dependent tasks
   - Reroute resources to unblocked parallel work
   - Escalate critical blockers for manual resolution

IMPORTANT: Always maintain task file accuracy for cross-agent coordination. Each agent must update task status to prevent conflicts and ensure smooth parallel execution.
