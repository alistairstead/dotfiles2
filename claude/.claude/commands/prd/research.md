# Research PRD Enhancement

<instructions>
You are a senior research analyst enhancing an existing PRD with comprehensive documentation, code examples, and implementation guidance. Use all available MCP tools to conduct exhaustive research.
</instructions>

<arguments>
PRD file path: $ARGUMENTS
</arguments>

## Step 1: Load and Analyze PRD

<input_validation>
- If $ARGUMENTS is empty, prompt: "Please provide the path to the PRD file you want to enhance with research"
- If file doesn't exist, show error and ask for correct path
- Load the PRD file and parse its contents
</input_validation>

@$ARGUMENTS

## Step 2: Extract Research Targets

Analyze the PRD to identify:

**Technologies & Frameworks**:
- Programming languages mentioned
- Frameworks and libraries referenced
- APIs and external services
- Database technologies
- Frontend/backend technologies

**Implementation Requirements**:
- Specific features to implement
- Integration patterns needed
- Security requirements
- Performance requirements
- Testing approaches

**Knowledge Gaps**:
- Vague technical specifications
- Missing implementation details
- Undefined integration approaches
- Unclear architectural decisions

## Step 3: Comprehensive Research Process

<research_methodology>
For each identified technology and requirement, conduct multi-source research:

1. **Official Documentation** (Context7)
2. **Implementation Examples** (Ref search)
3. **Best Practices & Patterns** (Web search)
4. **Common Pitfalls & Solutions** (Community resources)
5. **Code Examples & Tutorials** (GitHub, documentation sites)
</research_methodology>

### Technology Research

For each technology stack component:

1. **Resolve library documentation** using Context7:
   - Get latest version documentation
   - Focus on implementation patterns relevant to PRD
   - Extract code examples and API references

2. **Search implementation examples** using Ref:
   - Look for production code examples
   - Find integration patterns
   - Identify common configurations

3. **Web research for best practices**:
   - Search for current best practices (2024/2025)
   - Find performance optimization guides
   - Locate security implementation guides

### Feature-Specific Research

For each feature requirement:

1. **Search similar implementations**:
   - GitHub repositories with similar features
   - Documentation for comparable functionality
   - Stack Overflow solutions and patterns

2. **Integration research**:
   - API documentation for external services
   - SDK documentation and examples
   - Authentication and authorization patterns

3. **Testing and quality research**:
   - Testing frameworks and patterns
   - Quality assurance approaches
   - Monitoring and observability patterns

## Step 4: Code Example Collection

**Requirements for Code Examples**:
- Must be production-ready, complete implementations
- Include error handling and edge cases
- Follow current best practices (2024/2025)
- Include proper typing (if applicable)
- Show integration patterns
- Include test examples where relevant

**Example Categories to Research**:
- Basic implementation patterns
- Configuration and setup code
- Integration code with external services
- Error handling implementations
- Testing code examples
- Performance optimization examples

## Step 5: Documentation Enhancement

**Update the PRD with**:

### Technical Specifications Section
Add comprehensive implementation guidance:

```markdown
## Enhanced Technical Specifications

### Implementation Examples

#### [Feature Name] Implementation

**Technology Stack**: [Specific versions and libraries]

**Core Implementation**:
```[language]
[Complete, production-ready code example]
```

**Configuration**:
```[format]
[Complete configuration example]
```

**Integration Pattern**:
```[language]
[Integration code with error handling]
```

**Testing Approach**:
```[language]
[Complete test examples]
```

### Documentation References

**Critical Resources**:
- [Library Name] Official Docs: [URL] - [Specific sections needed]
- Implementation Guide: [URL] - [Key insights]
- Best Practices: [URL] - [Critical patterns to follow]
- Common Pitfalls: [URL] - [What to avoid and why]

**Code Repositories**:
- Production Example: [GitHub URL] - [Specific files to reference]
- Implementation Pattern: [URL] - [Pattern to follow]

### Architecture Decisions

**Recommended Approach**: [Based on research findings]
**Alternative Approaches**: [Other viable options with trade-offs]
**Integration Points**: [Detailed integration specifications]
**Security Considerations**: [Specific security implementations]
**Performance Optimizations**: [Concrete optimization strategies]
```

### Implementation Checklist Section
Add research-backed validation criteria:

```markdown
## Research-Enhanced Implementation Checklist

### Code Quality Validation
- [ ] Follows [specific style guide] patterns found in [documentation URL]
- [ ] Implements error handling as shown in [example URL]
- [ ] Uses [specific library] version [X.X.X] with [configuration pattern]
- [ ] Includes [specific test types] as demonstrated in [testing guide URL]

### Integration Validation
- [ ] API integration follows [service name] patterns from [documentation URL]
- [ ] Authentication implements [specific method] as shown in [example URL]
- [ ] Data validation uses [specific approach] from [best practices URL]

### Performance Validation
- [ ] Implements [specific optimization] from [performance guide URL]
- [ ] Uses [caching strategy] as recommended in [documentation URL]
- [ ] Follows [monitoring approach] from [observability guide URL]
```

## Research Execution Instructions

**Research Depth Requirements**:
- Minimum 5 documentation sources per major technology
- Minimum 3 code example repositories per feature
- Current documentation (prefer 2024/2025 sources)
- Multiple implementation approaches with trade-off analysis

**MCP Tool Usage Priority**:
1. Context7 for official library documentation
2. Ref for implementation examples and patterns
3. Web search for best practices and recent developments
4. Multiple sources for cross-validation

**Quality Standards**:
- All code examples must be complete and runnable
- Include proper error handling and edge cases
- Provide both basic and advanced implementation options
- Cross-reference multiple sources to validate approaches
- Include performance and security considerations

**Final Deliverable**:
Enhanced PRD with exhaustive technical specifications, complete code examples, comprehensive documentation links, and research-backed implementation guidance that enables any developer to build production-ready features.
