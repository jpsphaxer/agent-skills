# The Double Loop

Outside-In TDD runs two loops simultaneously.

```
┌─────────────────────────────────────────┐
│           OUTER LOOP                    │
│                                         │
│   Write acceptance test (red)           │
│            │                            │
│            ▼                            │
│   ┌─────────────────────┐               │
│   │     INNER LOOP      │               │
│   │                     │               │
│   │  Write unit test    │               │
│   │  (red)              │               │
│   │       │             │               │
│   │       ▼             │               │
│   │  Write min code     │               │
│   │  (green)            │               │
│   │       │             │               │
│   │       ▼             │               │
│   │  Refactor           │               │
│   │       │             │               │
│   │       └─────────────┘               │
│   │  (repeat until acceptance           │
│   │   test advances)                    │
│   └─────────────────────┘               │
│            │                            │
│            ▼                            │
│   Acceptance test green                 │
│   → move to next criterion              │
└─────────────────────────────────────────┘
```

## The outer loop (acceptance)

- Timescale: hours to days
- Written from the user's perspective
- Tests observable behaviour only — inputs and outputs the caller can see
- Stays red until the entire slice of functionality is complete
- Provides regression protection for everything the user cares about

## The inner loop (unit)

- Timescale: minutes
- Written from the developer's perspective
- Tests one unit in isolation using mocks for collaborators
- Each mock defines a contract — that contract is the next unit test
- Red → green → refactor, strictly in that order

## Why outside-in

Starting from the acceptance test means you only build what is needed to serve the outside. You cannot gold-plate or over-engineer what no test requires. Every collaborator is discovered through need, not assumption.

The mock at each boundary is not a shortcut — it is a design decision. When you mock a collaborator, you are deciding its interface. That decision becomes a test.

## The key discipline

When the acceptance test is red, you work the inner loop. When the inner loop is green, you check whether the acceptance test has advanced. If it has not, you identify the next collaborator and start the inner loop again. You never skip ahead.
