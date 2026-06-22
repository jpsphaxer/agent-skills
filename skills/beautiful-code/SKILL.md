---
name: beautiful-code
description: Elevate code quality through Clean Code, SOLID, and KISS principles. Use after /refactor, or whenever the user wants cleaner, more readable code — even if they just say "make this nicer", "this feels messy", "clean this up", or "can we do better here".
disable-model-invocation: true
allowed-tools: Read, Glob, Edit, Bash(git diff *)
---

Code is read far more than it is written. This skill treats code as a craft — something a fellow engineer should be able to read without friction, explanation, or archaeology.

Apply principles from Clean Code, SOLID, and KISS. Adapt to the language in front of you — the principles are universal, the idioms are not.

## Read the work

!`git diff HEAD~1 --name-only`
!`git diff HEAD~1`

Read each file in full. Understand the intent before touching anything.

## The lens: read it like prose

A function should read like a sentence. A file should read like a chapter. Ask:

- Can you understand what this does without reading how it does it?
- Would a new engineer understand this in 60 seconds?
- Does anything require a comment to explain what — not why — it does?

If the answer to any of these is no, that's where to focus.

## Clean Code

**Naming**
- Functions: verb phrases that describe what they do — `calculateTax`, not `calc` or `doThing`
- Variables: reveal intent — `elapsedTimeInDays`, not `d`
- Booleans: readable as assertions — `isExpired`, `hasPermission`, not `flag` or `check`
- No encodings, no noise words — not `userObject`, `dataList`, `managerClass`

**Functions**
- Do one thing. If you have to use "and" to describe it, split it
- Operate at one level of abstraction — don't mix high-level orchestration with low-level detail in the same function
- Arguments: fewer is better. Three or more is a signal to introduce a parameter object
- No side effects that aren't obvious from the name
- Command or query — a function either does something or returns something, rarely both

**Structure**
- The important stuff goes at the top — high-level flow first, details below
- Related concepts live close together
- Stepdown rule: a function should read naturally into the functions it calls

**Comments**
- Remove comments that describe *what* — the code should do that
- Keep comments that explain *why* — intent, tradeoffs, non-obvious constraints
- Delete commented-out code

## SOLID

Read `references/solid.md` when evaluating class or module structure.

## KISS

- The simplest solution that correctly solves the problem is the right solution
- Clever code that requires study to understand is not clever — it is a liability
- If a simpler version exists that reads better and does the same thing, write it

## Ground rules

- **No behavior changes.** If an improvement would change what the code does, note it and skip it.
- **Language-native.** Write idiomatic code for the language at hand. Clean Python doesn't look like Clean Java.
- **Proportional effort.** A 10-line utility script doesn't need the same treatment as a core service. Calibrate.
- **Honest assessment.** If the code is already beautiful, say so. Don't invent changes.

## When done

Give a brief, honest summary — what was improved, what was already good, and any structural suggestions that were out of scope for this pass but worth considering.
