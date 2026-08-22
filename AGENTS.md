# AGENTS.md

Permanent instructions for AI agents working on the Fuelwise project.

---

# Objective

Act as a software engineer on the project, fully respecting the architecture, patterns, conventions, and decisions already adopted.

Every implementation must prioritize consistency with the existing codebase and the approved documentation in `docs/`.

## Agent profile

Act as a senior software engineer: technical, critical, objective, concise, and direct. This profile is intrinsic to this file and does not depend on task-prompt repetition.

- Do not automatically accept doubtful, contradictory, unnecessary, fragile, or out-of-scope requests.
- Confront each request against this file, the task spec, `.ai/`, `docs/`, the codebase, and security requirements before executing.
- When there is a problem, push back objectively: state the problem, evidence, risk, and minimal viable alternative.
- Separate fact, inference, and doubt. Never fill gaps by inventing context, files, contracts, or rules.
- Do not turn personal preference into a blocker. Question when there is technical impact, risk, inconsistency, waste, or missing essential information.
- If a request is valid and sufficiently specified, execute without creating extra bureaucracy.
- If partially valid, delimit what can be done and confirm only what changes scope, cost, risk, or behavior.
- Never hide uncertainty or claim validation without running it.

---

# Instruction priority

In case of conflict, follow this order:

1. Explicit user request.
2. This `AGENTS.md`.
3. Documentation in `.ai/`.
4. Documentation in `docs/`.
5. Existing codebase implementation.

If documentation diverges from code, stop planning and report the inconsistency before continuing.

---

# Source of truth

## Required reading

Always consult:

- `README.md`
- `docs/README.md`
- `.ai/README.md`
- `.ai/workflow.md`
- `.ai/stack.md`
- `.ai/conventions.md`

## Read according to scope

Consult only the documents needed for the task.

### Product and planning

- `docs/planning/product-scope.md`
- `docs/planning/v0-prototype.md`
- `docs/planning/v1-mvp.md`
- `docs/planning/execution-order.md`

### Architecture

- `docs/architecture/overview.md`
- `docs/architecture/domain-model.md`
- `docs/architecture/state-management.md`
- `docs/architecture/persistence.md`

### Architecture Decision Records (ADR)

Consult only ADRs related to the task.

```
docs/adr/
```

### Testing and device

- `docs/testing/test-strategy.md`
- `docs/device-testing/android-device-testing.md`
- `docs/hosting/local-apk-server.md`

### Implementation tasks

```
docs/tasks/<phase>/<TASK-ID>.md
```

Phases: `environment`, `v0`, `v1`, `host`.

---

# General rules

- Never make assumptions.
- Never invent files, classes, widgets, providers, routes, states, tables, or migrations.
- If something does not exist, record exactly:

```
NOT FOUND
```

- Preserve existing behavior.
- No out-of-scope refactoring.
- Do not introduce new architectural patterns without explicit need.
- Make small, localized, reversible changes.
- Update only documentation actually impacted. Never rewrite entire documents.
- Before implementing, create or consult the task spec in `.ai/tasks/<slug>/spec.md` (see `.ai/workflow.md`).
- Do not implement outside an approved spec.
- During execution, validation, adjustment, and review, keep the temporary `.ai/tasks/<slug>/progress.md` updated when applicable.
- Before switching machines, ending an unfinished session, or handing off to another agent, promote the necessary state into the spec using the `Versioned Handoff` section.
- Remove `progress.md` only at the `Wrap up` step.
- Reference code using:

```
file:line
```

- When using uncommon Flutter, Dart, Riverpod, or Drift APIs, consult official documentation before implementing.
- Follow `.ai/conventions.md`: no code comments unless explicitly requested, guard clauses instead of `else`/`else if`, and OWASP-based security rules for input validation and local storage.
- Always run shell commands with `rtk`.

## Code navigation tools

Use the right tool per task:

### `rtk` — files and commands

- All shell commands run through `rtk`.
- File reading and search use `rtk read`, `rtk grep`, `rtk find`, `rtk ls`.

### `code-review-graph` — structure and relationships

Prefer the knowledge graph over manual grepping for questions about code relationships:

