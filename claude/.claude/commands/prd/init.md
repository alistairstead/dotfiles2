# Initialize Project PRD Template

<instructions>
You are a senior technical analyst creating the foundational PRD template for this project. This template will serve as the base context for all feature PRDs. Follow these steps systematically.
</instructions>

<analysis_framework>
Apply MECE (Mutually Exclusive, Collectively Exhaustive) thinking to ensure comprehensive, non-overlapping analysis coverage.
</analysis_framework>

<thinking>
I need to understand this project deeply by analyzing its structure, technology stack, architectural patterns, and business context. This analysis will become the foundation that all feature PRDs build upon.

Let me examine:

1. Project structure and organization
2. Technology stack and dependencies
3. Existing patterns and conventions
4. Business domain and user base
5. Quality standards and processes
   </thinking>

## Step 1: Project Structure Analysis

First, I'll analyze the codebase structure to understand architectural patterns:

!find . -type f -name "_.json" -o -name "_.yaml" -o -name "_.yml" -o -name "_.toml" -o -name "\*.md" | head -20

!ls -la

<project_analysis>
Examining the project structure to identify:

- Package managers and dependency files
- Configuration files and their purposes
- Documentation patterns
- Directory organization principles
- Build and deployment configurations
  </project_analysis>

## Step 2: Technology Stack Detection

!if [ -f "package.json" ]; then echo "=== Node.js Project ===" && cat package.json; fi
!if [ -f "requirements.txt" ]; then echo "=== Python Project ===" && cat requirements.txt; fi
!if [ -f "Cargo.toml" ]; then echo "=== Rust Project ===" && cat Cargo.toml; fi
!if [ -f "pom.xml" ]; then echo "=== Java Project ===" && cat pom.xml; fi
!if [ -f "go.mod" ]; then echo "=== Go Project ===" && cat go.mod; fi

<tech_stack_analysis>
Based on the detected configuration files, I'll identify:

- Primary programming languages and frameworks
- Major dependencies and their purposes
- Development and production tooling
- Testing frameworks and quality tools
- Deployment and infrastructure patterns
  </tech_stack_analysis>

## Step 3: Quality Standards Assessment

!if [ -f ".eslintrc.js" ] || [ -f ".eslintrc.mjs" ] || [ -f ".eslintrc.cjs" ] || [ -f ".eslintrc.ts" ] || [ -f ".eslintrc.json" ]; then echo "ESLint configuration found"; fi
!if [ -f "jest.config.js" ] || [ -f "jest.config.mjs" ] || [ -f "jest.config.cjs" ] || [ -f "jest.config.ts" ] || [ -f "vitest.config.js" ] || [ -f "vitest.config.mjs" ] || [ -f "vitest.config.cjs" ] || [ -f "vitest.config.ts" ] || [ -f "package.json" ]; then echo "Testing framework detected"; fi
!if [ -f "sonar-project.properties" ]; then echo "SonarQube integration found"; fi
!if [ -f ".github/workflows" ]; then echo "GitHub Actions workflows:" && ls .github/workflows/; fi

## Step 4: Documentation and Context Gathering

@README.md
@CONTRIBUTING.md
@docs/

<context_synthesis>
Now I'll synthesize all this information into a comprehensive base PRD template that captures:

- Project mission and business context
- Technical architecture and constraints
- User personas and primary use cases
- Quality standards and development practices
- Integration patterns and external dependencies
  </context_synthesis>

## Generate Base PRD Template

Create `prds/templates/base-prd.md` with the following structure:

````markdown
# Base PRD Template for [Project Name]

## Project Context

[Auto-generated from analysis]

### Documentation & References (list all context needed to implement the feature)

```yaml
# MUST READ - Include these in your context window
- url: [Official API docs URL]
  why: [Specific sections/methods you'll need]

- file: [path/to/file]
  why: [Pattern to follow, gotchas to avoid]

- doc: [Library documentation URL]
  section: [Specific section about common pitfalls]
  critical: [Key insight that prevents common errors]

- docfile: [path/to/documentation/file]
  why: [docs that exist in the project]
```

### Technology Stack

[Detected technologies, frameworks, and key dependencies]

### Architecture Overview

[Identified patterns, structure, and design principles]

#### Current Codebase tree (run `tree` in the root of the project) to get an overview of the codebase

```bash

```
````

#### Desired Codebase tree with files to be added and responsibility of file

```bash

```

### Quality Standards

[Testing requirements, code quality gates, and review processes]

### User Base & Business Context

[Target users, business domain, and key objectives]

### Integration Landscape

[External services, APIs, and system dependencies]

## Feature PRD Template Structure

### Executive Summary

- Problem statement
- Solution approach
- Success metrics

### Requirements Analysis

- User stories (INVEST criteria)
- Acceptance criteria (Given-When-Then format)
- Edge cases and error scenarios

### Technical Specifications

- Architecture changes required
- API specifications
- Database schema changes
- Security considerations

### Implementation Plan

- Development phases
- Dependencies and blockers
- Testing strategy
- Rollout plan

### Success Metrics

- Key Performance Indicators
- User experience metrics
- Technical performance metrics
- Business impact measurements

## Final validation Checklist

- [ ] All tests pass
- [ ] No linting errors
- [ ] No type errors
- [ ] Manual test successful
- [ ] Error cases handled gracefully
- [ ] Logs are informative but not verbose
- [ ] Documentation updated if needed

---

## Anti-Patterns to Avoid

- ❌ Don't create new patterns when existing ones work
- ❌ Don't skip validation because "it should work"
- ❌ Don't ignore failing tests - fix them
- ❌ Don't use sync functions in async context
- ❌ Don't hardcode values that should be config
- ❌ Don't catch all exceptions - be specific

```

```
