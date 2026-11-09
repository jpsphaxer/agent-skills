#!/usr/bin/env bash
# Usage: bash fetch-pr-comments.sh [PR_NUMBER | owner/repo#N | PR_URL]
# Prints review threads, review summaries, and discussion comments for a PR in
# a structured format for an AI agent to triage. If no PR number is given, uses
# the PR for the current branch.

set -euo pipefail

if ! command -v gh &>/dev/null; then
  echo "ERROR: gh CLI is not installed. See https://cli.github.com then run: gh auth login" >&2
  exit 1
fi

if ! gh auth status &>/dev/null; then
  echo "ERROR: gh CLI is not authenticated. Run: gh auth login" >&2
  exit 1
fi

# Accepts: <number> | owner/repo#<number> | https://github.com/owner/repo/pull/<number>
ARG="${1:-}"
REPO=""
PR_NUMBER=""
if [[ "$ARG" =~ ^https?://github\.com/([^/]+/[^/]+)/pull/([0-9]+) ]]; then
  REPO="${BASH_REMATCH[1]}"; PR_NUMBER="${BASH_REMATCH[2]}"
elif [[ "$ARG" =~ ^([^/#]+/[^/#]+)#([0-9]+)$ ]]; then
  REPO="${BASH_REMATCH[1]}"; PR_NUMBER="${BASH_REMATCH[2]}"
else
  PR_NUMBER="$ARG"
fi

if [ -z "$REPO" ]; then
  REPO=$(gh repo view --json nameWithOwner -q .nameWithOwner)
fi
if [ -z "$PR_NUMBER" ]; then
  PR_NUMBER=$(gh pr view --repo "$REPO" --json number -q .number 2>/dev/null) || {
    echo "ERROR: no PR given and no PR found for the current branch." >&2
    exit 1
  }
fi

OWNER="${REPO%%/*}"
NAME="${REPO##*/}"

echo "=== PR #${PR_NUMBER} — ${REPO} ==="
gh pr view "$PR_NUMBER" --repo "$REPO" \
  --json title,author,headRefName,state \
  -q '"Title: " + .title + "\nPR author: " + .author.login + "\nBranch: " + .headRefName + "\nState: " + .state'
echo ""

# --- Review summaries (APPROVED / CHANGES_REQUESTED / COMMENTED bodies) ---

echo "=== REVIEW SUMMARIES ==="
gh api "repos/${REPO}/pulls/${PR_NUMBER}/reviews" --paginate \
  --jq '.[] | select((.body // "") != "") |
    "--- Review by \(.user.login) [\(.state)]\n\(.body[0:1500])\n"'

# --- Inline review threads: grouped, with resolved/outdated status ---

echo "=== INLINE REVIEW THREADS ==="
gh api graphql \
  -F owner="$OWNER" -F name="$NAME" -F number="$PR_NUMBER" \
  -f query='
query($owner:String!, $name:String!, $number:Int!) {
  repository(owner:$owner, name:$name) {
    pullRequest(number:$number) {
      reviewThreads(first:100) {
        nodes {
          isResolved
          isOutdated
          path
          line
          originalLine
          comments(first:50) {
            nodes { author { login } body diffHunk }
          }
        }
      }
    }
  }
}' \
  --jq '.data.repository.pullRequest.reviewThreads.nodes[] |
    "--- Thread: \(.path):\(.line // .originalLine) [resolved=\(.isResolved), outdated=\(.isOutdated)]\n" +
    "Diff context:\n\(.comments.nodes[0].diffHunk)\n" +
    ([.comments.nodes[] | "  @\(.author.login // "ghost"): \(.body)"] | join("\n")) + "\n"'

# --- Top-level PR discussion comments ---

echo "=== PR DISCUSSION COMMENTS ==="
gh api "repos/${REPO}/issues/${PR_NUMBER}/comments" --paginate \
  --jq '.[] | "--- @\(.user.login):\n\(.body)\n"'
