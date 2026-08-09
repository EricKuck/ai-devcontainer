#!/usr/bin/env bash
set -euo pipefail

git config --global core.autocrlf input
git config --global init.defaultBranch main

sudo chown "$(id -u):$(id -g)" \
    "$HOME/.gradle" \
    "$HOME/.pi" \
    "$HOME/.pi/agent"
