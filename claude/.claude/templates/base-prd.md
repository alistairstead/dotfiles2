# Base PRD Template

## Project Context

### Technology Stack
[Detected technologies, frameworks, and key dependencies]

### Architecture Overview
[Identified patterns, structure, and design principles]

#### Current Codebase Structure
```bash
[Project tree output]
```

### Quality Standards
[Testing frameworks, linting rules, and code quality requirements]

### User Base & Business Context
[Target users, business domain, and key objectives]

### Integration Landscape
[External services, APIs, and system dependencies]

### Documentation & References
```yaml
# Critical context for feature implementation
- url: [API documentation URL]
  why: [Required endpoints/methods]

- file: [path/to/pattern/file]
  why: [Pattern to follow or avoid]

- doc: [Library documentation URL]
  section: [Specific implementation guidance]
```

## Development Standards

### Testing Requirements
- Unit tests for all business logic
- Integration tests for API endpoints
- E2E tests for critical user flows

### Code Quality Gates
- All linting rules must pass
- Type checking must pass (if applicable)
- Test coverage minimum thresholds
- Manual testing verification

### Implementation Checklist
- [ ] All tests pass
- [ ] No linting/type errors
- [ ] Manual testing successful
- [ ] Error handling implemented
- [ ] Logging added appropriately
- [ ] Documentation updated

## Anti-Patterns to Avoid
- ❌ Don't create new patterns when existing ones work
- ❌ Don't skip validation because "it should work"
- ❌ Don't ignore failing tests
- ❌ Don't hardcode values that should be configurable
- ❌ Don't catch exceptions too broadly