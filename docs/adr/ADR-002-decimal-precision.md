# ADR-002 — Decimal Precision

**Status:** Accepted

## Context

Financial and consumption-ratio calculations can be affected by floating-point errors.

## Decision

Use decimal precision in the domain, avoid intermediate rounding, and round only in presentation.

## Consequences

Results and tests are more stable. Text input must be converted to decimal values through explicit validation.
