# ENV-001 — Versions and Prerequisites

## Objective

Record the exact development-tool versions and host prerequisites required to build the reproducible Docker environment, so no version stays implicit.

## Scope

- Pin Flutter/Dart, Android SDK, Build Tools, JDK, Gradle/AGP/Kotlin/NDK versions.
- Define the minimum Android OS version for the app.
- Record Docker, Docker Compose, disk, and memory requirements.
- Document per-OS (Linux, macOS, Windows) host commands.

## Non-goals

- Creating the Docker image or Compose file (ENV-002/ENV-003).
- Installing anything on the host automatically.

## Sources

- Flutter stable release channel (verified `3.47.1`, Dart `3.13.1`).
- Flutter `3.47.1` tooling source: `gradle_utils.dart` constants (compileSdk 36, minSdk 24, targetSdk 36, Java min 17, Gradle 9.3.1, AGP 9.1.0, Kotlin 2.4.0, NDK 28.2.13676358).
- Host verification: Docker `29.7.2` and Compose `v5.5.0` present.

## Affected files

- `docs/planning/environment.md`
- `docs/hosting/local-apk-server.md`

## Acceptance criteria

- Required tools are identifiable with exact versions.
- Versions are mutually compatible (Flutter 3.47.1 ↔ AGP 9.1.0 ↔ Gradle 9.3.1 ↔ JDK 17+ ↔ compileSdk 36).
- No version is implicit; every pinned value has a source.

## Test plan

Documentation-only task: manual review of consistency between both documents and this spec.

## Versioned Handoff

(none — single session)