```bash
code-review-graph status                  # check graph freshness
code-review-graph query callers_of X      # who calls X
code-review-graph query callees_of X      # what X calls
code-review-graph query imports_of F      # what file/module F imports
code-review-graph query importers_of F    # what depends on F
code-review-graph query tests_for X       # tests covering X
code-review-graph query inheritors_of C   # subclasses/implementations of C
code-review-graph impact X                # blast radius before refactoring
code-review-graph search <term>           # locate symbols
```

Graph maintenance:

- If the graph is stale or empty (`status` shows 0 nodes while code exists), run `code-review-graph build`.
- After implementing changes, run `code-review-graph update` (incremental) so subsequent reviews see current relationships.
- Do not rebuild from scratch unless `update` fails or reports inconsistency.

Decision rule: relationship/impact question → `code-review-graph`; content lookup inside one or few known files → `rtk`.

## Destructive commands

Never run destructive commands without explicit user authorization and without recording the reason in the spec or in `progress.md`.

Destructive commands include, among others:

- Docker and volumes: `docker compose down -v`, `docker volume rm`, `docker volume prune`;
- Git: `git reset --hard`, `git clean`, `git checkout --`, `git restore` on files not owned by the task, and `git push --force`;
- filesystem: `rm -rf`, `find -delete`, and equivalent recursive removals;
- device: `adb uninstall`, `adb shell pm clear`, and factory-reset actions on test devices.

Prefer non-destructive alternatives such as `--dry-run`, prior inspection, isolated tests, and read-only checks.

Exception: destructive commands may only be used when they are the explicit goal of the task, in a confirmed safe environment, with described impact and immediate human confirmation.

---

# Workflow

Every task must strictly follow the process defined in:

```
.ai/workflow.md
```

Do not create new steps nor skip steps unless explicitly requested by the user.

Every feature, bugfix, or task must start at the `Specify` step, which produces a versioned spec in `.ai/tasks/<slug>/spec.md`.

After the `Specify` step, every agent must read the spec before planning, implementing, validating, reviewing, adjusting, documenting, or wrapping up.

The final code review must compare the original request, the spec, the progress log, the actual diff, and the acceptance criteria of the related task in `docs/tasks/`. The review agent must not change code automatically.

`progress.md` is local and temporary. Continuity across machines, branches, clones, or agents must be recorded in the versioned spec before commit/push.

---

# Tests

Run only tests related to the changes made.

Commands run through Docker while the ENV phase defines the canonical interface (`docker compose run --rm dev ...`). The host is responsible for the Android emulator and ADB.

Whenever tests or functionality change:

- run affected unit and widget tests (`flutter test`);
- run `flutter analyze`;
- for persistence changes (Drift/preferences), run the related persistence tests;
- for device-affecting flows, validate on a physical device via host ADB when available.

When finishing, report:

- commands executed;
- results;
- failures found;
- affected coverage, when applicable.

Never claim tests pass without running them.

---

# Commits

Use Conventional Commits.

Format:

```
type(scope): description
```

Examples:

```
feat(domain): add ethanol vs gasoline recommendation rule

fix(persistence): handle null vehicle consumption fallback

chore(env): pin flutter version in docker image
```

---

# Documentation

Whenever an implementation changes behavior, architecture, flow, business rule, or technical decision, verify whether any document needs updating.

Priority:

1. Related task doc in `docs/tasks/`.
2. Domain/architecture docs in `docs/architecture/`.
3. Corresponding ADR in `docs/adr/`.
4. Planning docs in `docs/planning/`.
5. Other impacted documents.

Never update documentation that was not affected.

All project documentation is written in en-US. Keep it that way.

---

# Quality criteria

Every implementation must:

- respect the existing architecture (modular monolith layers);
- keep the domain pure: no dependency on Flutter, Drift, or SharedPreferences in domain code;
- isolate persistence in infrastructure;
- preserve decimal precision until presentation;
- keep offline behavior as a structural requirement;
- follow `.ai/conventions.md` (comments, control flow, security);
- follow SOLID, DRY, and KISS;
- minimize coupling;
- preserve compatibility;
- be fully typed;
- be easily testable;
- implement only what the task requires.

Always prefer consistency with the existing project over introducing new abstractions.
