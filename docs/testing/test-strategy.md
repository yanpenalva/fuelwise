# Test Strategy

## Goals

- Validate the domain without UI.
- Validate V0 forms and widgets.
- Validate V1 persistence and integration.
- Validate the complete offline user flow.

## Test layers

- Unit tests for calculation and validation.
- Widget tests for screens and forms.
- Persistence tests for Drift and preferences (in-memory database, decimal text round-trip, UTC instants, schema v1 pin, malformed-value fallbacks).
- Integration tests with replaceable dependencies (in-memory Drift over the real repositories through the UI: one history entry per calculation, profile prefill after restart, explicit profile save).
- On-device smoke validation of the complete offline flow via host ADB (calculation, history, profile, airplane mode, dark mode, rotation).

## Priorities

1. Calculation precision and rules.
2. Input validation.
3. Profile and history persistence.
4. V0 regression coverage.
5. Offline behavior on a physical phone.
