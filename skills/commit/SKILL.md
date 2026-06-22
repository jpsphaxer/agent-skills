---
name: commit
description: Stage and commit changes using the 5W1H method. Use when the user says "commit" or "commit my changes". Does not push.
disable-model-invocation: true
allowed-tools: Bash(git *), Bash(gh *)
argument-hint: "[optional scope or message context]"
---

## Gather context

!`gh auth status`
!`gh repo view --json name,defaultBranchRef,url`
!`git status`
!`git diff --staged`
!`git diff`
!`gh api repos/{owner}/{repo}/commits?per_page=5 2>/dev/null || git log --oneline -5`

If not authenticated, stop and ask the user to run `gh auth login`.

If nothing is staged, run `git add -u` to stage tracked changes. For untracked files, review `git status` and stage only files directly related to the current work using `git add <file>`. Never blanket-stage with `git add .`.

## Commit incrementally

Commit early and often as work progresses — not in one large lump at the end. Each commit should represent a single logical step forward: a passing test, a working behaviour, a completed refactor. Small incremental commits make history readable, bugs bisectable, and rollbacks surgical.

If the diff touches more than one concern — a bug fix and a refactor, a feature and a dependency update — stop and split them into separate commits before proceeding. A commit message that needs "and" to describe what changed is a signal to split.

## Answer the 5W1H before writing anything

Write for someone who has never seen this codebase. Answer each in plain language:

- **Who** — which component or layer changed?
- **What** — what was added, removed, fixed, or refactored?
- **Why** — what breaks or stays broken without this change?
- **Where** — which files or areas? (skip if obvious from scope)
- **How** — what approach was used? (skip if obvious)
- **When** — part of a sequence? (skip if standalone)

## Commit message format — follow this exactly

```
type(scope): <imperative what> — <why it matters>

Who:   <component or layer>
What:  <concrete change in one sentence>
Why:   <problem this solves or consequence of not doing it>
Where: <files or subsystems> [omit if obvious]
How:   <approach used> [omit if obvious]
When:  <sequencing note> [omit if standalone]
```

Every commit must have the subject line and Who/What/Why. Where, How, When are omitted only when they add nothing new beyond the subject line.

Subject line: max 72 chars, imperative mood, `type(scope): what — why`.

Types: `feat` `fix` `refactor` `docs` `test` `chore` `style` `perf` `revert`

## Standard to meet

Bad — describes the diff, not the decision:
```
fix(nav): push state in geolocationCodeOutletConnected and extract effectiveState getter
```

Good — explains what was wrong and why this fixes it:
```
fix(nav): sync state label when geolocation outlet connects late — prevent stale UI after dashboard load

Who:   top-nav state label, geolocation outlet
What:  push current state on outlet connect; extract effectiveState getter
Why:   outlet can connect after hub broadcasts on dashboard load, leaving the label showing the old state
How:   matches the connect pattern already used by other outlets; getter centralises state logic
```

## Commit

```bash
git commit -m "<subject>" -m "<body>"
```

Body is always passed as a second `-m` flag — never skip it.

After committing, print the commit hash, subject line, and the GitHub commit URL:

```bash
gh browse --commit $(git rev-parse HEAD) --no-browser
```

## Stop conditions

- Nothing to commit → report status, do nothing
- Merge conflicts present → list files, ask user to resolve first
- Sensitive files staged (`.env`, `*.key`, `*.pem`, `*secret*`) → warn and confirm before committing