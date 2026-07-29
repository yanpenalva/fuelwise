# ADR-006 — Complete History Snapshot

**Status:** Accepted

## Context

History must remain readable when the current vehicle profile changes.

## Decision

Store a complete snapshot of the result and relevant values at calculation time.

## Consequences

History remains consistent and independent of the current profile, at the cost of slightly more storage per entry.
