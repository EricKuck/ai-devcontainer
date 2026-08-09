#!/usr/bin/env bash
set -euo pipefail

# Runs on the macOS host, bound to a hotkey. Writes the clipboard image into the
# bridge directory that the container mounts at the same absolute path, then
# replaces the clipboard with that file's path so it can be pasted as text into
# a harness running in the container.

BRIDGE="${CLIPBOARD_BRIDGE_DIR:-$HOME/.clipboard-images}"
KEEP=50

fail() {
    osascript -e "display notification \"$1\" with title \"Clipboard image\"" >/dev/null 2>&1 || true
    echo "$1" >&2
    exit 1
}

mkdir -p "$BRIDGE"
stamp="$(date +%Y%m%d-%H%M%S)-$$"
out="$BRIDGE/$stamp.png"

if command -v pngpaste >/dev/null 2>&1; then
    pngpaste "$out" >/dev/null 2>&1 || rm -f "$out"
else
    osascript \
        -e "set fh to open for access (POSIX file \"$out\") with write permission" \
        -e 'set eof fh to 0' \
        -e 'write (the clipboard as «class PNGf») to fh' \
        -e 'close access fh' >/dev/null 2>&1 || rm -f "$out"
fi

# Nothing rendered as image data, so fall back to a file copied in Finder.
if [ ! -f "$out" ]; then
    src="$(osascript -e 'POSIX path of (the clipboard as «class furl»)' 2>/dev/null || true)"
    ext="$(printf '%s' "${src##*.}" | tr '[:upper:]' '[:lower:]')"
    case "$ext" in
        png | jpg | jpeg | gif | webp) ;;
        *) fail "No image on the clipboard." ;;
    esac
    out="$BRIDGE/$stamp.$ext"
    cp "$src" "$out" || fail "Could not copy $src."
fi

printf '%s' "$out" | pbcopy

ls -t "$BRIDGE" | tail -n "+$((KEEP + 1))" | while IFS= read -r old; do
    rm -f "$BRIDGE/$old"
done
