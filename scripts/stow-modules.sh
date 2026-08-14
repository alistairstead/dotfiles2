#!/bin/sh
# Single source of truth for which top-level directories are stow packages.
# Sourced by install.sh (to link them) and .github/test/validate.sh (to check
# the links landed), so the list cannot drift from what is on disk.
#
# A package is any top-level directory that contains tracked files and whose
# contents mirror $HOME. Deriving from `git ls-files` rather than a glob keeps
# untracked build output (node_modules, dist) from being stowed into $HOME.
#
# Excluded directories live in the repo but are not packages:
#   .github    CI workflows and test fixtures
#   scripts    repo tooling, run from the checkout
#   karabiner  a TypeScript build (package.json, src/, tsconfig.json) that
#              compiles into ~/.config/karabiner; stowing its root would
#              symlink package.json and src/ straight into $HOME

# Usage: stow_modules [repo_root]
stow_modules() {
  git -C "${1:-.}" ls-files |
    sed -n 's|^\([^/][^/]*\)/.*|\1|p' |
    sort -u |
    grep -vxE '\.github|scripts|karabiner'
}
