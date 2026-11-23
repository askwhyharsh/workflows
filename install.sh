#!/usr/bin/env bash
# Symlink every skill in this repo into ~/.claude/skills.
set -euo pipefail

repo="$(cd "$(dirname "$0")" && pwd)"
dest="${CLAUDE_SKILLS_DIR:-$HOME/.claude/skills}"
mkdir -p "$dest"

for dir in "$repo"/skills/*/; do
  name="$(basename "$dir")"
  target="$dest/$name"
  if [ -L "$target" ] && [ "$(readlink "$target")" = "${dir%/}" ]; then
    echo "ok       $name"
  elif [ -e "$target" ] || [ -L "$target" ]; then
    echo "skipped  $name (exists at $target; move it aside to install)"
  else
    ln -s "${dir%/}" "$target"
    echo "linked   $name"
  fi
done
