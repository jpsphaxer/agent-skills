#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
SKILLS_SRC="$REPO_DIR/skills"
GLOBAL_SRC="$REPO_DIR/global"

SKILL_TARGETS=(
  "$HOME/.claude/skills"
  "$HOME/.codex/skills"
)

usage() {
  echo "Usage: $0 [install|collect]"
  echo ""
  echo "  install  — copy repo → machine (default)"
  echo "  collect  — copy machine → repo (to capture edits made in agent dirs)"
  exit 1
}

cmd="${1:-install}"

case "$cmd" in
  install)
    echo "Pulling latest from remote..."
    git -C "$REPO_DIR" pull

    for target in "${SKILL_TARGETS[@]}"; do
      echo "Syncing skills → $target"
      mkdir -p "$target"
      rsync -a --delete "$SKILLS_SRC/" "$target/"
    done

    if [ -f "$GLOBAL_SRC/CLAUDE.md" ]; then
      echo "Installing global/CLAUDE.md → ~/.claude/CLAUDE.md"
      cp "$GLOBAL_SRC/CLAUDE.md" "$HOME/.claude/CLAUDE.md"
    fi

    if [ -f "$GLOBAL_SRC/AGENTS.md" ]; then
      echo "Installing global/AGENTS.md → ~/.codex/AGENTS.md"
      cp "$GLOBAL_SRC/AGENTS.md" "$HOME/.codex/AGENTS.md"
    fi

    echo ""
    echo "Done. Skills installed to Claude and Codex."
    ;;

  collect)
    echo "Collecting skills from ${SKILL_TARGETS[0]}..."
    rsync -a --delete "${SKILL_TARGETS[0]}/" "$SKILLS_SRC/"

    if [ -f "$HOME/.claude/CLAUDE.md" ]; then
      echo "Collecting ~/.claude/CLAUDE.md → global/CLAUDE.md"
      cp "$HOME/.claude/CLAUDE.md" "$GLOBAL_SRC/CLAUDE.md"
    fi

    if [ -f "$HOME/.codex/AGENTS.md" ]; then
      echo "Collecting ~/.codex/AGENTS.md → global/AGENTS.md"
      cp "$HOME/.codex/AGENTS.md" "$GLOBAL_SRC/AGENTS.md"
    fi

    echo ""
    echo "Done. Review changes with: git -C \"$REPO_DIR\" diff"
    echo "Then commit: git -C \"$REPO_DIR\" add -A && git -C \"$REPO_DIR\" commit -m 'chore: collect skill updates'"
    ;;

  *)
    usage
    ;;
esac
