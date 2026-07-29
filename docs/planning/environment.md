# ENV Phase — Development Environment

This phase precedes V0. Its goal is reproducible development and testing through Docker, with the host responsible for the Android emulator and ADB.

## Tasks

- `ENV-001` Define versions and prerequisites.
- `ENV-002` Create the development Docker image.
- `ENV-003` Create Docker Compose.
- `ENV-004` Standardize commands.
- `ENV-005` Configure physical-device testing.
- `ENV-006` Run the environment smoke test.

## Exit criteria

- `flutter analyze`, `flutter test`, and `flutter build apk` run in the container.
- The APK can be installed on a physical phone through host ADB.
- The documentation clearly separates host, container, and device responsibilities.
