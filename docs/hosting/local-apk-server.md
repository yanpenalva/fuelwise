# Minimum Local APK Hosting

## Objective

Serve the APK over the local Wi-Fi network for manual installation and updates. The server must remain simple, local, unauthenticated, and separate from application data.

## Requirements

- Start only after V1 is functional.
- Use a minimal HTTP server or Nginx.
- Publish a page with application name, version, build date, and APK link.
- Operate only on the local network.

## Expected flow

1. Build the APK in the container.
2. Copy or mount it into the served directory.
3. Open the local URL on the phone.
4. Download and install the APK.
5. Repeat the flow for an update.
