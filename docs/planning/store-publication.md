# Store Publication Plan

Planning document for publishing Fuelwise on the Google Play Store. This page is the working checklist; each item is a future task. Fuelwise is offline-first: no backend, no accounts, no connectivity requirements.

## Readiness gates

Before any store submission, the following must be true:

1. **Release build** — signed `app-release.aab` (Play App Signing) produced by the container toolchain; debug builds must never ship. Requires committing the release signing config in the Android module.
2. **Dependency audit** — `sqlite3_flutter_libs 0.6.0+eol` and transitive `sqlcipher_flutter_libs 0.7.0+eol` are end-of-life; replace (or justify) before release (OWASP A06 supply chain).
3. **Release smoke on physical device** — full offline flow validated on a release APK/AAB, not only debug.
4. **Privacy policy** — offline-first still requires a Play privacy policy (document that data stays on-device).
5. **Store listing assets** — app icon, feature graphic, screenshots (light + dark), short/full description (pt-BR + en-US).
6. **Targets** — targetSdk already 36; confirm Play requirements at submission time.

## Phased plan

Pending phases in execution order:

- **HOST phase** — local APK server and offline-device validation workflow (per `docs/hosting/local-apk-server.md` and `docs/planning/execution-order.md`).
- **Pre-release** — release signing, dependency EOL resolution, release smoke, privacy policy draft, listing assets, versioning policy (semver; `lib/presentation/release/app_release.dart` and `pubspec.yaml` in sync).
- **Submission** — internal testing track first, then closed testing, then staged production rollout.
- **Post-launch** — crash/ANR monitoring without third-party services to keep offline-first; keep listing updated per release.

## History storage strategy (product decision, implemented in V1)

Motivation: the app must never grow unbounded on small internal storage.

- **Cap**: history is limited to `HistoryController.maxHistoryEntries = 500` entries (application-layer constant).
- **Eviction**: automatic, oldest-first. When a new entry would exceed the cap, the newest 500 are kept and the oldest are deleted in the same save flow. Auto-eviction was chosen over user prompts for offline-first zero-friction; a 500-entry cap costs well under 1 MB of text rows.
- **UI**: history is grouped by month (`Agosto de 2026` style headers) with expandable/collapsible sections; per-entry deletion with confirmation remains available, so capacity is also user-manageable.

Storage estimate: each row is a text snapshot (~200–400 B); 500 rows ≈ 0.1–0.2 MB plus SQLite overhead — negligible on any Android device.

## Out of scope

Cloud sync/backup, exports, cross-device history, and remote monitoring remain out of scope for this publication cycle.