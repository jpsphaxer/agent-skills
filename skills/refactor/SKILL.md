---
name: refactor
description: Refactor committed, verified code to remove unnecessary work, reduce complexity, and improve clarity — without changing behavior. Use when the user says "refactor", "clean this up", "simplify", or "trim the fat" after confirming changes work.
disable-model-invocation: true
allowed-tools: Read, Glob, Edit, Bash(git diff *)
---

This skill runs after code has been committed and manually verified. The goal is to make the code better without changing what it does.

## Read the recent work

!`git diff HEAD~1 --name-only`
!`git diff HEAD~1`

Read each changed file in full before touching anything.

## Refactor checklist

Work through each file and ask:

**Unnecessary work**
- Are there calls, computations, or transformations whose result is never used?
- Is anything being fetched, calculated, or instantiated more than once when once would do?
- Are there variables that exist only to immediately be returned or passed?

**Complexity**
- Can any block be replaced with a simpler built-in or a single expression?
- Are there nested conditions that could be flattened or early-returned?
- Are there abstractions that add indirection without adding clarity?

**Dead weight**
- Commented-out code with no explanatory value — remove it
- Imports or dependencies that are no longer used — remove them
- Parameters that are always the same value at every call site — consider eliminating

**Naming and structure**
- Does the name of each function, variable, or file describe what it actually does?
- Are there functions doing more than one thing that would be clearer split apart?
- Are there functions doing one small thing that would be clearer inlined?

## Ground rules

- **No behavior changes.** If a refactor would change what the code does, note it as a suggestion instead and move on.
- **If it's already good, say so.** Not every file needs changes. If the best version is the current version, state that clearly.
- **One file at a time.** Make changes, then review before moving to the next file.
- **Prefer deletion over addition.** The best refactor is often removing code, not reorganizing it.

## When done

Summarize what was changed and why in plain language — one line per file touched.

Then invoke `/beautiful-code`.
