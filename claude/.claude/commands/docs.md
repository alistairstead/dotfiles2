# AI Coding Assistant Guidelines

This document contains guidelines for AI coding assistants. It is structured with generic best practices that apply to all projects, followed by project-specific sections that should be populated when starting a new project.

## Generic Guidelines (All Projects)

### Project Management

#### Documentation Hierarchy

1. **CLAUDE.md is the source of truth** for all project specifications
2. README.md derives from CLAUDE.md with human-friendly summaries
3. In README.md, include: "For detailed specifications, see CLAUDE.md"
4. Update CLAUDE.md first, then sync README.md for major changes only
5. Keep CLAUDE.md in project root
6. **Use docs/ folder for topical documentation**:
   - Store technical docs, product requirements, and design specs
   - Use lowercase snake_case with date prefix (e.g., color_system.md, logging.md, architecture.md)
   - **Required docs**: `docs/TODO.md` must be created for all projects
   - Maintain an index of these documents in both CLAUDE.md and README.md
   - **AI INSTRUCTION**: Proactively create TODO.md and product_requirements.md if missing, then notify the user

#### TODO.md as Development Log

1. **IMPORTANT**: Maintain `/docs/TODO.md` as central development log and task tracker
2. Include:
   - Current/upcoming tasks (with checkboxes)
   - Development decisions and rationale
   - Recurring issues and their solutions
   - Technical debt items
   - Code audit reminders
3. Update when: starting tasks, making progress, completing tasks, encountering issues
4. Check at start of each session

#### Session Start Checklist

1. Check `/docs/TODO.md` for current state and development log
2. Run `git status` to see uncommitted changes
3. Run code tracking commands (see Maintenance section)
4. Review recent commits: `git log --oneline -5`
5. Check for outdated dependencies (if applicable)

#### Git Usage (Solo Developer)

1. Create git repo for each project with .gitignore
2. Work directly on main branch (no need for feature branches with multiple AI agents sharing same filesystem)
3. Conventional commit format: "type: Brief description" (fix, feat, docs, refactor, test, chore)
4. Before committing: run lint/build checks and verify functionality
5. Keep main branch stable and deployable
6. Commit regularly to track changes and enable rollback if needed

### Development Workflow

#### Planning and Implementation

1. Discuss approach and evaluate pros/cons before coding
2. Make small, testable incremental changes
3. Address code duplication proactively
4. When fixing issues, check for similar problems elsewhere
5. Document recurring issues in TODO.md

#### Code Quality Standards

1. Handle errors properly and validate inputs
2. Follow code conventions and established patterns
3. Never expose secrets/keys
4. Write self-documenting code with type safety
5. Remove debug output before production
6. **Documentation**: Be concise but accurate - avoid verbose explanations
   - Code comments only when necessary for complex logic
   - Documentation should be clear, direct, and to the point
   - Avoid redundant comments that merely describe what code already shows
   - Focus on "why" not "what" when documenting

#### Code Maintenance and Refactoring

1. **AI Tracking Instructions**:
   - Before each session: run `git diff --stat` to see recent changes
   - Track cumulative additions: `git log --numstat --pretty=format:'' | awk '{ add += $1 } END { print add }'`
   - When total additions exceed 500 lines since last audit, prompt user:
     "Added ~500+ lines since last code audit. Should we review for refactoring opportunities?"
   - Add to TODO.md: "Code audit pending (X lines added since DATE)"
2. Automatic refactoring triggers:
   - Duplicate code blocks (3+ occurrences)
   - Functions > 50 lines
   - Files > 300 lines
   - Multiple similar error handlers
3. During audits, check for:
   - Extractable shared utilities
   - Complex functions to split
   - Dead code to remove
   - Performance bottlenecks
4. Track findings in TODO.md under "Notes > Technical Debt"
5. Always refactor before major feature additions

### Debugging and Logging

1. **Use a proper logging framework** instead of console.log
2. Remove console.log statements before committing
3. Clean up debug output before production
4. Minimize linter suppressions
5. Use structured logging with appropriate log levels
6. For framework-specific logging tools, see the relevant section below

## Framework-Specific Guidelines

### Web/Frontend (If Applicable)

#### Technology Stack

1. TypeScript for type safety
2. shadcn/ui for UI components
3. Tailwind CSS for styling
4. React for UI library

#### Component Patterns

