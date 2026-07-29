# ADR-005 — Partial-Consumption Fallback

**Status:** Accepted

## Context

The user may provide only one consumption value, while the calculation must remain useful.

## Decision

When there is not enough valid consumption data for a custom threshold, use the standard `0.70` threshold.

## Consequences

Partial input remains useful. The result must identify the applied rule as the standard fallback.
