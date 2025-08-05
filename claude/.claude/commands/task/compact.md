# Extract Learning and Update Project Memory

<instructions>
You are an organizational learning specialist extracting actionable insights from completed development cycles. Focus on identifying patterns that improve future task generation, tool usage, and development effectiveness.
</instructions>

<arguments>
Feature name or task file path: $ARGUMENTS
</arguments>

## Step 1: Load Execution Evidence

<input_handling>
- If $ARGUMENTS contains "/" or ends with ".md", treat as task file path
- If $ARGUMENTS is a feature name, look for `docs/tasks/$ARGUMENTS-tasks.md`
- If no task file found, load recent git history and analyze patterns
</input_handling>

@$ARGUMENTS

**Analyze development artifacts:**
!git log --oneline --since="1 week ago" | head -10
!git diff --stat HEAD~10 HEAD 2>/dev/null || echo "Limited git history available"

## Step 2: Extract Key Learning Patterns

**Identify improvement opportunities:**

1. **Task Completion Analysis**:
   - Which tasks took longer than expected and why?
   - What dependencies were missed in initial planning?
   - Which agent assignments worked well vs. poorly?

2. **Tool Usage Effectiveness**:
   - Which tool calls consistently failed or needed retries?
   - What file patterns or commands caused issues?
   - Which workflows were smooth vs. problematic?

3. **Process Bottlenecks**:
   - Where did handoffs between tasks break down?
   - What quality gates caught real issues vs. false positives?
   - Which parts of the development flow need improvement?

## Step 3: Update Project Memory and Documentation

**Create or update project learning files:**

Create `docs/learning/[feature-name]-insights.md` using template:

@~/.claude/templates/learning-extraction-template.md

**Key areas to document:**

1. **Prompt Engineering Improvements**:
   - Which Claude commands need better guidance?
   - What tool call patterns consistently fail?
   - Which input handling needs refinement?

2. **Process Optimizations**:
   - Task breakdown patterns that work well
   - Quality gates that provide real value
   - Agent coordination improvements needed

3. **Technical Learnings**:
   - Architecture decisions that proved effective/problematic
   - Technology choices that exceeded/disappointed expectations
   - Performance patterns discovered

**Update CLAUDE.md with refined context:**
- Add discovered patterns to avoid repeating mistakes
- Include successful tool usage patterns
- Document effective agent coordination approaches

**Pattern Recognition Framework:**

1. **Recurring Issues**: Identify problems that appear across multiple features
2. **Successful Patterns**: Document approaches that consistently work well  
3. **Tool Effectiveness**: Track which tools and workflows are most reliable
4. **Prompt Improvements**: Note where Claude commands need better guidance

**Actionable Outputs:**

Generate specific recommendations for:
- Task breakdown improvements
- Quality gate refinements  
- Tool usage optimizations
- Agent coordination enhancements
- CLAUDE.md context updates

**Summary and Next Steps:**

1. **Document key insights** in `docs/learning/[feature-name]-insights.md`
2. **Update CLAUDE.md** with discovered patterns and anti-patterns
3. **Identify immediate improvements** for task generation and tool usage
4. **Note recurring tool call failures** that need prompt engineering fixes
5. **Update agent coordination guidance** based on execution experience

**Focus on actionable improvements that directly enhance:**
- Task breakdown accuracy
- Tool call reliability 
- Agent handoff effectiveness
- Quality gate precision
- Development velocity

This learning extraction should result in measurably better performance on the next development cycle.
