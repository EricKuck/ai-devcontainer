#!/usr/bin/env bash
set -euo pipefail

mkdir -p \
    "$HOME/.pi/agent" \
    "$HOME/.config/opencode" \
    "$HOME/.devcontainer" \
    "$HOME/.local/share/opencode"

: > "$HOME/.devcontainer/empty-gradle.properties"

if [ ! -f "$HOME/.local/share/opencode/auth.json" ]; then
    printf '{}' > "$HOME/.local/share/opencode/auth.json"
fi

if [ ! -f "$HOME/.claude/.credentials.json" ]; then
    CRED="$(security find-generic-password -s 'Claude Code-credentials' -w 2>/dev/null || true)"
    if [ -n "$CRED" ]; then
        mkdir -p "$HOME/.claude"
        printf '%s' "$CRED" > "$HOME/.claude/.credentials.json"
        chmod 600 "$HOME/.claude/.credentials.json"
    fi
fi
