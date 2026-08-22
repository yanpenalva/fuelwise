# Workflow

Every feature, bugfix, or task follows this process. Do not create new steps nor skip steps unless explicitly requested by the user.

## Steps

### 1. Specify

- Identify the related task in `docs/tasks/<phase>/<TASK-ID>.md` when one exists.
- Create `.ai/tasks/<slug>/spec.md` with: objective, scope, non-goals, affected files, acceptance criteria, and test plan.
- If no existing task matches and the work is trivial (typo, doc fix), the spec may be a short note instead of a full document.

### 2. Plan

- Read the spec.
- Read only the docs relevant to the scope (`docs/planning/`, `docs/architecture/`, ADRs, task doc).
- Break down implementation into small, reversible steps.

### 3. Implement

- Follow `AGENTS.md` quality criteria.
- Make small, localized changes.
- Keep `.ai/tasks/<slug>/progress.md` updated with what was done, decisions, and deviations from the spec.

### 4. Validate

- Run affected tests (`flutter test`) through Docker when available.
- Run `flutter analyze`.
- For persistence changes, run Drift/preferences tests.
- For device-affecting flows, validate via host ADB on a physical device when available.
- Run `code-review-graph update` so the knowledge graph reflects the changes.
- Record commands and results in `progress.md`.

### 5. Review

- Compare original request, spec, progress log, actual diff, and the acceptance criteria of the related task in `docs/tasks/`.
- The review agent must not change code automatically. Findings go back to step 3.

### 6. Wrap up

- Update impacted documentation (`docs/tasks/`, `docs/architecture/`, ADRs) — never untouched documents.
- Promote any state needed for continuity into the spec under `Versioned Handoff`.
- Remove `progress.md`.

## Versioned Handoff

Before switching machines, ending an unfinished session, or handing off to another agent, add to the spec:

- current step and completed steps;
- open decisions;
- next concrete actions;
- commands already run and their results.

## Rules

- Never implement outside an approved spec.
- The spec is versioned and committed; `progress.md` is local and temporary.
