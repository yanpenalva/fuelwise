# HOST-004 — Document USB/ADB Installation

## Objective

Provide a host-side installation and diagnostics alternative.

## Prerequisites

ENV-005 and a Docker-generated APK are complete.

## Subtasks

- Locate the APK on the host.
- Run `adb install` and `adb install -r`.
- Collect logs with ADB.
- Document clean uninstall for tests.
- Keep ADB outside the container.

## Expected files

- `docs/device-testing/android-device-testing.md`.
- `docs/hosting/local-apk-server.md`.

## Acceptance criteria

The alternative install path works, logs can be collected, and ADB remains a host tool.

## Tests

Install, update, log, and uninstall an APK from the host.

## Out of scope

USB passthrough into Docker.
