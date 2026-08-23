# Stack

Fuelwise is an offline-first Flutter Android application. No backend, no cloud, no Flutter Web.

## Stack

| Component | Role | Status |
|-----------|------|--------|
| Flutter `3.47.1` (Android target) | Application framework | Pinned — see versions table in [`docs/planning/environment.md`](../docs/planning/environment.md) |
| Dart `3.13.1` | Language (bundled with Flutter) | Bundled |
| Riverpod `3.4.2` | State management (V1) | Implemented — preferences providers (V1 wave 1) |
| Drift `2.34.3` + `drift_flutter 0.3.1` (+ `drift_dev` 2.34.5, `build_runner` 2.16.0) | Local persistence (V1) | Implemented — schema v1, profile persistence (V1 wave 2); history wiring pending (wave 3) |
| shared_preferences `2.5.5` (`SharedPreferencesAsync`) | Lightweight preferences (V1) | Implemented — V1 wave 1 |
| Docker + Docker Compose (`dev` service) | Reproducible dev environment | Implemented — image `fuelwise-dev`, smoke-tested |
| Android SDK / Build Tools / NDK | APK builds inside container (API 36, minSdk 24) | Implemented; on-device install validated |

Versions are pinned in the "Versions and prerequisites" section of `docs/planning/environment.md` (recorded by ENV-001). Do not assume a version that is not documented there.

## Responsibilities split

- **Container**: Flutter, Dart, Android SDK tools, `flutter analyze`, `flutter test`, `flutter build apk`.
- **Host**: Docker, Docker Compose, ADB (platform-tools), USB/device connection, local APK server (HOST phase).
- **Device**: physical Android phone for installation and offline validation.

## Required installations

### Host

1. Docker Engine and Docker Compose plugin.
2. Android platform-tools (`adb`) for device testing.
3. `rtk` wrapper for all shell commands.

### Container (provided by the dev image, not installed manually)

- Flutter SDK (version pinned by ENV-001).
- Android SDK, Build Tools, and JDK.

No host-side Flutter installation is required once the ENV image exists; before that, any temporary host-side Flutter must match the versions recorded by ENV-001.

## Canonical commands (defined by ENV phase)

```bash
docker compose build dev
docker compose run --rm dev flutter pub get
docker compose run --rm dev flutter analyze
docker compose run --rm dev flutter test
docker compose run --rm dev flutter build apk --debug
```

These commands do not exist yet until ENV-003/ENV-004 are implemented. If `docker-compose.yml` is absent, record:

```
NOT FOUND
```
