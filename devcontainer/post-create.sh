#!/usr/bin/env bash
set -euo pipefail

# Run from $HOME, not the workspace. In a linked git worktree the workspace holds
# a .git file pointing at an absolute path inside the main repository; git aborts
# on a .git that is present but unresolvable (unlike one that is simply absent),
# so even `git config --global` would fail here and take the lifecycle hook with
# it. aidev mounts the common git dir so git works in the workspace regardless.
cd "$HOME"

git config --global core.autocrlf input
git config --global init.defaultBranch main

sudo chown "$(id -u):$(id -g)" \
    "$HOME/.gradle" \
    "$HOME/.pi" \
    "$HOME/.pi/agent"
