# HOST-005 — Validate Offline Operation

## Objective

Prove that the installed application remains useful without network access.

## Prerequisites

The app is installed through local Wi-Fi or ADB.

## Subtasks

- Disable Wi-Fi and mobile data.
- Run standard and custom calculations.
- View the profile and history.
- Delete a history entry.
- Restart the application.
- Confirm data preservation.

## Expected files

- `docs/hosting/local-apk-server.md`.
- `docs/device-testing/android-device-testing.md`.

## Acceptance criteria

All V1 functionality works offline, the server is needed only to download new versions, and the app makes no external calls.

## Tests

Run the complete offline scenario before and after restarting the app.

## Out of scope

Synchronization, backend services, and external calls.
