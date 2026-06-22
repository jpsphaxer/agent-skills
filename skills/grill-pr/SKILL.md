---
name: grill-pr
description: Review a GitHub pull request. Use when asked to review, grill, critique, or audit a PR. Accepts a PR number, owner/repo#number, or GitHub URL. Writes PR_#####_REVIEW.md in the current directory with prioritized, copy-paste-ready findings.
argument-hint: <pr-number-or-url>
allowed-tools: Bash(gh *), Write
---

# Grill PR

Fetch the PR once, read the diff, write a useful review. Do not turn this into a repo archaeology project.

## Step 1 — Fetch

Parse `$ARGUMENTS` for the repo and PR number:

- Bare number (`5869`) → use current repo via `gh repo view --json nameWithOwner`
- `owner/repo#123` → split on `#`
- GitHub URL (`https://github.com/owner/repo/pull/123`) → extract from path

Then run in parallel:

```bash
gh pr view <number> --repo <owner/repo> \
  --json title,body,author,baseRefName,headRefName,state,additions,deletions,changedFiles,labels

gh pr diff <number> --repo <owner/repo>
```

## Step 2 — Review

Read the full diff. Prioritize correctness first, then maintainability.

**Priority levels:**

- `P1` — Fix before merge: likely bug, regression, incorrect behavior, or a test that signals the wrong interface.
- `P2` — Worth discussing: meaningful maintainability, API design, or abstraction issue. May be a follow-up.
- `P3` — Polish only: small nit, only worth raising if trivial to fix.

Skip anything that is pure preference, style-only, or wouldn't matter to a reader six months from now. If you cannot explain why it matters, don't include it.

**For each finding, ask:**

1. Is there actual impact — a bug, a hidden coupling, a test that can never fail, a responsibility in the wrong place?
2. Can I ground the recommendation in something already present in the diff or the surrounding code? If the fix is obvious because the author did the right thing elsewhere, point to it.
3. Is this already handled by the language, the framework, or the test suite? If so, skip it.

## Step 3 — Write

Write `PR_#####_REVIEW.md` (zero-padded to 5 digits) in the current directory.

### Review voice

Write each finding as a comment addressed directly to the PR author — as if you are the reviewer leaving it on GitHub. Second person, conversational, ready to copy-paste.

- Explain the *why*: the tradeoff, the hidden cost, or the implication. Don't just name the problem.
- Ground every recommendation in the code. Quote the actual method, line, or pattern from the diff.
- When the fix is obvious because the code already does the right thing somewhere else, say so explicitly: "The controller's `index` action already does this — `visit_type` belongs there too."
- Do not sound like a linter or a style guide. If you sound pedantic, rewrite it.

### Output structure

```markdown
# PR ###### Review — <title>

**Author:** @<login>
**Stats:** +X / -Y, N files

---

## Overview

Two to four sentences on what the PR does and your overall read on it.

---

## P1 — Fix Before Merge

### 1. <Short title>

<The comment body — written directly to the PR author. Prose first, code block only when it makes the point concrete.>

---

## P2 — Worth Discussing

...

---

## P3 — Nits

...

---

## What's Good

Bullet list of specific things the author got right. Be concrete — name the method, the pattern, or the decision.
```

Only include sections that have content. A PR with no P1 findings skips that section entirely.
