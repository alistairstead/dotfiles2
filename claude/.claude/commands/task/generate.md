# Generate Implementation Tasks

<instructions>
You are a senior engineering manager breaking down a feature PRD into atomic, executable tasks for agentic workflows. Focus on clear dependencies and TDD structure.
</instructions>

<arguments>
PRD path or name: $ARGUMENTS
</arguments>

## Step 1: Load PRD Context

<input_handling>
- If $ARGUMENTS contains "/" or ends with ".md", treat as file path
- If $ARGUMENTS is a name, look for `docs/prds/$ARGUMENTS-prd.md` or `docs/prds/$ARGUMENTS.md`
- If file not found, prompt for correct PRD path
- Load the PRD and extract feature requirements
</input_handling>

@$ARGUMENTS

## Step 2: Analyze Dependencies and Extract Implementation Context

Identify task dependencies by analyzing:
- **Sequential requirements**: Database → API → Frontend → Integration
- **Parallel opportunities**: Frontend components can develop alongside API
- **External dependencies**: Third-party services, authentication systems
- **Testing dependencies**: Tests must be written before implementation (TDD)

## Step 2.5: Extract PRD Implementation Context

**Parse PRD for actionable implementation details:**

1. **User Stories → Test Cases**:
   - Extract specific acceptance criteria with Given-When-Then scenarios
   - Identify edge cases and error conditions from user stories
   - Map user flows to specific component interactions

2. **Technical Specifications → Implementation Guidance**:
   - API specifications → Exact endpoint schemas, request/response formats
   - Database changes → Schema definitions, migration scripts, indexing strategy
   - Frontend requirements → Component structures, props interfaces, state management
   - Architecture impact → Integration patterns, data flow, system interactions

3. **Business Rules → Validation Logic**:
   - Extract specific validation requirements and error messages
   - Identify business constraints and enforcement rules
   - Document authorization and access control requirements

4. **Performance & Security → Concrete Requirements**:
   - Performance metrics → Specific benchmarks and optimization targets
   - Security requirements → Authentication patterns, input validation, data protection
   - Non-functional requirements → Accessibility standards, browser compatibility

5. **Integration Context from Base PRD**:
   - Technology stack patterns to follow
   - Existing architectural conventions
   - Code quality standards and testing approaches
   - Anti-patterns to avoid

## Step 3: Generate Task Breakdown

Create `docs/tasks/[feature-name]-tasks.md` using the agentic template:

@~/.claude/templates/task-template.md

**Task Generation Requirements**:

1. **Unique Task IDs**: Use `[feature-prefix]-[number]` format (e.g., `auth-001`, `auth-002`)

2. **TDD Structure**: Each task includes:
   - Tests to write first (red phase)
   - Implementation to make tests pass (green phase)
   - Clear completion criteria

3. **Agent-Friendly Format**:
   - Clear deliverable file paths
   - Status tracking for cross-agent handoffs
   - Agent assignment (job title or specific agent name)
   - No time estimates (agents work differently than humans)
   - Specific completion criteria

4. **Dependency Management**:
   - List prerequisite task IDs
   - Support parallel task execution where possible
   - Identify critical path through dependency chain

**Task Categories**:
- **Foundation**: Database, infrastructure, basic scaffolding
- **Core Implementation**: Business logic, API endpoints, frontend components
- **Integration**: Connecting systems, data flow, user experience
- **Quality Assurance**: Performance, security, documentation

**Completion Criteria Standards**:
- All tests pass (unit, integration, acceptance)
- Code meets quality standards (linting, type checking)
- Feature works end-to-end as specified in PRD
- Documentation updated

Replace template placeholders with:
- `[Feature Name]` → Actual feature name from PRD
- `[task-id-X]` → Sequential task IDs with feature prefix
- `[feature]` → Lowercase feature name for file paths
- `[ext]` → Appropriate file extensions for project
- `[agent-type]` → Appropriate agent type or job title for the task
- `[PRD-Context]` → Extracted implementation details from PRD analysis
- `[User-Story]` → Specific user story this task implements
- `[Acceptance-Criteria]` → Exact criteria from PRD with examples
- `[Business-Rules]` → Validation rules and constraints
- `[API-Schema]` → Endpoint specifications with request/response examples
- `[DB-Schema]` → Database structure, relationships, migration code
- `[Component-Structure]` → Props interface, state management patterns
- `[Code-Examples]` → Implementation patterns from PRD research
- `[Performance-Targets]` → Specific benchmarks and optimization goals
- Test descriptions → Specific test requirements from PRD user stories

**Agent Assignment Guidelines**:
- **Backend tasks**: backend-engineer, api-developer, database-engineer
- **Frontend tasks**: frontend-engineer, ui-developer, react-developer
- **Full-stack tasks**: fullstack-engineer, integration-specialist
- **QA tasks**: qa-engineer, testing-specialist, performance-engineer
- **DevOps tasks**: devops-engineer, infrastructure-specialist
- **Security tasks**: security-engineer, security-specialist
- **Documentation tasks**: technical-writer, documentation-specialist

**Agent Handoff Requirements**:
- Include clear status tracking mechanism
- Document blockers and resolution paths
- Specify file locations for all deliverables
- Reference PRD sections for context
