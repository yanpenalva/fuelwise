# ADR-007 — Docker Development Environment

**Status:** Accepted

## Context

The host environment must not be the foundation of development. Flutter, Android SDK, analysis, tests, and builds must be reproducible, while the host retains emulator and ADB responsibilities.

## Decision

Create a pinned Docker image for Flutter, Dart, and Android SDK, exposing analysis, test, and APK-build workflows through the container.

## Consequences

Less variation between machines and APK builds without a local SDK installation. Documentation must clearly separate host, container, and device responsibilities.
