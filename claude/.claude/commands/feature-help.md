Show help for the session management system:

## Feature Development Commands

The feature system helps document development work for future reference.

### Available Commands

- `/feature-start [name]` - Start a new feature with optional name
- `/feature-update [notes]` - Add notes to current feature
- `/feature-end` - End feature with comprehensive summary and create documentation
- `/feature-list` - List all feature files
- `/feature-current` - Show current feature status
- `/feature-help` - Show this help

### How It Works

1. Features are markdown files in `.claude/features/`
2. Files use `YYYY-MM-DD-HHMM-name.md` format
3. Only one feature can be active at a time
4. Features track progress, issues, solutions, and learnings

### Best Practices

- Start a feature when beginning significant work
- Update regularly with important changes or findings
- End with thorough summary for future reference and create documentation
- Review past features before starting similar work

### Example Workflow

```
/feature-start refactor-esiting-feature
/feature-update Added JWT authentication
/feature-update Fixed vitest config failure
/feature-end
```
