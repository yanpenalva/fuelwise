# Dependencies

Runtime dependencies added in V0 and the rules governing future additions.

## Runtime dependencies

| Package | Version | Purpose |
| --- | --- | --- |
| `decimal` | ^3.2.6 | Exact decimal arithmetic for prices, consumption, ratios, and thresholds (ADR-002). `double` is never used for money. |
| `intl` | ^0.20.3 | pt-BR number formatting in the presentation layer. Rounding happens once, at display time. |
| `flutter_localizations` | sdk: flutter | pt-BR Material/Cupertino strings backing `Locale('pt', 'BR')`. |

Transitive companions pulled by `decimal`: `rational` (arbitrary-precision rational arithmetic).

## Rules for new dependencies

Per `.ai/conventions.md`, every new package must:

1. Solve a real need the SDK cannot cover.
2. Be healthy on pub.dev (maintained, popular, compatible with the Flutter/Dart constraint).
3. Be justified in the task spec before implementation.
4. Be pinned in `pubspec.yaml`.

No dependency may cross into the domain layer: domain code depends only on pure Dart.
