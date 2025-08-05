# Initialize Project PRD Template

<instructions>
You are a senior technical analyst creating the foundational PRD template for this project. This template will serve as the base context for all feature PRDs.
</instructions>

## Step 1: Project Structure Analysis

Analyze the codebase structure to understand architectural patterns:

!find . -type f \( -name "*.json" -o -name "*.yaml" -o -name "*.yml" -o -name "*.toml" -o -name "*.md" \) | head -20
!ls -la
!tree -L 2 -I 'node_modules|.git|dist|build' || find . -maxdepth 2 -type d | head -10

## Step 2: Technology Stack & Quality Standards Detection

![ -f "package.json" ] && echo "=== PACKAGE.JSON ===" && cat package.json
![ -f "Cargo.toml" ] && echo "=== CARGO.TOML ===" && cat Cargo.toml
![ -f "requirements.txt" ] && echo "=== REQUIREMENTS.TXT ===" && cat requirements.txt
![ -f "Gemfile" ] && echo "=== GEMFILE ===" && cat Gemfile

Quality tooling detection:
!for config in .eslintrc* jest.config* vitest.config* .github/workflows* sonar-project.properties; do [ -e "$config" ] && echo "Found: $config"; done

## Step 3: Documentation Gathering

Load existing documentation if available:
![ -f "README.md" ] && echo "=== README FOUND ===" || echo "No README.md found"
![ -f "CONTRIBUTING.md" ] && echo "=== CONTRIBUTING FOUND ===" || echo "No CONTRIBUTING.md found"
![ -d "docs" ] && echo "=== DOCS DIRECTORY ===" && find docs -name "*.md" | head -5 || echo "No docs directory found"

@README.md
@CONTRIBUTING.md

## Step 4: Generate Base PRD Template

Based on the analysis above, populate the base PRD template:

@~/.claude/templates/base-prd.md

**Update the base template with:**

1. **Technology Stack**: Fill in detected languages, frameworks, and dependencies
2. **Architecture Overview**: Document identified patterns and project structure
3. **Current Codebase Structure**: Insert the tree output or directory structure
4. **Quality Standards**: List found testing frameworks, linters, and CI/CD tools
5. **Documentation & References**: Add critical files, URLs, and implementation guides

**Template Population Instructions:**

- Replace `[Detected technologies...]` with actual tech stack from package files
- Replace `[Project tree output]` with the tree command output
- Replace `[Testing frameworks...]` with found quality tools
- Add specific file paths and URLs that feature developers will need
- Include any discovered patterns, conventions, or anti-patterns from the codebase

Create the populated template as `docs/prds/templates/base-prd.md` for use by feature PRD generation.
