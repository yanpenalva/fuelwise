# HOST-001 — Generate the Android Artifact

## Objective

Generate a predictable APK for local testing.

## Prerequisites

V1 is functional and the Docker build works.

## Subtasks

- Define the initial debug build.
- Generate the APK through Docker.
- Mount or copy it to the served directory.
- Add a page with name, version, and artifact build date generated from the APK.
- Document the artifact source.

## Expected files

- `docker-compose.yml`.
- `docs/hosting/local-apk-server.md`.

## Acceptance criteria

The APK is generated without Android Studio and can be found predictably without a backend.

## Tests

Build the APK and verify its path and metadata page.

## Out of scope

Release signing, store publishing, and public distribution.
