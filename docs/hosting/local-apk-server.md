# Minimum Local APK Hosting

## Objective

Serve the APK over the local Wi-Fi network for manual installation and updates. The server must remain simple, local, unauthenticated, and separate from application data.

## Requirements

- Start only after V1 is functional.
- Use a minimal HTTP server or Nginx.
- Publish a page with application name, version, build date, and APK link.
- Operate only on the local network.

## Host prerequisites

The hosting host reuses the ENV-phase requirements from [`docs/planning/environment.md`](../planning/environment.md): Docker Engine `29.x`+ and Docker Compose. For device installation it also needs Android platform-tools (`adb`) with the per-OS setup documented there.

The APK targets minSdk `24` (Android 7.0) and is built against API `36`; the test phone must run Android 7.0 or newer.

## Expected flow

1. Build the APK in the container.
2. Copy or mount it into the served directory.
3. Open the local URL on the phone.
4. Download and install the APK.
5. Repeat the flow for an update.
