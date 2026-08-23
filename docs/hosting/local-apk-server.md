# Local APK Hosting

Serve the debug APK over the local Wi-Fi network for manual installation and updates. The server stays simple, local, unauthenticated, and separated from application data.

## Requirements

- Docker Engine `29.x`+ and Docker Compose (host).
- Android platform-tools (`adb`) on the host for the ADB alternative (see [`docs/device-testing/android-device-testing.md`](../device-testing/android-device-testing.md)).
- Phone running Android 7.0+ (minSdk 24) on the same Wi-Fi network.

## HOST-001 — Generate the artifact

The APK is generated inside the dev container (no Android Studio):

```bash
docker compose run --rm dev flutter build apk --debug
```

Artifact: `build/app/outputs/flutter-apk/app-debug.apk`. The download page displays the app name, version (`v1.0.0`), build type, and the APK file modification date generated when the server starts.

## HOST-002 — Serve over the local network

Start the server:

```bash
docker compose up -d --force-recreate apk-server
```

What runs: an `nginx:1.27-alpine` service serving a generated page from `docker/nginx/index.html` at `/` and the APK directory at `/apk/` (read-only mount of `build/app/outputs/flutter-apk`). No application data is exposed; only the APK and static page.

HTTP (`:8080`) redirects to HTTPS (`:8443`): modern Chrome refuses APK downloads over plain HTTP, so the download page and the APK are served with a self-signed certificate.

One-time certificate generation (host, requires `openssl`; certs are git-ignored — never commit the key):

```bash
mkdir -p docker/nginx/certs
openssl req -x509 -newkey rsa:2048 \
  -keyout docker/nginx/certs/server.key \
  -out docker/nginx/certs/server.crt \
  -days 3650 -nodes -subj "/CN=HOST_IP" \
  -addext "subjectAltName=IP:HOST_IP,IP:127.0.0.1,DNS:localhost"
docker compose up -d --force-recreate apk-server
```

The phone will show a self-signed warning once — tap **Advanced → Proceed**; it is then remembered for this server.

Find the host IP (Linux):

```bash
ip -4 addr show | grep -oE '192\.168\.[0-9]+\.[0-9]+' | head -1
```

Firewall note: allow TCP `8080` and `8443` on the host (e.g., `sudo ufw allow 8080/tcp && sudo ufw allow 8443/tcp`). The phone must be on the same Wi-Fi/LAN.

Verify from the host:

```bash
curl -fsSI http://127.0.0.1:8080/apk/app-debug.apk | head -1       # expect 301
curl -kfsSI https://127.0.0.1:8443/apk/app-debug.apk | head -1    # expect 200
```

## HOST-003 — Install/update from the phone browser

1. Put the phone on the same Wi-Fi as the host.
2. Open `https://HOST_IP:8443` in the phone browser (accept the self-signed warning once).
3. Tap **Download APK (app-debug.apk)**.
4. When prompted, allow installing from this source ("unknown sources").
5. Open the downloaded file and install. For an update, repeat — `install -r` semantics keep app data.

Common errors:

| Symptom | Fix |
|---|---|
| Page doesn't load on the phone | Same network? Host firewall allows 8080 and 8443? Server running? |
| "App not installed" | Enable unknown sources / allow this app source; check storage |
| Stale version shown after install | The download page caches; hard-refresh the page |
| APK 404 | Build output missing — run the HOST-001 build first |
| Another app opens the APK | Use the browser download notification or the system Files app and select Android Package Installer; this is device-specific intent handling |

## HOST-004 — ADB alternative

ADB stays a host tool (never inside the container):

```bash
adb devices                       # phone must show "device"
adb install -r build/app/outputs/flutter-apk/app-debug.apk
adb logcat -s flutter             # filtered logs
adb uninstall br.com.fuelwise.fuelwise   # clean slate (destructive: wipes data)
```

Full flow and troubleshooting: [`docs/device-testing/android-device-testing.md`](../device-testing/android-device-testing.md).

## HOST-005 — Validate offline operation

After installing (Wi-Fi or ADB), prove the app needs no network:

1. Disable Wi-Fi and mobile data (or airplane mode).
2. Run standard and custom calculations.
3. Open profile and history; export a history month/entry.
4. Delete a history entry.
5. Kill and reopen the app; confirm data is preserved.

Acceptance: every V1 function works offline; the server is needed only to download new versions; the app makes no external calls.

## Out of scope

Authentication, public hosting, backend, APIs, release signing, and store publishing.
