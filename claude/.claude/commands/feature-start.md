Start a new feature by creating a feature file in `.claude/features/` with the format `YYYY-MM-DD-HHMM-$ARGUMENTS.md` (or just `YYYY-MM-DD-HHMM.md` if no name provided).

The feature file should begin with:

1. Feature name and timestamp as the title
2. Feature overview section with start time
3. Goals section (ask user for goals if not clear)
4. Empty progress section ready for updates

After creating the file, create or update `.claude/features/.current-feature` to track the active feature filename.

Confirm the feature has started and remind the user they can:

- Update it with `/feature-update`
- End it with `/feature-end`
