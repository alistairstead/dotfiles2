#!/bin/sh
# Shared functions for both bash and zsh
# This file contains POSIX-compatible function definitions

# Simple git wrapper function
g() {
    if [ $# -eq 0 ]; then
        git status --short
    else
        git "$@"
    fi
}

# Git commit wrapper
gc() {
    if [ $# -eq 0 ]; then
        git commit -v
    else
        git commit -m "$*"
    fi
}

# Copy to clipboard (macOS)
if command -v pbcopy >/dev/null 2>&1; then
    copy() {
        cat "$@" | pbcopy
    }
fi

# Source environment files
envs() {
    set -a
    # shellcheck source=/dev/null
    . "$1"
    set +a
}

# Git worktree helper function.
# Use it like this:
# wt feature-name
wt() {
    # Exit immediately on error
    set -e

    # Get the current Git project directory (must be inside a Git repo)
    project_dir="$(git rev-parse --show-toplevel)"

    # Get the base name of the current project folder
    project_name="$(basename "$project_dir")"

    # Get the desired feature/branch name from the first argument
    feature_name="$1"

    # Fail fast if no feature name was provided
    if [ -z "$feature_name" ]; then
        echo "❌ Usage: wt <feature-name>"
        return 1
    fi

    # Define the parent folder where all worktrees go, beside the main repo
    worktree_parent="$(dirname "$project_dir")/${project_name}-worktrees"

    # Define the full path of the new worktree folder
    worktree_path="$worktree_parent/${feature_name}"

    # Create the parent worktrees folder if it doesn't exist
    mkdir -p "$worktree_parent"

    # Create the worktree and the branch
    git -C "$project_dir" worktree add -b "$feature_name" "$worktree_path"

    # Copy .env if it exists
    if [ -f "$project_dir/.env" ]; then
        cp "$project_dir/.env" "$worktree_path/.env"
        echo "📁 Copied .env into worktree."
    fi

    # Copy .envrc if it exists
    if [ -f "$project_dir/.envrc" ]; then
        cp "$project_dir/.envrc" "$worktree_path/.envrc"
        echo "📁 Copied .envrc into worktree."
    fi

    # Copy .claude directory if it exists
    if [ -d "$project_dir/.claude" ]; then
        cp -R "$project_dir/.claude" "$worktree_path/.claude"
        echo "📁 Copied .claude into worktree."
    fi

    # cd into the new worktree
    # cd "$worktree_path"

    # Open the worktree in Cursor
    cursor "$worktree_path" &

    # Confirm success
    echo "✅ Worktree '$feature_name' created at $worktree_path and checked out."
}

gh_comments() {
    # Get PR review comments from GitHub
    #
    # Fetches code review comments (inline comments on diffs) from a GitHub PR.
    # Auto-detects repo and PR number from current directory/branch if not provided.
    #
    # Usage:
    #   gh_comments [--no-bots] [--unresolved] [owner/repo] [pr_number]
    #
    # Arguments:
    #   --no-bots    Optional flag to exclude bot comments (e.g., Copilot)
    #   --unresolved Optional flag to show only unresolved comments
    #   owner/repo   Optional repository in owner/repo format (auto-detected if omitted)
    #   pr_number    Optional PR number (auto-detected from current branch if omitted)
    #
    # Examples:
    #   # Get all comments including bots (default)
    #   gh_comments
    #
    #   # Get only human comments
    #   gh_comments --no-bots
    #
    #   # Get only unresolved comments
    #   gh_comments --unresolved
    #
    #   # Get unresolved comments from humans only
    #   gh_comments --no-bots --unresolved
    #
    #   # Specify repo and PR
    #   gh_comments kodehort/scratch 189
    #
    #   # Full specification with flags
    #   gh_comments --no-bots --unresolved kodehort/scratch 189

    local no_bots=false
    local unresolved_only=false
    local repo=""
    local pr_number=""

    # Parse flags
    while [[ "$1" == --* ]]; do
        case "$1" in
        --no-bots)
            no_bots=true
            shift
            ;;
        --unresolved)
            unresolved_only=true
            shift
            ;;
        *)
            echo "Unknown flag: $1"
            return 1
            ;;
        esac
    done

    # Smart argument parsing: if first arg is a number, treat as PR number
    if [[ "$1" =~ ^[0-9]+$ ]]; then
        pr_number="$1"
        repo=""
    else
        repo="$1"
        pr_number="$2"
    fi

    # Auto-detect repo if not provided
    if [ -z "$repo" ]; then
        repo=$(gh repo view --json nameWithOwner -q .nameWithOwner 2>/dev/null)
        if [ -z "$repo" ]; then
            echo "Error: Could not detect repository. Please specify <owner/repo>"
            echo "Usage: gh_comments [--no-bots] [--unresolved] [owner/repo] [pr_number]"
            return 1
        fi
        echo "Detected repo: $repo"
    fi

    # Auto-detect PR number if not provided
    if [ -z "$pr_number" ]; then
        pr_number=$(gh pr view --json number -q .number 2>/dev/null)
        if [ -z "$pr_number" ]; then
            echo "Error: Could not detect PR number. Please specify PR number or checkout a branch with an associated PR"
            echo "Usage: gh_comments [--no-bots] [--unresolved] [owner/repo] [pr_number]"
            return 1
        fi
        echo "Detected PR #$pr_number"
    fi

    # Output filter status
    if [ "$no_bots" = true ]; then
        echo "Filtering: humans only (no bots)"
    else
        echo "Filtering: including bots (Copilot, etc.)"
    fi

    if [ "$unresolved_only" = true ]; then
        echo "Filtering: unresolved comments only"
    fi

    # Use GraphQL for --unresolved flag, REST API otherwise
    if [ "$unresolved_only" = true ]; then
        # Split repo into owner/name
        owner="${repo%/*}"
        name="${repo#*/}"

        # Build GraphQL query with pagination support
        graphql_query='query($owner: String!, $name: String!, $pr: Int!, $cursor: String) {
          repository(owner: $owner, name: $name) {
            pullRequest(number: $pr) {
              reviewThreads(first: 100, after: $cursor) {
                pageInfo {
                  hasNextPage
                  endCursor
                }
                nodes {
                  id
                  isResolved
                  comments(first: 1) {
                    nodes {
                      author { login, __typename }
                      body
                      diffHunk
                      line
                      startLine
                    }
                  }
                }
              }
            }
          }
        }'

        # Pagination loop to fetch all review threads
        all_threads_file=$(mktemp)
        response_file=$(mktemp)
        echo "[]" > "$all_threads_file"
        cursor=""
        has_next="true"

        while [ "$has_next" = "true" ]; do
            if [ -z "$cursor" ]; then
                gh api graphql -f query="$graphql_query" -f owner="$owner" -f name="$name" -F pr="$pr_number" > "$response_file"
            else
                gh api graphql -f query="$graphql_query" -f owner="$owner" -f name="$name" -F pr="$pr_number" -f cursor="$cursor" > "$response_file"
            fi

            # Extract threads from response and append
            jq '.data.repository.pullRequest.reviewThreads.nodes' "$response_file" > "${response_file}.threads"
            jq -s 'add' "$all_threads_file" "${response_file}.threads" > "${all_threads_file}.new"
            mv "${all_threads_file}.new" "$all_threads_file"

            # Update pagination state
            has_next=$(jq -r '.data.repository.pullRequest.reviewThreads.pageInfo.hasNextPage' "$response_file")
            cursor=$(jq -r '.data.repository.pullRequest.reviewThreads.pageInfo.endCursor' "$response_file")
        done

        all_threads="$all_threads_file"
        rm -f "$response_file" "${response_file}.threads"

        # Build jq filter for unresolved comments (preserve thread_id)
        jq_filter='map(select(.isResolved == false) | {thread_id: .id, comment: .comments.nodes[0]})'

        if [ "$no_bots" = true ]; then
            jq_filter="$jq_filter | map(select(.comment.author.__typename == null or .comment.author.__typename != \"Bot\"))"
        fi

        jq_filter="$jq_filter | map({ thread_id: .thread_id, user: .comment.author.login, diff_hunk: .comment.diffHunk, line: .comment.line, start_line: .comment.startLine, body: .comment.body })"

        jq "$jq_filter" "$all_threads"
        rm -f "$all_threads"
    else
        # Use REST API for other filters
        jq_filter
        base_conditions=""

        # Build condition chain
        if [ "$no_bots" = true ]; then
            base_conditions='.user.type == "User"'
        fi

        # Build final filter
        if [ -n "$base_conditions" ]; then
            jq_filter="[ .[] | select($base_conditions) | { user: .user.login, diff_hunk, line, start_line, body } ]"
        else
            jq_filter='[ .[] | { user: .user.login, diff_hunk, line, start_line, body } ]'
        fi

        # Execute REST API call
        gh api "repos/$repo/pulls/$pr_number/comments" | jq "$jq_filter"
    fi
}

gh_comment_resolve() {
    # Resolve a PR review thread
    #
    # Usage:
    #   gh_comment_resolve <thread_id>
    #
    # Arguments:
    #   thread_id  The thread ID from gh_comments output (e.g., PRRT_kwDOLsFqtM5kv0rG)
    #
    # Example:
    #   gh_comment_resolve PRRT_kwDOLsFqtM5kv0rG

    local thread_id="$1"

    if [ -z "$thread_id" ]; then
        echo "Usage: gh_comment_resolve <thread_id>"
        return 1
    fi

    gh api graphql -f query='
      mutation($threadId: ID!) {
        resolveReviewThread(input: {threadId: $threadId}) {
          thread { isResolved }
        }
      }
    ' -f threadId="$thread_id" | jq -r '.data.resolveReviewThread.thread.isResolved'
}
