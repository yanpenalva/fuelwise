# ADR-001 — Modular Monolith

**Status:** Accepted

## Context

The product is a small offline Flutter application with no backend or distributed coordination.

## Decision

Use a modular monolith with clear domain, application, infrastructure, and presentation boundaries.

## Consequences

Lower operational complexity, faster implementation, and independently testable domain logic. The team must prevent cross-layer coupling.
