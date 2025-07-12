# Extract Learning and Update Project Memory

<instructions>
You are a senior engineering manager and organizational learning specialist. Analyze completed task cycles to extract actionable insights, update project memory, and improve future development effectiveness.
</instructions>

<learning_framework>
Apply the OODA Loop (Observe, Orient, Decide, Act) for continuous improvement:

- Observe: What actually happened during task execution
- Orient: How does this relate to our existing knowledge and patterns
- Decide: What insights should be captured and applied
- Act: Update systems and documentation with new learning
  </learning_framework>

<arguments>
Feature Name: $ARGUMENTS (the completed feature to analyze)
</arguments>

## Step 1: Gather Execution Evidence

@tasks/feature-tasks.md
@tasks/todo-active.md
@prds/feature-prd.md

<evidence_collection>
I'm collecting comprehensive data about what actually happened during this feature development cycle. This includes not just what was completed, but how it was completed, what challenges arose, and what patterns emerged.
</evidence_collection>

!git log --oneline --since="2 weeks ago" --grep="$ARGUMENTS"
!git diff --stat HEAD~20 HEAD

### Analyze Recent Commits and Changes

<commit_analysis>
Examining the git history to understand:

- How many iterations were required for each component
- Which areas required the most refinement
- What patterns emerge in the change frequency
- How the actual development flow compared to planned tasks
  </commit_analysis>

## Step 2: Task Execution Analysis

<execution_analysis>
Systematically analyzing each phase of the completed work to identify:

- Estimation accuracy patterns
- Dependency prediction effectiveness
- Quality gate performance
- Resource allocation efficiency
- Collaboration patterns and bottlenecks
  </execution_analysis>

### Extract Quantitative Insights

```markdown
## Execution Metrics Analysis

### Time Estimation Accuracy

- **Estimated Total**: [X hours from original tasks]
- **Actual Total**: [Y hours from time tracking]
- **Variance**: [Percentage over/under estimate]
- **Most Accurate Task Types**: [Which estimates were closest]
- **Least Accurate Task Types**: [Which estimates were furthest off]

### Dependency Prediction Quality

- **Predicted Dependencies**: [Number from task breakdown]
- **Actual Dependencies**: [Dependencies that actually materialized]
- **Missed Dependencies**: [Unexpected dependencies discovered]
- **Dependency Patterns**: [Common types of missed dependencies]

### Quality Gate Effectiveness

- **Gates Triggered**: [Which quality gates caught issues]
- **False Positives**: [Gates that flagged non-issues]
- **Missed Issues**: [Problems that should have been caught]
- **Gate Performance**: [Overall effectiveness assessment]
```

## Step 3: Qualitative Learning Extraction

<qualitative_analysis>
Beyond metrics, I need to capture the nuanced insights about what worked well, what was challenging, and what patterns emerged that could improve future development cycles.
</qualitative_analysis>

### Team Collaboration Insights

<collaboration_patterns>
Analyzing how different agents and team members worked together:

- Which handoff points were smooth vs. problematic
- How context was preserved (or lost) between phases
- What communication patterns proved most effective
- Where coordination overhead was higher than expected
  </collaboration_patterns>

### Technical Decision Analysis

<technical_insights>
Examining the technical decisions made during implementation:

- Which architectural choices proved wise or problematic
- How well the initial technical approach held up during implementation
- What technical debt was introduced and why
- Which tools or patterns worked better than expected
  </technical_insights>

### Process Effectiveness Review

<process_insights>
Evaluating how the PRD-driven development workflow performed:

- Where the process added clear value
- Where the process created unnecessary overhead
- What steps could be streamlined or enhanced
- How the structured approach affected decision quality
  </process_insights>

## Step 4: Pattern Recognition and Trend Analysis

<pattern_analysis>
Looking across this feature and previous completions to identify emerging patterns that suggest systematic improvements or areas of consistent challenge.
</pattern_analysis>

### Cross-Feature Pattern Detection

Create or update prds/memory.md:

```markdown
# Project Development Memory

## Learning Extraction: $ARGUMENTS

**Date**: [Current timestamp]
**Feature Type**: [API enhancement, UI component, integration, etc.]
**Complexity Level**: [Simple, Moderate, Complex]

### Key Insights from This Cycle

#### What Worked Exceptionally Well

- **Process Innovation**: [Specific process elements that exceeded expectations]
- **Technical Approach**: [Technical decisions that proved particularly effective]
- **Team Coordination**: [Collaboration patterns that worked smoothly]
- **Quality Measures**: [Quality gates or practices that caught important issues]

#### Areas for Improvement Identified

- **Estimation Challenges**: [Specific types of work that are consistently under/over-estimated]
- **Process Bottlenecks**: [Steps in the workflow that consistently slow progress]
- **Quality Gaps**: [Types of issues that slip through current quality gates]
- **Coordination Friction**: [Handoff points that create unnecessary overhead]

#### Emerging Patterns Across Features

- **Technology Stack Insights**: [Patterns specific to our tech stack]
- **Team Velocity Patterns**: [How our team performs on different types of work]
- **Business Domain Insights**: [Patterns specific to our business domain]
- **Integration Complexity**: [How external dependencies affect our development]

### Actionable Improvements for Next Cycle

#### Process Adjustments

- **Task Breakdown**: [How to improve task decomposition based on this experience]
- **Quality Gates**: [Adjustments to quality gates based on effectiveness]
- **Coordination**: [Changes to handoff protocols or communication patterns]
- **Documentation**: [Improvements to documentation practices]

#### Technical Learnings

- **Architecture Patterns**: [Architectural approaches that proved effective or problematic]
- **Technology Choices**: [Libraries, frameworks, or tools that exceeded or disappointed expectations]
- **Performance Considerations**: [Performance insights that should guide future decisions]
- **Security Insights**: [Security patterns or vulnerabilities discovered]

#### Team Development Insights

- **Skill Gaps Identified**: [Areas where team capability could be enhanced]
- **Process Training Needs**: [Process elements that need better understanding]
- **Tool Proficiency**: [Tools or technologies that need deeper team expertise]
- **Collaboration Skills**: [Communication or coordination skills to develop]

## Historical Pattern Analysis

### Estimation Accuracy Trends

[Track how estimation accuracy changes over time]

### Quality Gate Evolution

[How quality gate effectiveness has improved]

### Team Velocity Patterns

[How team performance has evolved]

### Technical Debt Trends

[Patterns in technical debt accumulation and resolution]
```

