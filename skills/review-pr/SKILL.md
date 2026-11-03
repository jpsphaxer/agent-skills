---
description: Fetch GitHub PR review comments and generate a categorized PR_REVIEW_TODO.md. Pass the PR number as argument.
argument-hint: [pr-number]
allowed-tools: Bash(bash scripts/review-pr.sh *) Write
---

## Raw PR comment data

!`bash scripts/review-pr.sh $ARGUMENTS`

---

## Your task

Using the raw comment data above, generate a `PR_REVIEW_TODO.md` file in the repo root.

### Categorize each comment as one of:

- **`code`** — Real bug, correctness issue, security concern, or missing test. Almost always worth fixing.
- **`docs`** — Documentation, examples, or inline comments that are inaccurate or contradict actual code behavior.
- **`instructions`** — About `.github/instructions/`, `.claude/rules/`, or `.claude/commands/` files. Flag separately — these involve judgment calls about AI assistant guidance vs. enforced rules.
- **`dismissed`** — The PR author already replied indicating they are okay with it or disagree with the suggestion.
- **`low`** — Minor style, cosmetic, or preference-level feedback with no correctness impact.

### Output format for PR_REVIEW_TODO.md

```markdown
# PR #{number} Review Comments

## Already addressed by author
- One line per dismissed comment with a summary of the author's response. ✅

---

## Code & correctness issues
- [ ] `file:line` — Plain-English summary of what was flagged and why it matters.

## Documentation issues
- [ ] `file:line` — Summary of the inaccuracy or misleading content.

## AI instruction files
- [ ] `file:line` — Summary. Note: these involve judgment — engineers should decide whether the example or guidance is worth updating.

## Low priority / cosmetic
- [ ] `file:line` — Summary. Fix if trivial, skip if not.
```

Distill each comment into plain English — do not paste the raw body. Include the file path and line number for traceability.

After writing the file, report: total comments, count per category.
