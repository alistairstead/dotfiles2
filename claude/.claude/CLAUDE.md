- In all interactions, commit messages, PR descriptions and documentation be extremely concise and sacrifice grammar for the sake of concision.

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

- Ask any questions needed to complete the planning task. Make the
  questions extremely concise. Sacrifice grammar for the sake of concision.
