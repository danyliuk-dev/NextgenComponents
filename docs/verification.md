# Verification — 2026-10-18

## Local visible Chrome

Completed on **Linux, kolizej-iMac**, in ordinary visible Google Chrome. The user explicitly authorized direct CDP control after the standard browser connector returned no browsers. A separate task profile/window and CDP port 9341 were used. `xprop` confirmed the active window was `Google-chrome` with title `Nextgen • Blazor - Google Chrome`. The slot was agreed with the other active Codex session before launch. Only the task browser was closed at completion.

Both galleries were served on loopback: Blazor `http://127.0.0.1:5180`, Flutter `http://127.0.0.1:5181`.

### Observed results

- **Blazor:** light/dark, regular/compact, text and numeric input, required-name validation, numeric upper bound, dropdown/radio/checkbox/switch changes, disabled button, saved notification and dismissal all passed. Dialog showed the edited name/team/seats/access, closed with Escape, reopened and closed with Done. ArrowRight selected the Keyboard tab. Focus revealed the tooltip. At 390 px width, the form became one column with no horizontal document overflow.
- **Flutter:** light/dark, regular/compact, native text input, required-name and numeric upper-bound validation, dropdown selection, radio/checkbox/switch changes, saved notification and dismissal passed. Dialog displayed edited values and closed on Escape. Clicking Keyboard switched content. Hover revealed the tooltip. The 390 px layout wrapped the form and radio group without visible clipping in the inspected region.
- Screenshots were inspected, not merely generated. They are stored under `artifacts/browser/` (ignored build evidence): `blazor-light.png`, `blazor-dark-dialog.png`, `blazor-dark-compact.png`, `blazor-tooltip.png`, `blazor-narrow.png`, `flutter-light.png`, `flutter-dark-compact.png`, `flutter-validation.png`, `flutter-dropdown.png`, `flutter-numeric-validation.png`, `flutter-saved.png`, `flutter-dialog.png`, `flutter-keyboard-tab.png`, `flutter-tooltip.png`, `flutter-narrow.png`, `flutter-fixed.png`.

Representative screenshots are included in Git: [Blazor desktop](screenshots/blazor-dark-compact.png), [Blazor narrow](screenshots/blazor-narrow.png), [Flutter after fixes](screenshots/flutter-fixed.png), [Flutter narrow](screenshots/flutter-narrow.png).

### Defects found and fixed

1. Flutter radio options lacked individual accessible names. Each option now merges the radio and its label into one semantic node, and label clicks select the option. Browser semantics after rebuild expose `Viewer`, `Editor`, `Administrator` individually; regression test passed.
2. Flutter text validation retained a required-field error after the user corrected the value. Text fields now validate on interaction. Browser retest confirmed the error appears for empty input and disappears after correction, before another submit.

## Automated checks

- .NET SDK 10.0.112: library/gallery/checks build passed with zero warnings/errors.
- Blazor: 11 server-rendering checks passed, covering encoding, label association, selected/disabled states and ARIA output.
- Flutter SDK 3.47.6 / Dart 3.13.5: analysis passed. Final runtime suite: **12 widget tests passed**, including the radio semantic-name regression and immediate validation correction.
- Final Flutter release web rebuild succeeded with local renderer assets. A build-time font-family warning mentioned CupertinoIcons; no missing glyphs were observed in the exercised controls.
- Shared-token generation consistency and core text/button contrast checks passed (at least 4.5:1 for the tested pairs).

## Scope limits

This verifies the foundation subset, not complete Telerik parity. No physical mobile device, desktop-native build, full screen-reader audit, performance benchmark, or exhaustive cross-browser/keyboard suite was performed. Flutter tabs were clicked in the browser; their keyboard implementation is native Flutter and was not exhaustively audited. Browser console/network monitoring was not recorded as a comprehensive error audit.

## Repeating the review

Coordinate a Chrome slot first. Start the galleries, then use an isolated visible local Chrome profile and a free CDP port. `scripts/chrome-review.mjs` is a dependency-free Node 22+ CDP helper for the currently fixed review endpoint 9341; it accepts a JSON file of evaluation, protocol and screenshot actions. Never run it against a shared user profile without explicitly choosing the intended tab.

Earlier sandbox restrictions were resolved by a session permission change. Flutter used a temporary SDK copy and cache metadata under `/tmp`; project build/test behavior does not depend on those paths. Offline .NET verification used the existing NuGet cache with vulnerability auditing disabled for that command only. Repository defaults remain unchanged.
