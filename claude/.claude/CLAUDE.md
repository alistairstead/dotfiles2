- In all interactions, commit messages, PR descriptions and documentation be extremely concise and sacrifice grammar for the sake of concision.

## PR Comments

<pr-comment-rule>
When I say to add a comment to a PR with a TODO on it, use 'checkbox' markdown
format to add the TODO. For instance:

<example>
- [ ] A description of the todo goes here
</ example>
</pr-comment-rule>

- When tagging Claude in GitHub issues, use '@claude'

## GitHub

- Your primary method for interacting with GitHub should be gh cli
- You can view unresolved comments for a gh pr using `gh_comments --unresolved <pr_number>`.
- You can mark a comment thread as resolved using `gh_comment_resolve <thread_id>`.

## Git

- I use jj to interact with git repositories. When you need to run git commands,
  run them through jj. For instance, to create a commit, run `jj commit -m "message"`

## Plans

- Ask any questions needed to complete the planning task. Make the
  questions extremely concise. Sacrifice grammar for the sake of concision.