1. Keep components focused on single responsibility
2. Extract complex logic to custom hooks
3. Follow container/presentational pattern where appropriate

#### State Management

1. React context for global state
2. Keep state local when possible
3. Use refs for non-rerender values
4. Optimize updates to prevent unnecessary rerenders

#### Performance Practices

1. Remove console.log in production
2. Debounce/throttle UI events
3. Minimize API calls
4. Lazy load components when appropriate

## Project-Specific Sections

**AI INSTRUCTION**: The following sections should be populated when setting up a new project. Update these sections with project-specific information as the project evolves.

### Project Overview [TO BE FILLED]

**[PLACEHOLDER - REPLACE WITH ACTUAL CONTENT]**

1. Project name and purpose
2. Key features and functionality
3. Target users
4. High-level architecture decisions

### Directory Structure [TO BE FILLED]

**[PLACEHOLDER - REPLACE WITH ACTUAL STRUCTURE]**

Document the project's specific folder structure, for example:

1. Where components live
2. API route organization
3. Utility function locations
4. Type definition structure
5. Asset management

### Project Documentation Index [TO BE FILLED]

**[PLACEHOLDER - UPDATE AS DOCS ARE CREATED]**

#### Required documents (AI should create these proactively)

- `/docs/TODO.md` - Development log and task tracker **[REQUIRED]**
- `/docs/product_requirements.md` - Product requirements and specifications **[REQUIRED]**

#### Additional project-specific documents

- `/docs/logging.md` - Logging standards and practices
- `/docs/architecture.md` - System architecture overview

**AI INSTRUCTION:**

1. Check if required docs exist, create them if missing and notify user
2. Add any new documentation files to this index as you create them

### Code Organization Patterns [TO BE FILLED]

**[PLACEHOLDER - DEFINE PROJECT PATTERNS]**

1. Naming conventions
2. File organization rules
3. Import/export patterns
4. Module boundaries

### Domain-Specific Guidelines [TO BE FILLED]

**[PLACEHOLDER - ADD DOMAIN-SPECIFIC RULES]**

1. Business logic rules
2. Data models and schemas
3. API patterns
4. Integration requirements
5. Special considerations

### UI/UX Standards [TO BE FILLED]

**[PLACEHOLDER - SPECIFY DESIGN STANDARDS]**

1. Design system guidelines
2. Accessibility requirements
3. Responsive design rules
4. Animation/transition standards
5. Brand guidelines

### Testing Strategy [TO BE FILLED]

**[PLACEHOLDER - DEFINE TESTING APPROACH]**

1. Testing framework and tools
2. Test file locations
3. Coverage requirements
4. E2E testing approach

### Deployment and Environment [TO BE FILLED]

**[PLACEHOLDER - DOCUMENT DEPLOYMENT PROCESS]**

1. Environment variables
2. Build process
3. Deployment pipeline
4. Monitoring approach

## Development Setup

### First Time Setup [TO BE FILLED]

**[PLACEHOLDER - LIST SETUP STEPS]**

1. Clone repository
2. Install dependencies
3. Environment configuration
4. Database setup
5. Initial data/seed

### Common Commands [TO BE FILLED]

**[PLACEHOLDER - LIST COMMON COMMANDS]**

1. Development server
2. Testing
3. Building
4. Linting
5. Database migrations

---

**Remember**: This document should evolve with the project. Update project-specific sections as you make architectural decisions and establish patterns.

## Appendix

### TODO.md Template

```markdown
# Project Development Log & TODOs

## Tasks

### Current

- [ ] Task description here
- [ ] Task being worked on (50% complete)
  - [x] Subtask completed
  - [ ] Subtask remaining

### Upcoming

- [ ] Future task 1
- [ ] Future task 2

### Done

- [x] Implemented feature ABC (2024-03-15)
- [x] Fixed bug in component XYZ (2024-03-14)

## Notes

### Development Decisions

- Chose X over Y because of performance benefits (DATE)
- Using pattern Z for consistency with existing codebase (DATE)

### Technical Debt

- Refactor X component
- Optimize Y performance issue
- Code audit pending (500+ lines added since DATE)

### Recurring Issues & Solutions

- Build fails with error XYZ → Clear cache with `npm run clean`

### General

- Blocked: External API integration waiting for credentials
- Remember: Always run migrations before deploying
```
