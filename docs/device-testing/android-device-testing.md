# Android Device Testing

Status: validated. APK generated in Docker and installed on a physical Android phone via host ADB; app launch confirmed on device.

## Responsibility split

- Host: ADB, USB cable, drivers, and the physical connection to the phone.
- Container: APK build only. No USB or ADB access; the container never talks to devices.
- Device: Developer options enabled, USB debugging authorized, and application execution.

USB and ADB stay outside the container by design: all device interaction runs on the host through `adb`.

## Enable Developer options and USB debugging

On the phone:

1. Open **Settings > About phone** and tap **Build number** seven times to unlock Developer options.
2. Go back to **Settings > System > Developer options**.
3. Enable **USB debugging**.

The exact menu names vary by vendor, but the Build number tap sequence is standard.

## Host verification

Before any installation, connect the phone by USB and confirm the host sees it:

```bash
adb devices
```

The device must be listed with status `device`. If it appears as `unauthorized`, accept the debugging authorization prompt on the phone and rerun the command.

## APK installation flow

Generate the APK inside the container:

```bash
docker compose run --rm dev flutter build apk --debug
```

Install it from the host:

```bash
adb install -r build/app/outputs/flutter-apk/app-debug.apk
```

`-r` reinstalls over an existing version, keeping the app data.

## Log collection

Filter logs to Flutter output only:

```bash
adb logcat -s flutter
```

Dump the full device log to a file for later analysis:

```bash
adb logcat -d > logs.txt
```

Use the filtered stream while reproducing an issue and the full dump when the failure is unclear.

## Uninstalling the app

```bash
adb uninstall <package>
```

This is a destructive command: it removes the application and its local data (including any stored history). Run it only with explicit intent.

## Troubleshooting

| Symptom | Cause | Fix |
|---------|-------|-----|
| Device listed as `unauthorized` | USB debugging authorization not accepted | Accept the prompt on the phone, then rerun `adb devices` |
| No permissions detected / device missing | udev rules missing (Linux) | Install/configure udev rules for the vendor, then unplug and replug the cable |
| Device listed as `offline` | Stale ADB state | Revoke USB debugging in Developer options on the phone, reconnect, and authorize again |
