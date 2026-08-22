# ENV-002..006 — Development Environment Implementation

## Objective

Implement the complete ENV phase: reproducible Docker image, Compose workflow, standardized commands, device-testing documentation, and the approval smoke test.

Covers `docs/tasks/environment/ENV-002.md` through `ENV-006.md`.

## Scope

- `docker/Dockerfile`: pinned toolchain (Flutter 3.47.1 / Dart 3.13.1, JDK 17, Android API 36, Build-Tools 36.0.0, NDK 28.2.13676358, cmdline-tools), licenses accepted at build time, PATH configured, non-root user.
- `docker-compose.yml`: `dev` service, project mount, pub cache volume, workdir `/workdir`, no USB/ADB inside container.
- Command interface documented in `README.md` + `docs/planning/environment.md`.
- `docs/device-testing/android-device-testing.md` expanded: developer options, USB debugging, host ADB verification, install, logs; container stays out of USB path.
- Smoke test (ENV-006): minimal Flutter app in repo root (`lib/main.dart`, `pubspec.yaml`, android platform files), run analyze/test/build apk in container.

## Non-goals

- Product features beyond smoke-test app.
- Emulator inside Docker, APK hosting (HOST phase).
- Release/signing configuration.

## Affected files

- `docker/Dockerfile`
- `docker-compose.yml`
- `.dockerignore`
- `README.md`
- `docs/planning/environment.md`
- `docs/device-testing/android-device-testing.md`
- minimal Flutter app scaffold for the smoke test

## Acceptance criteria

1. Image builds without manual intervention; `flutter doctor` passes inside it.
2. `flutter analyze`, `flutter test`, `flutter build apk --debug` succeed via `docker compose run --rm dev`.
3. Commands are documented and independent of host SDK state.
4. Device flow documented with host/container responsibility split.
5. ENV exit criteria from `docs/planning/environment.md` met (device install step depends on physical phone availability).

## Test plan

- Build image; run `flutter doctor`.
- Run the three canonical commands against a freshly created minimal app.
- Device steps validated only if a phone is attached; otherwise recorded as pending.

## Versioned Handoff

(none — single session)
