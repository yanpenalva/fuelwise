# Getting Started

Complete guide to run Fuelwise locally, execute the daily development workflow, and debug on an Android phone. All heavy work runs inside Docker; the host never needs Flutter or the Android SDK.

## 1. Prerequisites (host)

Install only these:

| Tool | Version | Install |
|------|---------|---------|
| Docker Engine | `29.x`+ | [docs.docker.com](https://docs.docker.com/engine/install/) |
| Docker Compose | v2 plugin+ | Included with recent Docker Desktop / `docker-compose-plugin` package |
| Android platform-tools (`adb`) | latest | Linux: `sudo apt install adb` · macOS: `brew install --cask android-platform-tools` · Windows: [SDK Platform-Tools](https://developer.android.com/tools/releases/platform-tools) |
| Git | any | distribution package |

Hardware: at least 20 GB free disk and 16 GB RAM recommended. A physical Android 7.0+ phone for testing.

## 2. First-time setup

From the repository root:

```bash
docker compose build dev
```

Builds the `fuelwise-dev` image (~11 GB): Flutter 3.47.1, Dart 3.13.1, JDK 17, Android SDK API 36, Build-Tools 36.0.0, NDK 28.2.13676358, licenses pre-accepted, non-root user. Takes 10–20 minutes on the first run.

Verify:

```bash
docker compose run --rm dev flutter doctor
```

The Android toolchain must show `[✓]`. Chrome and Linux desktop entries may show `[✗]` — both are out of scope.

## 3. Daily commands

All commands run from the repository root. Nothing depends on host SDK state.

| Command | Purpose |
|---------|---------|
| `docker compose run --rm dev flutter pub get` | Install/update Dart packages |
| `docker compose run --rm dev flutter pub add <package>` | Add a new dependency |
| `docker compose run --rm dev flutter analyze` | Static analysis |
| `docker compose run --rm dev flutter test` | Run all tests |
| `docker compose run --rm dev flutter test test/<file>.dart` | Run one test file |
| `docker compose run --rm dev flutter build apk --debug` | Build debug APK |
| `docker compose run --rm dev bash` | Interactive shell inside the container |
| `docker compose down` | Stop/remove containers (keeps caches) |
| `docker volume rm fuelwise_pub_cache` | Reset pub cache (fixes corrupted downloads) |

Persistent volumes: `pub_cache` (downloaded packages) and `android_debug_keystore` (debug signing key + ADB keys — keeps APK signatures stable across builds).

## 4. Install the app on a phone (USB)

One-time on the phone: **Settings > About phone** → tap *Build number* 7× → enable **USB debugging** in Developer options.

```bash
adb devices                                                  # must list the phone as "device"
docker compose run --rm dev flutter build apk --debug
adb install -r build/app/outputs/flutter-apk/app-debug.apk   # -r updates over the existing app
```

Collect logs while reproducing an issue:

```bash
adb logcat -s flutter      # Flutter output only
adb logcat -d > logs.txt   # full dump
```

Details and troubleshooting: [`device-testing/android-device-testing.md`](../device-testing/android-device-testing.md).

## 5. Debug with hot reload (`flutter run`) over Wi-Fi

USB stays outside the container by design, so `flutter run` uses ADB over Wi-Fi: the container talks to the ADB server running on your host, which reaches the phone wirelessly.

### One-time preparation (every boot of the phone resets it)

With the phone connected by USB:

```bash
adb tcpip 5555                       # switches the phone's adbd to TCP mode
adb shell ip -f inet addr show wlan0 # note the phone IP, e.g. 192.168.1.26
```

Phone and computer must be on the same Wi-Fi network.

### Start the shared ADB server on the host

The container reuses the host's ADB server so the phone authorization is shared. The default ADB server only listens on localhost, so start it bound to all interfaces:

```bash
adb kill-server
nohup adb -a -P 5037 nodaemon server > /tmp/adb-server.log 2>&1 &
adb connect <PHONE_IP>:5555          # e.g. adb connect 192.168.1.26:5555
adb devices                          # phone must appear as "device"
```

Security note: this exposes port 5037 on your local network. Use only on trusted networks and stop it when done (`pkill -f "adb -a"` restores the normal behavior on the next plain `adb` command).

### Run the app from the container

```bash
docker compose run --rm dev flutter run -d <PHONE_ID>
```

`<PHONE_ID>` is what `adb devices` shows (serial over USB or `<PHONE_IP>:5555`). Inside the session:

| Key | Action |
|-----|--------|
| `r` | Hot reload |
| `R` | Hot restart |
| `q` | Quit |

The `docker-compose.yml` already points the container at the host ADB server via `ANDROID_ADB_SERVER_ADDRESS=host.docker.internal`.

## 6. Troubleshooting

| Symptom | Cause | Fix |
|---------|-------|-----|
| `adb devices` empty on host | Cable/debugging off | See [`device-testing/android-device-testing.md`](../device-testing/android-device-testing.md) troubleshooting table |
| Container `adb devices` shows `Connection refused` | Shared ADB server not started | Repeat section 5 step "Start the shared ADB server" |
| `INSTALL_FAILED_UPDATE_INCOMPATIBLE` | Signature changed (old builds before the keystore volume) | `adb uninstall br.com.fuelwise.fuelwise`, reinstall |
| Pub get fails in container | Network/proxy or corrupted cache | Retry; then `docker volume rm fuelwise_pub_cache` |
| Gradle/license error during APK build | Licenses are pre-baked; suspect env/path | Reproduce in `docker compose run --rm dev bash`, run `flutter doctor -v` |
| Phone lost after reboot | TCP mode resets | Redo section 5 one-time preparation |