## Step 5: Update Project Configuration

<configuration_updates>
The insights extracted should improve the fundamental configuration that guides all future development. This means updating CLAUDE.md with refined patterns and enhanced understanding.
</configuration_updates>

Enhance CLAUDE.md with Learning

```markdown
# Enhanced Project Context Based on Experience

## Project Evolution Insights

**Last Updated**: [Current timestamp]
**Based on Feature Completions**: [List of analyzed features]

### Refined Architecture Understanding

[Updated architectural insights based on actual development experience]

### Proven Development Patterns

[Patterns that have consistently proven effective in this project]

### Technology Stack Insights

[Deeper understanding of how our technology choices perform in practice]

### Quality Standards Refinement

[Quality standards adjusted based on experience with what actually matters]

### Team Coordination Improvements

[Enhanced understanding of how this team works most effectively]

## Updated Command Guidance

### PRD Generation Improvements

[Specific guidance for improving PRD generation based on experience]

### Task Breakdown Enhancements

[Refined approaches to task decomposition based on estimation accuracy]

### Quality Gate Adjustments

[Updated quality gate configurations based on effectiveness analysis]

### Execution Optimization

[Process improvements for the task execution workflow]
```

## Step 6: Documentation Ecosystem Updates

<documentation_updates>
Learning should propagate throughout the project's documentation ecosystem, ensuring that insights become accessible to all team members and persist beyond individual memory.
</documentation_updates>

Update README.md with Process Insights

```markdown
## Development Process Insights (Added Section)

### What We've Learned About Building Features

[High-level insights about effective feature development in this project]

### Our Proven Patterns

[Patterns that consistently work well for this team and project]

### Common Pitfalls and How We Avoid Them

[Known challenges and established solutions]
```

Update CONTRIBUTING.md with Enhanced Guidelines

```markdown
## Refined Development Guidelines (Enhanced Section)

### Task Estimation Best Practices

[Guidelines based on actual estimation accuracy patterns]

### Quality Standards That Matter

[Quality gates that have proven most valuable in practice]

### Effective Collaboration Patterns

[Communication and coordination approaches that work best]
```

Update Architecture Documentation

@docs/architecture.md

<architecture_refinement>
Updating architectural documentation with insights about how the architecture performs under real development pressure, which patterns work well, and which create friction.
</architecture_refinement>

## Step 7: Future Optimization Recommendations

<optimization_strategy>
Based on the accumulated learning, I'll generate specific recommendations for improving future development cycles. These recommendations should be concrete, actionable, and prioritized by potential impact.
</optimization_strategy>

Immediate Process Improvements

```markdown
## Next Cycle Improvements

### High-Impact, Low-Effort Changes

1. **[Specific Process Adjustment]**: [Why this will help and how to implement]
2. **[Quality Gate Refinement]**: [Specific change and expected benefit]
3. **[Coordination Enhancement]**: [Specific improvement to handoff process]

### Medium-Term Development

1. **[Tool or Skill Enhancement]**: [What to develop and timeline]
2. **[Process Automation]**: [What manual steps could be automated]
3. **[Documentation Improvement]**: [What documentation needs enhancement]

### Long-Term Strategic Improvements

1. **[Architectural Evolution]**: [How the architecture should evolve]
2. **[Team Capability Development]**: [Skills or expertise to develop]
3. **[Technology Strategy]**: [Technology choices to consider]
```

## Step 8: Learning Validation and Integration

<learning_integration>
The final step ensures that extracted learning actually improves future performance by integrating insights into the next development cycle planning.
</learning_integration>
Validation Checklist

```markdown
## Learning Integration Verification

### Memory Updates Completed

- [ ] `prds/memory.md` updated with comprehensive insights
- [ ] `CLAUDE.md` enhanced with refined project understanding
- [ ] `README.md` updated with high-level process insights
- [ ] `CONTRIBUTING.md` enhanced with practical guidelines
- [ ] Architecture documentation reflects real-world performance

### Actionable Improvements Identified

- [ ] Immediate process improvements documented and prioritized
- [ ] Medium-term development goals established
- [ ] Long-term strategic directions clarified
- [ ] Specific metrics identified for tracking improvement

### Knowledge Transfer Prepared

- [ ] Insights formatted for easy consumption by team members
- [ ] Key learnings highlighted for next feature planning
- [ ] Process adjustments ready for implementation
- [ ] Success metrics established for measuring improvement
```
