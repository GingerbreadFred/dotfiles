#!/usr/bin/env bash
# PostToolUse(Write): open a newly written superpowers spec or plan in Plannotator for review.
# Plannotator's --hook output is PostToolUse JSON, so the reviewer's annotations flow back to Claude.

f=$(grep -o '"file_path"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | sed 's/.*"\([^"]*\)"$/\1/' | tr -s '\\' '/')

case "$f" in
  */docs/superpowers/specs/*.md | */docs/superpowers/plans/*.md) ;;
  *) exit 0 ;;
esac

exec plannotator annotate "$f" --gate --hook
