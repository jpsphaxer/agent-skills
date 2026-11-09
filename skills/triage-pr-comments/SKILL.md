---
name: triage-pr-comments
description: Triage review comments left on your own pull request. Use when asked to address, go through, summarize, or triage PR feedback, "what did reviewers say", or "handle the review comments". Fetches threads from GitHub, checks each against the code, and writes PR_#####_TODO.md. For reviewing someone else's PR, use grill-pr instead.
argument-hint: [pr-number-or-url]
allowed-tools: Bash(bash *fetch-pr-comments.sh*), Bash(git *), Read, Grep, Write
---

# Triage PR Comments

You are the PR **author** working through feedback. Turn raw review comments into a short, honest TODO list. For reviewing someone else's PR, use `grill-pr`.

## Step 1 — Fetch

Run `scripts/fetch-pr-comments.sh` from this skill's directory, passing `$ARGUMENTS`: a PR number, `owner/repo#123`, or a GitHub URL. With no argument it uses the PR for the current branch. A bare number uses the repo you're in; a URL or `owner/repo#123` works from anywhere, but then read files via `gh api` or a local checkout of that repo.

Output has three sections: review summaries, inline threads (with resolved/outdated flags and diff context), and discussion comments.

## Step 2 — Verify against the code

For each thread, read the referenced file at the current HEAD before deciding anything. Reviewers can be wrong, and the code may have changed since the comment. Do not just paraphrase.

## Step 3 — Classify

Assign every thread one **status** first:

- **Done** — resolved, or outdated and the current code already addresses it.
- **Replied** — the PR author already answered declining or disagreeing, and the reviewer didn't push back.
- **Open** — still needs action.

For **Open** items, pick a **type** and a verdict:

- `code` — bug, correctness, security, missing test.
- `docs` — docs, examples, or comments that contradict the code.
- `question` — reviewer is asking something; needs an answer, not a change.
- `nit` — style or preference with no correctness impact.

Verdict for each Open item: **Fix**, **Disagree** (the code is already right; say why, citing the line), or **Decide** (a judgment call for the author — say what the tradeoff is).

Ignore bot noise (CI summaries, coverage comments) unless it flags a real failure.

## Step 4 — Write

Write `PR_#####_TODO.md` (PR number zero-padded to 5 digits) in the current directory. Do not commit it.

```markdown
# PR #<number> — <title>: Review TODO

## Open
### Code & correctness
- [ ] `file:line` — **Fix** — What was flagged and why it matters. (@reviewer)

### Questions
- [ ] `file:line` — Question to answer.

### Docs
- [ ] ...

### Nits
- [ ] ...

## Needs your decision
- `file:line` — The tradeoff and a recommendation.

## Disagree (code is already right)
- `file:line` — Why, with the line that proves it.

## Already handled
- `file:line` — One line: resolved / fixed in current code / author replied. ✅
```

Only include sections that have content. Distill each comment into plain English with file and line for traceability; never paste raw bodies.

Finish by reporting total threads and counts per status and type. Don't start fixing anything unless asked.
