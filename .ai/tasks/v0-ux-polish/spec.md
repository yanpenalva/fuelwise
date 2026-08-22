# V0 UX Polish

## Objective

Apply user feedback from first on-device testing of the V0 prototype before starting V1.

## Feedback items

1. `Novo cálculo` button obscured by system navigation bar → respect safe area.
2. Layout too plain → richer visual hierarchy in form and result screens.
3. Add an application icon (flutter_launcher_icons + placeholder artwork, replaceable later).
4. Live input formatting: price fields behave as BRL currency mask (digits grouped, comma decimals); consumption fields show `L` suffix and hints clarifying km/l.
5. Clarify `Personalizada` rule semantics: threshold derived from consumption ratio, not a typed value. Relabel options accordingly.
6. Friendly loading indicator on Calculate tap (perceived responsiveness).
7. Welcome dialog explaining how the app works on open (every launch in V0; first-run-only deferred to V1 preferences).

## Constraints

- No persistence added in V0 (welcome dialog shows every launch).
- Keep domain untouched except nothing needed; all changes presentation-layer.
- Existing pt-BR labels used by tests must stay consistent; agents update affected tests within their file boundary.

## File boundaries

- Agent 1: `home_page.dart`, `fuel_input_field.dart`, affected tests (form/flow labels, welcome dialog).
- Agent 2: `result_view.dart`, `result_view_test.dart`.
- Main thread: app icon setup (`pubspec.yaml` dev dep, assets, manifest), spec/docs, final integration gate.

## Acceptance criteria

All 7 items addressed; analyze clean; full suite green; APK installs and runs on device with new visuals.

## Versioned Handoff

(n/a — single session)
