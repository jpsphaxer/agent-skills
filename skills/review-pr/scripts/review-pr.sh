#!/usr/bin/env bash
# Usage: bash scripts/review-pr.sh <PR_NUMBER>
# Fetches all review comments for a GitHub PR and prints them in a structured
# format for an AI assistant (Claude Code or Copilot) to categorize.

set -euo pipefail

PR_NUMBER="${1:-}"

if [ -z "$PR_NUMBER" ]; then
  echo "ERROR: PR number required. Usage: bash scripts/review-pr.sh <PR_NUMBER>" >&2
  exit 1
fi

# --- Prerequisites ---

if ! command -v gh &>/dev/null; then
  echo "ERROR: gh CLI is not installed."
  echo "Install it from https://cli.github.com then run: gh auth login"
  exit 1
fi

if ! gh auth status &>/dev/null; then
  echo "ERROR: gh CLI is not authenticated. Run: gh auth login"
  exit 1
fi

REPO=$(gh repo view --json nameWithOwner -q .nameWithOwner)

echo "=== PR #${PR_NUMBER} — ${REPO} ==="
echo ""

# --- PR overview ---

echo "=== OVERVIEW ==="
gh pr view "$PR_NUMBER" --json title,body,author -q '"Title: " + .title + "\nAuthor: " + .author.login'
echo ""

# --- Inline review comments (with file + line context) ---

echo "=== INLINE REVIEW COMMENTS ==="
gh api "repos/${REPO}/pulls/${PR_NUMBER}/comments" --paginate \
  --jq '.[] | {
    id: .id,
    author: .user.login,
    file: .path,
    line: (.line // .original_line),
    body: .body
  } | "--- Comment ID: \(.id)\nAuthor: \(.author)\nFile: \(.file):\(.line)\nBody:\n\(.body)\n"'

# --- Top-level PR discussion comments ---

echo "=== PR DISCUSSION COMMENTS ==="
gh api "repos/${REPO}/issues/${PR_NUMBER}/comments" --paginate \
  --jq '.[] | "--- Comment ID: \(.id)\nAuthor: \(.user.login)\nBody:\n\(.body)\n"'
