#!/usr/bin/env bash
set -euo pipefail

mkdir -p \
    "$HOME/.clipboard-images" \
    "$HOME/.aidev/activity" \
    "$HOME/.pi/agent" \
    "$HOME/.gradle/caches/modules-2"

if [ ! -f "$HOME/.claude/.credentials.json" ]; then
    CRED="$(security find-generic-password -s 'Claude Code-credentials' -w 2>/dev/null || true)"
    if [ -n "$CRED" ]; then
        mkdir -p "$HOME/.claude"
        printf '%s' "$CRED" > "$HOME/.claude/.credentials.json"
        chmod 600 "$HOME/.claude/.credentials.json"
    fi
fi
