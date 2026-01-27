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

jjc() {
    if [ $# -eq 0 ]; then
        jj commit
    else
        jj commit -m "$*"
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

jjw() {
    cmd="$1"
    shift

    case "$cmd" in
    new | add)
        name="$1"
        rev="${2:-@}"
        if [ -z "$name" ]; then
            echo "Usage: jjw new <name> [revision]"
            return 1
        fi

        root=$(jj root) || return 1
        dest="../$(basename "$root")__${name}"

        jj workspace add "$dest" -r "$rev" || return 1

        # Create .git file for IDE compatibility
        echo "gitdir: $root/.git" >"$dest/.git"
        echo "✓ Created .git link for IDE compatibility"

        # Copy env files
        for f in .env .env.local .envrc .tool-versions mise.toml .claude; do
            if [ -e "$root/$f" ]; then
                cp -R "$root/$f" "$dest/" && echo "✓ $f"
            fi
        done

        if [ -f "$dest/.envrc" ] && command -v direnv >/dev/null 2>&1; then
            (cd "$dest" && direnv allow)
        fi

        echo "→ cd $dest"
        ;;
    go | cd)
        name="$1"
        root=$(jj root) || return 1
        dest="../$(basename "$root")__${name}"
        if [ -d "$dest" ]; then
            cd "$dest" || return 1
        else
            echo "Workspace not found: $dest"
        fi
        ;;
    list | ls)
        jj workspace list
        ;;
    *)
        echo "Usage: jjw {new|go|list} ..."
        ;;
    esac
}
