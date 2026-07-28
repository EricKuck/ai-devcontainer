#!/usr/bin/env bash
set -euo pipefail

git config --global core.autocrlf input
git config --global init.defaultBranch main

sudo chown "$(id -u):$(id -g)" \
    "$HOME/.local" \
    "$HOME/.local/share" \
    "$HOME/.local/share/opencode"
