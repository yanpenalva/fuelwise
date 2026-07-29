# Android Device Testing

## Responsibility split

- Host: ADB, USB cable, and drivers.
- Container: APK build.
- Device: installation and application execution.

## Checklist

- Enable Developer Options.
- Enable USB debugging.
- Run `adb devices` on the host.
- Generate the APK in the container.
- Install with `adb install` or `adb install -r`.
- Open the application on the phone.
- Collect logs when a failure occurs.

ADB remains outside the main development container.
