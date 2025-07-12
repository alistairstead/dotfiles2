# Generate Implementation Tasks

<instructions>
You are a senior engineering manager with expertise in task decomposition and project planning. Break down the feature PRD into atomic, executable tasks organized in logical phases.
</instructions>

<task_decomposition_principles>
Each task must be:

- Atomic: Single, well-defined action
- Estimable: 4-16 hours of work
- Testable: Clear completion criteria
- Independent: Minimal external dependencies within phase
- Assigned: Clear ownership and skills required
  </task_decomposition_principles>

<arguments>
Feature: $ARGUMENTS
</arguments>

## Step 1: Load Feature Context

@prds/feature-prd.md

<understanding>
I have the complete feature specification including user stories, technical requirements, and success criteria. Now I'll decompose this into executable tasks following proven software engineering practices.
</understanding>

## Step 2: Dependency Analysis

<dependency_mapping>
Using Critical Path Method (CPM) thinking to identify:

- Sequential dependencies (must finish before starting)
- Parallel opportunities (can work simultaneously)
- Resource constraints (team member availability)
- External dependencies (APIs, third-party services)
- Infrastructure dependencies (environments, tooling)
  </dependency_mapping>

## Step 3: Phase Organization

<phase_planning>
Organizing tasks into logical phases based on:

- Technical dependency order
- Risk mitigation strategy (high-risk items early)
- Value delivery milestones (MVP → enhancements)
- Team coordination needs
- Testing and validation points
  </phase_planning>

## Step 4: Task Generation

Create `tasks/feature-tasks.md`:

````markdown
# Implementation Tasks: [Feature Name]

## Overview

**Total Estimated Effort**: [X] story points / [Y] hours
**Estimated Duration**: [Z] weeks with [N] developers
**Critical Path**: [Longest dependency chain]

## Task Dependency Graph

```mermaid
setup-1 → test-1 → impl-1 → integration-1
↘ impl-2 ↗
```
````

## Phase 1: Foundation & Infrastructure (Sprint 1)

### Task 1.1: Database Schema Design

- **Description**: Design and review database schema changes for [feature]
- **Acceptance Criteria**:
  - Schema migration scripts created and reviewed
  - Indexing strategy documented and implemented
  - Backward compatibility verified
- **Estimate**: 8 hours
- **Owner**: Backend Engineer
- **Dependencies**: None
- **Deliverables**:
  - Migration scripts in `db/migrations/`
  - Schema documentation updated
- **Quality Gates**:
  - Schema review by senior engineer
  - Migration tested in staging environment

### Task 1.2: API Endpoint Scaffolding

- **Description**: Create basic API endpoint structure with authentication
- **Acceptance Criteria**:
  - RESTful endpoints created following project conventions
  - Authentication middleware integrated
  - Basic validation implemented
- **Estimate**: 6 hours
- **Owner**: Backend Engineer
- **Dependencies**: Task 1.1 (database schema)
- **Deliverables**:
  - API endpoints in `src/api/`
  - OpenAPI documentation updated
- **Quality Gates**:
  - Unit tests for endpoint routing
  - Integration tests for authentication

### Task 1.3: Frontend Component Architecture

- **Description**: Design and implement reusable component structure
- **Acceptance Criteria**:
  - Component hierarchy designed and documented
  - Shared components created following design system
  - State management pattern established
- **Estimate**: 10 hours
- **Owner**: Frontend Engineer
- **Dependencies**: None
- **Deliverables**:
  - Components in `src/components/`
  - Storybook stories for visual testing
- **Quality Gates**:
  - Component unit tests
  - Visual regression tests

### Task 1.4: DevOps Environment Setup

- **Description**: Configure development and staging environments
- **Acceptance Criteria**:
  - Feature branch deployments automated
  - Environment variables configured
  - Monitoring and logging enabled
- **Estimate**: 4 hours
- **Owner**: DevOps Engineer
- **Dependencies**: None
- **Deliverables**:
  - Updated CI/CD pipeline configuration
  - Environment documentation
- **Quality Gates**:
  - Successful automated deployment
  - Health check endpoints responding

## Phase 2: Core Feature Implementation (Sprint 2)

### Task 2.1: Core Business Logic Implementation

- **Description**: Implement the primary feature functionality
- **Acceptance Criteria**:
  - All user stories from PRD implemented
  - Business rules enforced
  - Error handling implemented
