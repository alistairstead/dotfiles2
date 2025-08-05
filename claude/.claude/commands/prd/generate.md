# Generate Feature PRD

<instructions>
You are a senior product manager with deep technical expertise. Generate a comprehensive PRD for the requested feature, building upon the base project context.
</instructions>

<arguments>
Feature input: $ARGUMENTS
</arguments>

## Step 1: Process Input

<input_handling>
Check the input type:
- If $ARGUMENTS contains "/" or ends with ".md", treat as file path and read the content
- If $ARGUMENTS is text, use directly as feature description
- If $ARGUMENTS is empty, prompt: "Please describe the feature you'd like to create a PRD for:"
</input_handling>

## Step 2: Load Context

@/docs/prds/templates/base-prd.md

<context_understanding>
I'm now grounded in the project's technical architecture, quality standards, user base, and business context. This foundation will inform every decision in the feature PRD.
</context_understanding>

## Step 3: Research & Analysis

### Codebase Analysis
- Search for similar features/patterns in the codebase
- Identify relevant files and existing conventions
- Note test patterns for validation approach

### External Research
- Search for similar implementations online
- Library documentation with specific URLs
- Best practices and common pitfalls
- Implementation examples from GitHub/StackOverflow/blogs

### User Clarification (if needed)
Ask 3-5 targeted questions that:
- Reference actual files/components found in the codebase
- Explore technical feasibility and integration points
- Consider user experience and edge cases
- Avoid questions already answered by codebase analysis

Example questions:
- "I see you have authentication in `auth/` module. Should this feature require user login?"
- "Your existing API uses REST patterns. Should we follow the same convention?"
- "I notice you have a design system in `components/`. Should we extend existing components?"

## Step 4: Multi-Perspective Analysis

Analyze the feature from these angles:

**User Value**: What problem does this solve? How does it fit existing workflows?
**Technical Feasibility**: What architectural changes are required? Integration points?
**Business Impact**: How does this align with objectives? Expected ROI?
**Risk Assessment**: What could go wrong technically and from UX perspective?

## Step 5: Stakeholder Analysis

Consider impact on:
- **End Users**: Primary beneficiaries, power users, casual users
- **Development Team**: Frontend, backend, DevOps, QA engineers
- **Business Stakeholders**: Product, marketing, support, sales
- **External Partners**: API consumers, integration partners

## Step 6: Requirements Development

Work through systematically:
1. **Problem Identification**: What specific pain point are we addressing?
2. **Solution Hypothesis**: What approach will solve this problem?
3. **User Story Derivation**: How do we break this into user-facing value?
4. **Acceptance Criteria**: What measurable outcomes define success?
5. **Technical Requirements**: What system changes enable this solution?
6. **Integration Points**: How does this connect with existing features?
7. **Edge Case Analysis**: What unusual scenarios must we handle?

## Step 7: Generate PRD

Create `docs/prds/feature-prd.md` using the template:

@~/.claude/templates/feature-prd-template.md

**Requirements for PRD Creation**:
- Assume the primary reader is a **junior developer**
- Requirements should be explicit, unambiguous, and avoid jargon
- Provide enough detail for them to understand the feature's purpose and core logic
- Bridge user needs with technical reality to make implementation straightforward
- Include specific code examples and implementation guidance where helpful
- Reference actual files and patterns found during codebase analysis
