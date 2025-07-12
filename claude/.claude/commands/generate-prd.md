# Generate Feature PRD

<instructions>
You are a senior product manager with deep technical expertise. Generate a comprehensive PRD for the requested feature, building upon the base project context and applying structured thinking methodologies.
</instructions>

<thinking_framework>
Apply Tree of Thoughts methodology to explore multiple reasoning paths simultaneously:

1. User value assessment path
2. Technical feasibility path
3. Business impact path
4. Risk evaluation path
   </thinking_framework>

YOU MUST DO IN-DEPTH RESEARCH, FOLLOW THE <research_process>

<research_process>

- Don't only research one page, and don't use your own webscraping tool - instead scrape many relevant pages from all documentation links mentioned in the initial.md file
- Take my tech as sacred truth, for example if I say a model name then research that model name for LLM usage - don't assume from your own knowledge at any point
- When I say don't just research one page, I mean do incredibly in-depth research, like to the ponit where it's just absolutely ridiculous how much research you've actually done, then when you creat the PRD document you need to put absolutely everything into that including INCREDIBLY IN DEPTH CODE EXMAPLES so any AI can pick up your PRD and generate WORKING and COMPLETE production ready code.

</research_process>

<arguments>
Feature file: $ARGUMENTS
</arguments>

## Step 1: Load Project Context

@prds/templates/base-prd.md

<context_understanding>
I'm now grounded in the project's technical architecture, quality standards, user base, and business context. This foundation will inform every decision in the feature PRD.
</context_understanding>

## Step 2: Research

1. **Codebase Analysis**
   - Search for similar features/patterns in the codebase
   - Identify files to reference in PRP
   - Note existing conventions to follow
   - Check test patterns for validation approach

2. **External Research**
   - Search for similar features/patterns online
   - Library documentation (include specific URLs)
   - Implementation examples (GitHub/StackOverflow/blogs)
   - Best practices and common pitfalls
   - Don't only research one page, and don't use your own webscraping tool - instead scrape many relevant pages from all documentation links mentioned in the initial.md file
   - When I say don't just research one page, I mean do incredibly in-depth research, like to the ponit where it's just absolutely ridiculous how much research you've actually done, then when you creat the PRD document you need to put absolutely everything into that including INCREDIBLY IN DEPTH CODE EXMAPLES so any **Junior Developer** can pick up your PRD and generate WORKING and COMPLETE production ready code.

3. **User Clarification** (if needed)

Based on your codebase analysis, ask 3-5 highly targeted questions that:

- Are specific to the user's context and existing code
- Reference actual files/components found in the codebase
- Explore technical feasibility and integration points
- Consider user experience and edge cases
- Avoid questions already answered by codebase analysis

Example questions:

- "I see you have authentication in `auth/` module. Should this feature require user login?"
- "Your existing API uses REST patterns. Should we follow the same convention or consider GraphQL for this feature?"
- "I notice you have a design system in `components/`. Should we extend existing components or create new ones?"
- Specific patterns to mirror and where to find them?
- Integration requirements and where to find them?

## Step 3: Feature Analysis Using Tree of Thoughts

<thinking>
Let me explore this feature from multiple angles simultaneously:

**User Value Path**:

- What problem does this solve for users?
- How does it fit into existing user workflows?
- What's the expected user adoption and engagement?

**Technical Feasibility Path**:

- What architectural changes are required?
- How does this integrate with existing systems?
- What are the performance and scalability implications?

**Business Impact Path**:

- How does this align with business objectives?
- What's the expected ROI and timeline?
- How does this affect competitive positioning?

**Risk Evaluation Path**:

- What could go wrong technically?
- What are the user experience risks?
- How might this impact system stability?
  </thinking>

## Step 4: Stakeholder Perspective Analysis

<mece_analysis>
Using MECE framework to ensure comprehensive stakeholder coverage:

**End Users**: Primary beneficiaries, power users, casual users
**Development Team**: Frontend, backend, DevOps, QA engineers
**Business Stakeholders**: Product, marketing, support, sales
**External Partners**: API consumers, integration partners, vendors
</mece_analysis>

## Step 5: Chain of Thought Requirements Development

<chain_of_thought>
Let me work through the requirements systematically:

1. **Problem Identification**: What specific pain point are we addressing?
2. **Solution Hypothesis**: What approach will solve this problem?
3. **User Story Derivation**: How do we break this into user-facing value?
4. **Acceptance Criteria**: What measurable outcomes define success?
5. **Technical Requirements**: What system changes enable this solution?
6. **Integration Points**: How does this connect with existing features?
7. **Edge Case Analysis**: What unusual scenarios must we handle?
   </chain_of_thought>

## Step 6: Generate Comprehensive PRD

Create `prds/feature-prd.md`:

```markdown
# PRD: [Feature Name]

## Executive Summary

### Problem Statement

[Clear articulation of the user problem being solved]

### Solution Overview

[High-level approach and core functionality]

### Success Metrics

- Primary KPI: [Measurable business impact]
- User Experience Metrics: [Engagement, satisfaction, adoption]
- Technical Metrics: [Performance, reliability, scalability]

## Requirements Analysis

### User Stories

#### Story 1: [Primary User Flow]

**As a** [user type]
**I want** [capability]
**So that** [business value]

**Acceptance Criteria**:

- **Given** [initial state], **When** [action], **Then** [expected outcome]
- **Given** [error condition], **When** [action], **Then** [error handling]
- **Given** [edge case], **When** [action], **Then** [graceful degradation]

#### Story 2: [Secondary User Flow]

[Continue pattern for 3-5 core user stories]

### Non-Functional Requirements

- Performance: [Response times, throughput requirements]
- Security: [Authentication, authorization, data protection]
- Accessibility: [WCAG compliance, screen reader support]
- Browser/Platform Support: [Compatibility matrix]

## Technical Specifications

### Architecture Impact

[How this feature affects existing system architecture. Include diagrams if needed]

### API Specifications

[New endpoints, data formats, authentication requirements]

### Database Changes

[Schema modifications, migration requirements, indexing strategy]

### Frontend Requirements

[UI/UX specifications, component needs, state management]

### Integration Requirements

[External services, webhooks, batch processes. Include diagrams if needed]

## Implementation Strategy

### Phase 1: Foundation (Week 1-2)

[Core infrastructure and basic functionality]

### Phase 2: Core Features (Week 3-4)

[Primary user flows and main functionality]

### Phase 3: Enhancement (Week 5-6)

[Advanced features, optimizations, polish]

### Dependencies and Blockers

[External dependencies, team dependencies, technical blockers]

## Testing Strategy

### Unit Testing

[Component-level testing requirements]

### Integration Testing

[API and system integration validation]

### User Acceptance Testing

[Criteria for product owner approval]

### Performance Testing

[Load testing, stress testing, benchmark requirements]

## Risk Assessment

### Technical Risks

- [High impact technical challenges]
- [Mitigation strategies for each risk]

### User Experience Risks

- [Potential usability issues]
- [User research and validation plans]

### Business Risks

- [Market timing, competitive concerns]
- [Contingency planning]

## Success Criteria and Measurement

### Definition of Done

[Specific, measurable criteria for feature completion]

### Post-Launch Metrics

[KPIs to track after deployment]

### Rollback Criteria

[Conditions that would trigger feature rollback]
```

**Remember**: Assume the primary reader of the PRD is a **junior developer**. Therefore, requirements should be explicit, unambiguous, and avoid jargon where possible. Provide enough detail for them to understand the feature's purpose and core logic.
**Remember**: Your PRDs should bridge user needs with technical reality, making implementation straightforward for developers.
