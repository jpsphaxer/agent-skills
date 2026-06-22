---
name: outside-in-tdd
description: Outside-In TDD is the default way we write code. Load this skill whenever a feature, story, task, endpoint, component, or bug fix is being planned or implemented — even if the user hasn't mentioned TDD. Acceptance test first, always. If code is being written or designed, this skill applies.
allowed-tools: Read, Glob, Edit, Bash
---

Outside-In TDD uses a double loop. The outer loop is an acceptance test that defines done from the user's perspective. It stays red until the entire feature works. The inner loop is the unit TDD cycle — red, green, refactor — that drives each collaborator into existence one at a time. Implementation only happens in response to a failing test.

Read `references/double-loop.md` for the full mental model before starting.

---

## Phase 1 — Planning (before any code)

Use this phase when a feature or story is being discussed or designed.

**Understand the requirement**
- What does the user/stakeholder want to be able to do?
- What is the observable outcome that proves it works?
- What are the edge cases and failure paths?

**Write acceptance criteria in Given/When/Then form**

```
Given <precondition>
When  <action>
Then  <observable outcome>
```

Write one scenario per acceptance criterion. These become your acceptance tests — one-to-one.

**Identify the outermost entry point**
- Where does the system get called from? (HTTP endpoint, CLI command, UI event, public API method)
- This is where your acceptance test will invoke the system.

**Sketch the component boundary map**
- What top-level collaborators does the entry point need?
- Don't go deeper than one level — the unit tests will discover the rest.

Output of this phase: a list of acceptance criteria in Given/When/Then form and a rough component boundary sketch. No code yet.

---

## Phase 2 — Execution (writing code)

**Outer loop: write the acceptance test first**

Translate each Given/When/Then into a failing acceptance test. This test:
- Invokes the system from the outside (no internal knowledge)
- Asserts only observable outcomes (response, output, state visible to the caller)
- Uses real collaborators where practical; stubs at system boundaries (DB, external APIs, time)
- Must fail for the right reason before any implementation begins

Run it. Confirm it is red. Do not proceed until you understand why it fails.

**Inner loop: TDD each collaborator**

Starting from the entry point, work inward one layer at a time:

1. Write a failing unit test for the next piece of behaviour needed
2. Write the minimum code to make it pass — nothing more
3. Refactor: clean the code without breaking tests
4. Repeat until the acceptance test advances

Use mocks and stubs to isolate the unit under test from its collaborators. Each mock represents a contract — that contract becomes the next unit test target.

**The loop continues until the acceptance test goes green.**

Never skip ahead to implementation. Never write code without a failing test. Never write more code than the failing test requires.

---

## Test naming

Tests are specifications, not method names. Name them as sentences that describe behaviour:

```
it("returns 401 when the token is expired")
it("sends a confirmation email after successful checkout")
it("rejects a withdrawal that exceeds the account balance")
```

Read existing tests in the project to match the stack, framework, and naming conventions already in use. Do not introduce new testing dependencies without flagging it.

---

## Ground rules

- Acceptance test before any implementation, every time
- A passing test is not the goal — the right behaviour, proven by a test, is the goal
- Mocks verify collaboration; they are not a shortcut around thinking
- If a unit is hard to test, the design is the problem — fix the design
- Tests are first-class code: they get the same naming, structure, and refactoring discipline as production code