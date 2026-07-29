# Fuelwise

Fuelwise is an offline-first Flutter Android application that compares ethanol and gasoline using prices and vehicle efficiency values provided by the user.

The product is intentionally local: after installation, calculations, vehicle preferences, and history work without a backend, account, synchronization, or internet connection.

## Current status

The repository currently contains the approved product plan and implementation tasks. Product code will be implemented in the order described in [`docs/planning/execution-order.md`](docs/planning/execution-order.md).

## Product scope

- Compare ethanol and gasoline prices.
- Use the standard `0.70` threshold or a threshold derived from vehicle consumption.
- Explain the rule used by the recommendation.
- Show cost per kilometer, maximum recommended ethanol price, and threshold difference.
- Store one vehicle profile and calculation history locally in V1.
- Generate and distribute a test APK locally over Wi-Fi after V1.

The following are out of scope: backend services, cloud synchronization, multiple vehicles, real refueling records, exports, maps, geolocation, Flutter Web, public hosting, app-store publishing, and remote CI/CD.

## Development phases

1. **ENV** — reproducible Docker development environment, static analysis, tests, APK build, and physical-device workflow.
2. **V0** — local calculation prototype without persistence or state-management infrastructure.
3. **V1** — offline MVP with Riverpod, Drift, preferences, vehicle profile, and history.
4. **HOST** — minimal local APK server and offline-device validation after V1.

## Documentation

Start with the English documentation in [`docs/README.md`](docs/README.md). The complete task breakdown remains organized under [`docs/tasks/`](docs/tasks/).

- [`docs/planning/`](docs/planning/) — scope, environment, versions, and execution order.
- [`docs/architecture/`](docs/architecture/) — architecture, domain, state, and persistence decisions.
- [`docs/adr/`](docs/adr/) — architecture decision records.
- [`docs/testing/`](docs/testing/) — test strategy.
- [`docs/device-testing/`](docs/device-testing/) — Android device and ADB workflow.
- [`docs/hosting/`](docs/hosting/) — local APK distribution.
- [`docs/tasks/`](docs/tasks/) — small, independently reviewable implementation tasks.

## Planned commands

The canonical commands will run through Docker and are documented in [`docs/planning/environment.md`](docs/planning/environment.md):

```bash
docker compose build dev
docker compose run --rm dev flutter pub get
docker compose run --rm dev flutter analyze
docker compose run --rm dev flutter test
docker compose run --rm dev flutter build apk --debug
```

The Android emulator and USB/ADB remain on the host. The main development container provides Flutter, Dart, Android SDK tools, analysis, tests, and APK builds.

## License

See [`LICENSE`](LICENSE).