- **Estimate**: 16 hours
- **Owner**: Backend Engineer
- **Dependencies**: Task 1.1, Task 1.2
- **Deliverables**:
  - Business logic in `src/services/`
  - Comprehensive unit tests
- **Quality Gates**:
  - Code coverage > 80%
  - Integration tests passing

### Task 2.2: User Interface Implementation

- **Description**: Build complete user interface for feature
- **Acceptance Criteria**:
  - All UI mockups implemented pixel-perfect
  - Responsive design working on all breakpoints
  - Accessibility requirements met (WCAG AA)
- **Estimate**: 20 hours
- **Owner**: Frontend Engineer
- **Dependencies**: Task 1.3, Task 2.1 (for API integration)
- **Deliverables**:
  - Complete UI implementation
  - Accessibility audit report
- **Quality Gates**:
  - Cross-browser testing completed
  - Accessibility testing with screen reader

### Task 2.3: API Integration and Data Flow

- **Description**: Connect frontend to backend APIs with proper error handling
- **Acceptance Criteria**:
  - All API calls implemented with proper error handling
  - Loading states and error messages implemented
  - Data validation on both client and server
- **Estimate**: 12 hours
- **Owner**: Full-Stack Engineer
- **Dependencies**: Task 2.1, Task 2.2
- **Deliverables**:
  - API integration layer
  - Error handling documentation
- **Quality Gates**:
  - End-to-end tests covering happy path
  - Error scenario testing completed

## Phase 3: Integration & Polish (Sprint 3)

### Task 3.1: Performance Optimization

- **Description**: Optimize feature performance based on requirements
- **Acceptance Criteria**:
  - Page load time < 2 seconds
  - API response time < 500ms for 95th percentile
  - Memory usage within acceptable limits
- **Estimate**: 8 hours
- **Owner**: Senior Engineer
- **Dependencies**: Task 2.3
- **Deliverables**:
  - Performance optimization report
  - Monitoring dashboards updated
- **Quality Gates**:
  - Load testing results meeting SLA
  - Performance monitoring alerts configured

### Task 3.2: Security Review and Hardening

- **Description**: Conduct security review and implement hardening measures
- **Acceptance Criteria**:
  - Security scan completed with no high-severity issues
  - Input validation reviewed and strengthened
  - Authorization controls verified
- **Estimate**: 6 hours
- **Owner**: Security Engineer
- **Dependencies**: Task 2.3
- **Deliverables**:
  - Security review report
  - Penetration testing results
- **Quality Gates**:
  - OWASP security scan passing
  - Security review approved

### Task 3.3: Documentation and Knowledge Transfer

- **Description**: Create comprehensive documentation for the feature
- **Acceptance Criteria**:
  - User documentation written and reviewed
  - Technical documentation updated
  - Team knowledge transfer completed
- **Estimate**: 4 hours
- **Owner**: Technical Writer + Team Lead
- **Dependencies**: All previous tasks
- **Deliverables**:
  - User guide documentation
  - Technical architecture documentation
- **Quality Gates**:
  - Documentation review by product team
  - Knowledge transfer session completed

## Quality Gates and Checkpoints

### Phase 1 Completion Criteria

- All infrastructure tasks completed and tested
- Development environment fully functional
- Basic scaffolding deployed to staging

### Phase 2 Completion Criteria

- Core functionality implemented and tested
- User acceptance testing completed
- Performance baseline established

### Phase 3 Completion Criteria

- All acceptance criteria met
- Security review passed
- Documentation completed
- Ready for production deployment

## Risk Mitigation and Contingency Plans

### High-Risk Tasks

- **Task 2.1** (Core Logic): Schedule extra review time, pair programming
- **Task 2.2** (UI Implementation): Early design validation, incremental review

### Dependency Management

- **External API delays**: Implement mock services for development
- **Resource conflicts**: Cross-training plan for critical tasks
- **Technical blockers**: Escalation path to architecture team

## Progress Tracking and Communication

### Daily Updates

- Task completion status
- Blockers and impediments
- Updated time estimates

### Weekly Reviews

- Phase progress assessment
- Risk evaluation and mitigation
- Stakeholder communication

### Milestone Demonstrations

- End of Phase 1: Infrastructure demo
- End of Phase 2: Feature demo to stakeholders
- End of Phase 3: Production readiness review

```

**Remember**: Good tasks are specific, testable, and sized for steady progress.
**Remember**: The tasks should be written for a **Junior Developer**, so keep them clear and straightforward.
```
