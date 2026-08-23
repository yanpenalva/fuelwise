# Fuelwise

Fuelwise is an offline-first Flutter Android application that compares ethanol and gasoline using prices and vehicle efficiency values provided by the user.

The product is intentionally local: after installation, calculations, vehicle preferences, and history work without a backend, account, synchronization, or internet connection.

## Product scope

- Compare ethanol and gasoline prices.
- Use the standard `0.70` threshold or a threshold derived from vehicle consumption.
- Explain the rule used by the recommendation.
- Show cost per kilometer, maximum recommended ethanol price, and threshold difference.
- Store one vehicle profile and calculation history locally in V1.
- Show a branded loading state with the app motto on launch.
- Accept dot or comma as decimal separator in consumption fields, formatted to pt-BR comma as the user types.
- Export one history entry or one month as a local CSV with useful calculation details.
- Generate and distribute a test APK locally over Wi-Fi after V1.

The following are out of scope: backend services, cloud synchronization, multiple vehicles, real refueling records, maps, geolocation, Flutter Web, public hosting, app-store publishing, and remote CI/CD.

## Development phases

1. **ENV** — reproducible Docker development environment, static analysis, tests, APK build, and physical-device workflow.
2. **V0** — local calculation prototype without persistence or state-management infrastructure.
3. **V1** — offline MVP with Riverpod, Drift, preferences, vehicle profile, and history.
4. **HOST** — minimal local APK server and offline-device validation after V1.

## Documentation

Start with the English documentation in [`docs/README.md`](docs/README.md). The complete task breakdown remains organized under [`docs/tasks/`](docs/tasks/).

- [`docs/development/getting-started.md`](docs/development/getting-started.md) — **setup, daily commands, and on-device debugging (start here)**.
- [`docs/planning/`](docs/planning/) — scope, environment, versions, and execution order.
- [`docs/architecture/`](docs/architecture/) — architecture, domain, state, and persistence decisions.
- [`docs/adr/`](docs/adr/) — architecture decision records.
- [`docs/testing/`](docs/testing/) — test strategy.
- [`docs/device-testing/`](docs/device-testing/) — Android device and ADB workflow.
- [`docs/hosting/`](docs/hosting/) — local APK distribution.
- [`docs/tasks/`](docs/tasks/) — small, independently reviewable implementation tasks.

## Commands

All Flutter/SDK work happens inside the container. The host requires only Docker, Docker Compose, and `adb` for device steps.

```bash
docker compose build dev                                        # build/rebuild image
docker compose run --rm dev flutter pub get                     # install deps
docker compose run --rm dev flutter analyze                     # static analysis
docker compose run --rm dev flutter test                        # tests
docker compose run --rm dev flutter build apk --debug           # debug APK
docker compose run --rm dev bash                                # shell into container
```

Full workflow — including installing on a phone and running with hot reload over Wi-Fi — is documented in [`docs/development/getting-started.md`](docs/development/getting-started.md). Prerequisites and pinned versions: [`docs/planning/environment.md`](docs/planning/environment.md).

## License

See [`LICENSE`](LICENSE).
