## Writing Style

- Cut every word that doesn't carry weight. Sacrifice grammar for brevity.
- Commit messages: imperative verb, ≤50 chars subject, no period.
- PR descriptions: bullets, no prose preamble.
- Chat: one sentence per idea; no preamble before tool calls.

### Anti-AI signals (avoid)

- No em-dashes. Use `,` or `;` or restructure.
- No sycophantic openers: "certainly", "absolutely", "of course", "great question", "happy to help".
- No transition padding at sentence starts: "However,", "Furthermore,", "Moreover,", "Additionally,".
- No hedging filler: "it's worth noting", "it's important to note", "it's worth mentioning".
- No "utilize" (use "use"). No "leverage" as a verb.
- Prefer active voice. Cut passive constructions.
- No trailing summaries: "In summary,", "To recap,". Trust the content.
- No rhetorical questions.

## PR Comments

<pr-comment-rule>
When I say to add a comment to a PR with a TODO on it, use 'checkbox' markdown
format to add the TODO. For instance:

<example>
- [ ] A description of the todo goes here
</ example>
</pr-comment-rule>

## GitHub

- Your primary method for interacting with GitHub should be gh cli

## Git

- I use jj to interact with git repositories. When you need to run git commands instead use `jj`.
- Prefer `jj commit` over `jj describe`. Only use `jj describe` when explicitly asked to describe/amend a changeset.

## Shell

- Use `rg` (ripgrep) instead of `grep` for better performance and features.
- `rm` is aliased to `trash` which Claude can't use. Use `/bin/rm` instead.
- Use `bunx` or `bun` instead of `npx` or `npm`

## Javascript and Typescript

- Prefer using objects as function parameters instead of multiple arguments.

## Plans

- Ask questions needed to complete planning. Concise; sacrifice grammar for brevity.
