# .ai — Agent Working Files

This directory contains agent-facing working files that complement the project documentation in `docs/`. It does not duplicate `docs/`; it defines how agents work and what the stack requires.

## Files

- [`stack.md`](stack.md) — required tools, versions, and installation requirements.
- [`workflow.md`](workflow.md) — mandatory task workflow (Specify → Plan → Implement → Validate → Review → Wrap up).
- [`conventions.md`](conventions.md) — code standards: layout, typing, control flow, validation, numbers, Riverpod, Drift, testing, and OWASP-based security rules.
- `tasks/<slug>/spec.md` — versioned task spec created at the `Specify` step.
- `tasks/<slug>/progress.md` — local, temporary progress log; removed at `Wrap up`.

## Not here on purpose

Architecture, planning, ADRs, testing strategy, and task definitions live in `../docs/` and remain the single source of truth for project knowledge.

All files in this directory are written in en-US.
