# ADR-004 — Drift for Local Persistence

**Status:** Accepted

## Context

V1 requires typed local persistence and structured queries for a growing history.

## Decision

Use Drift over SQLite for the vehicle profile and calculation history.

## Consequences

Typed queries and mappers, an evolvable schema, and in-memory database testing. Code generation becomes part of the build workflow.
