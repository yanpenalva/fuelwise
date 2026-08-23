# HOST-002 — Create the Local APK Server

## Objective

Serve the APK and a download page over the local network.

## Prerequisites

HOST-001 produced an APK artifact.

## Subtasks

- Add an `apk-server` Compose service.
- Use Nginx or a minimal HTTP server.
- Publish a local port.
- Serve the APK and download page.
- Document host IP, firewall, and Wi-Fi requirements.

## Expected files

- `docker-compose.yml`.
- `docker/nginx/` or server configuration.
- `docs/hosting/local-apk-server.md`.

## Acceptance criteria

The phone can open `https://HOST_IP:8443` after accepting the local certificate warning, download the APK, and the server exposes no application data. HTTP port 8080 only redirects to HTTPS.

## Tests

Open the page and download the APK from a phone on the same Wi-Fi network.

## Out of scope

Authentication, public hosting, backend, and application APIs.
