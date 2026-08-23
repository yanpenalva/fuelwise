# ENV Phase — Development Environment

This phase precedes V0. Its goal is reproducible development and testing through Docker, with the host responsible for the Android emulator and ADB.

## Versions and prerequisites

All versions verified against the Flutter stable channel and Flutter `3.47.1` tooling sources.

### Toolchain (installed inside the dev container)

| Component | Version | Source |
|-----------|---------|--------|
| Flutter | `3.47.1` stable | Flutter stable channel |
| Dart | `3.13.1` | Bundled with Flutter 3.47.1 |
| JDK | `17` or newer (17 recommended) | Flutter tooling minimum (`errorJavaMinVersionAndroid = 17`) |
| Gradle | `9.3.1` | Flutter app template default (`templateDefaultGradleVersion`) |
| Android Gradle Plugin (AGP) | `9.1.0` | Flutter app template default (`templateAndroidGradlePluginVersion`) |
| Kotlin Gradle Plugin | `2.4.0` | Flutter app template default (`templateKotlinGradlePluginVersion`) |
| Android SDK Platform | API `35` and `36` | API 36 is compileSdk/targetSdk; API 35 is required by the current plugin graph |
| Android SDK Build-Tools | `36.0.0` | Matches compileSdk 36; confirm exact revision during ENV-006 smoke test |
| NDK (side by side) | `28.2.13676358` | Flutter 3.47.1 default (`ndkVersion`) |

### App Android targets

| Setting | Value | Meaning |
|---------|-------|---------|
| minSdk | `24` (Android 7.0) | Minimum device OS the APK installs on |
| targetSdk / compileSdk | `36` (Android 16) | Build and target platform used by the toolchain |

### Host requirements

| Requirement | Version | Notes |
|-------------|---------|-------|
| Docker Engine | `29.x` or newer | Verified locally: `29.7.2` |
| Docker Compose | Compose v2 plugin or newer | Verified locally: `v5.5.0` |
| Android platform-tools (`adb`) | Latest from Android SDK Manager | Device install/validation only; not needed in the container |
| Free disk space | At least `20 GB` | Dev image (~8–10 GB), pub cache, Gradle cache, and build outputs |
| RAM | At least `16 GB` recommended | Container builds plus host emulator/device workflow |

### Host commands by operating system

Canonical project commands always run through Docker (see below). Only the host-specific steps differ.

```bash
docker compose build dev
docker compose run --rm dev flutter pub get
docker compose run --rm dev flutter analyze
docker compose run --rm dev flutter test
docker compose run --rm dev flutter build apk --debug
```

- Linux: `adb` via distribution package (`sudo apt install adb`, Fedora: `sudo dnf install android-tools`) or SDK Manager platform-tools; udev rules may be required so the device is visible without root.
- macOS: `brew install --cask android-platform-tools`; grant USB debugging authorization on first connection.
- Windows: download [SDK Platform-Tools](https://developer.android.com/tools/releases/platform-tools) manually and add to `PATH`; OEM USB driver may be needed for physical devices.

Device verification (any OS):

```bash
adb devices          # device must be listed before installation
adb install -r app-debug.apk
```

## Command interface

All project commands run through Docker. Commands are independent of host SDK state: the host needs only Docker, Docker Compose, and `adb` for device steps. Never rely on a host Flutter installation or Android SDK.

```bash
docker compose build dev                                        # build/rebuild image
docker compose run --rm dev flutter pub get                     # install deps
docker compose run --rm dev flutter analyze                     # static analysis
docker compose run --rm dev flutter test                        # tests
docker compose run --rm dev flutter build apk --debug           # debug APK
docker compose run --rm dev bash                                # shell into container
docker compose down                                             # stop/remove containers (keeps volumes)
docker volume rm fuelwise_pub_cache                             # reset pub cache when needed
```

### Failure diagnostics

- `flutter analyze` or `flutter test` fails inside the container: reproduce interactively with `docker compose run --rm dev bash` and rerun the failing command there to inspect versions, environment variables, and files.
- `flutter pub get` fails: check host network/proxy configuration first (the container shares the host network). If dependencies remain corrupted after connectivity is restored, reset the cache with `docker volume rm fuelwise_pub_cache` and rerun `pub get`.
- `flutter build apk` fails with license errors: Android SDK licenses are pre-accepted in the image, so license errors indicate an SDK path or environment problem inside the container, not missing acceptance. Verify `ANDROID_SDK_ROOT`/`ANDROID_HOME` and the SDK location via `docker compose run --rm dev bash`.

## Tasks

- `ENV-001` Define versions and prerequisites. (done)
- `ENV-002` Create the development Docker image. (done)
- `ENV-003` Create Docker Compose. (done)
- `ENV-004` Standardize commands. (done)
- `ENV-005` Configure physical-device testing. (done — validated on an Android phone via host ADB)
- `ENV-006` Run the environment smoke test. (done — full container-to-device flow passed)

## Smoke test results

Executed against the minimal Flutter scaffold (`flutter create --platforms android .`, package `br.com.fuelwise/fuelwise`):

| Step | Result |
|------|--------|
| Image build (`docker compose build dev`) | Passed — image `fuelwise-dev` (~11.2 GB after removing unused desktop toolchain packages) |
| `flutter doctor -v` | Android toolchain ✓ (SDK 36, build-tools 36.0.0, JDK 17, licenses accepted); Chrome ✗ and Linux desktop ✗ irrelevant — Android-only scope |
| `flutter pub get` | Passed |
| `flutter analyze` | No issues found |
| `flutter test` | All tests passed |
| `flutter build apk --debug` | Passed — `build/app/outputs/flutter-apk/app-debug.apk` (debug size varies by dependency graph; SDK platforms are preinstalled in the image) |
| Install on phone via host ADB | **Passed** — physical device (`adb install -r`, streamed install success) |
| Launch on device | **Passed** — app process `br.com.fuelwise.fuelwise` confirmed running |

Note: the first scaffold derived the project name from the container working directory (`/workdir` → package `br.com.fuelwise.workdir`). It was regenerated with an explicit `--project-name fuelwise`; always pass this flag when scaffolding.

The environment is approved for V0 implementation; all ENV exit criteria are met.

## Exit criteria

- `flutter analyze`, `flutter test`, and `flutter build apk` run in the container.
- The APK can be installed on a physical phone through host ADB.
- The documentation clearly separates host, container, and device responsibilities.
