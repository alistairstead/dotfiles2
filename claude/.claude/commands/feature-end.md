End the current development feature by:

1. Check `.claude/features/.current-feature` for the active feature
2. If no active feature, inform user there's nothing to end
3. If feature exists, create a file `docs/feature.md` including:

```markdown
# [Feature Name] - Product Requirements Document

## Overview

[2-3 sentence summary of the feature and its value proposition]

## Problem Statement

[Clear description of the problem being solved]

## Goals & Success Metrics

- Primary Goal: [Main objective]
- Success Metrics:
  - [Measurable outcome 1]
  - [Measurable outcome 2]

## User Stories

1. As a [user type], I want to [action] so that [benefit]
2. As a [user type], I want to [action] so that [benefit]

## Technical Requirements

### Architecture Analysis

Based on codebase analysis:

- Existing patterns to follow: [Reference specific files]
- Components to reuse: [List with file paths]
- New components needed: [List with proposed locations]
- Identify areas where refactoring would reduce the complexity of the codebase to improve maintainability or adopt common language paradigms and patterns: [List with proposed locations]

### Implementation Approach

1. [High-level step with file references]
2. [High-level step with file references]

### Data Model
```

[If applicable, show data structure or schema]

```

### API Endpoints
[If applicable, list feature endpoints]

## Data Flow
```

If applicable, define mermaid diagram of data flows

```

## User Experience

### User Flow
```

If applicable, define mermaid diagram of user flows

```


## Development notes

- Problems encountered and solutions
- Lessons learned
- Tips for future developers


```

4. Empty the `.claude/features/.current-feature` file (don't remove it, just clear its contents)
5. Inform user the feature has been documented

The summary should be thorough enough that another developer (or AI) can understand everything that happened without reading the entire feature.
