# Conventions

Code standards that apply to every implementation. When a convention conflicts with an ADR or `docs/architecture/`, the ADR/architecture doc wins and this file must be updated.

## Project layout

- Follow the modular monolith layers strictly: `presentation` → `application` → `domain` ← `infrastructure`.
- Dependencies point inward only. Domain imports nothing from Flutter, Riverpod, Drift, or SharedPreferences.
- One responsibility per file; file name matches the main type (`fuel_calculation_input.dart` contains `FuelCalculationInput`).
- No barrel files that re-export infrastructure into the domain.
- Feature-first folders inside each layer are preferred over type-first folders when a feature grows beyond three files.

## Language and typing

- Fully typed code. Never use `dynamic`; prefer explicit types over `var` for public APIs.
- Model classes immutable: `final` fields, `const` constructors where possible.
- Use Dart 3 features deliberately: sealed classes + exhaustive `switch` for closed sets (e.g., `Recommendation`, `ThresholdSource`); records only for internal tuples, never public APIs.
- Nullable types only when absence is a valid state. Validate and convert at the boundary, then carry non-null values inward.
- Prefer composition over inheritance; avoid deep class hierarchies.
- Avoid static mutable state and singletons; inject dependencies through constructors.

## Comments

- Do not add comments to code unless explicitly requested by the user.
- Code must be self-explanatory: clear names, small functions, obvious types.
- Doc comments (`///`) are also excluded by default; only add them when the task explicitly requires public API documentation.
- Never leave commented-out code behind.

## Control flow

- Avoid `else` and `else if`. Use guard clauses (early return) instead.
- Prefer returning early on invalid input, null checks, and error paths.
- Ternaries are acceptable for short, direct expressions.
- Example:

```dart
// Avoid
if (ratio <= threshold) {
  return Recommendation.ethanol;
} else {
  return Recommendation.gasoline;
}

// Preferred
if (ratio <= threshold) {
  return Recommendation.ethanol;
}

return Recommendation.gasoline;
```

- Exhaustive `switch` on sealed types instead of boolean flag chains.
- Fail fast at boundaries; never return placeholder or sentinel values to signal errors.

## Validation and errors

- Validate all external input (UI forms, stored data) at the boundary before it enters the domain. Prices and consumption must be finite and greater than zero.
- Domain constructors either produce a valid object or throw/return failure explicitly — no half-valid objects.
- Define specific exception/failure types in the domain layer; never throw generic `Exception` or leak infrastructure errors upward.
- Map exceptions to typed failures in application/infrastructure; the presentation layer never receives raw stack traces.
- Never swallow exceptions silently. Every `catch` must handle, wrap, rethrow, or log-and-recover deliberately.

## Numbers and money

- Use a decimal representation in the domain for prices, ratios, thresholds, and consumption (ADR-002). Never `double` for money.
- Store decimals as text in Drift (ADR-002); parse explicitly with validation.
- Round only in the presentation layer, once, at display time.
- Preserve intermediate precision through every calculation step.

## State management (Riverpod)

- Keep providers small and single-purpose; compose providers instead of fat ones.
- Immutable state objects; emit new instances instead of mutating.
- UI reads state via widgets and dispatches intents/actions; no business rules in widgets or controllers.
- Async state exposes explicit loading/error/data states (sealed types preferred) — never null-as-loading.
- Side effects (navigation, snackbars) stay out of providers' build path.

## Persistence (Drift / preferences)

- All persistence lives in `infrastructure`: tables, DAOs, database class, mappers.
- Domain types never cross the persistence boundary directly; mappers convert both ways explicitly.
- Schema changes always bump the schema version with a migration; never edit history of applied migrations.
- Dates stored in UTC (see `docs/architecture/persistence.md`).
- History entries store complete snapshots (ADR-006); never reference live profile rows.
- Preferences keys defined as named constants in one place; no string literals scattered around.
- Fallback to standard threshold is explicit in results (ADR-005): the result carries which rule was applied.

## Naming

- English identifiers everywhere (code, tests, fixtures).
- Boolean: `isXxx`, `hasXxx`. Methods: verbs. Classes: nouns.
- Test names describe behavior: `recommends ethanol when ratio equals threshold`.

## Testing

- Unit-test the domain first; every rule in `docs/architecture/domain-model.md` has at least one test, including boundary cases (ratio exactly equal to threshold).
- Widget tests cover user flows, not implementation details.
- Persistence tests run against the real Drift database in-memory.
- Arrange–Act–Assert structure; one behavior per test.
- Tests follow the same conventions as production code (typing, guard clauses, no comments).

## Security (OWASP)

Follow OWASP guidance adapted to an offline-first mobile app (OWASP Mobile Top 10 / MASVS mindset):

- Treat all user input as untrusted: validate prices, consumption values, and thresholds at the domain boundary before any calculation.
- Validate input range and type (e.g., non-negative, finite numbers), not just presence.
- Store data only in the app's private storage (Drift database, shared preferences); never write sensitive data to external/shared storage or logs.
- Never log user data, prices, or internal state in release builds.
- Keep dependencies pinned and minimal; review new packages before adding them (supply chain — OWASP A06).
- Deny by default: any future permission, deep link, or exported component must be explicitly justified.
- No secrets in code, config files, or version control — the app is fully local, keep it that way.

## Adding a dependency

Before introducing any package:

1. Confirm the need is real — no dependency for what the SDK already solves.
2. Check pub.dev health: maintained, popular, compatible Flutter/Dart constraint.
3. Justify it in the spec; note it in `progress.md`.
4. Pin the exact version in `pubspec.yaml`.
