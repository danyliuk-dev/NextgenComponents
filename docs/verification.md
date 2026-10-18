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

## Forms and dates (0.2)

Second coordinated visible Chrome session on the same Linux iMac, task profile and CDP port. Foreground `xprop` evidence identified `Google-chrome`, title `Nextgen • Flutter - Google Chrome`. Only the task browser was closed with `Browser.close`; the next session was explicitly notified that the slot was free.

- Blazor `/forms`: invalid leap day, reversed date range, unavailable Sunday and invalid time blocked submit. Corrected values saved with searched facilitator Jamie, time 10:15 and added Coffee service. Calendar popup disabled Sunday and selected October 23, then closed. Dark/compact mode inspected. At 390 CSS px, document width was 375 px (scrollbar included), with no horizontal overflow.
- Flutter Web: typed invalid leap day, reversed range and invalid time displayed errors and blocked submit. Correcting them and selecting Jamie/Coffee produced the expected saved summary. Calendar dialog selected October 23, then the saved summary showed the new date. Reset cleared the saved result and summary errors. Light/dark/compact and 390 px layout were visually inspected.
- Screenshots inspected: `forms-blazor-light`, `forms-blazor-dark`, `forms-blazor-narrow`, `forms-flutter-light`, `forms-flutter-invalid`, `forms-flutter-range`, `forms-flutter-dark`, `forms-flutter-picker`, `forms-flutter-narrow` (PNG files under ignored `artifacts/browser`). Representative committed evidence: [Blazor](screenshots/forms-blazor-dark.png), [Flutter](screenshots/forms-flutter-dark.png), [Flutter calendar](screenshots/forms-flutter-picker.png).
- Automated: .NET solution builds without warnings; 16 component rendering checks plus 8 date-rule checks pass. Flutter's 12 foundation tests and 7 new forms/date tests pass; analysis has no issues. Shared token generation/contrast checks pass; Flutter Web builds including local renderer assets.
- Fixed during verification: same-value calendar selection must replace an invalid Flutter text draft; immediate range submit must validate the newly edited range; MultiSelect must update form state with the newly emitted list; the Blazor demo's locked date must use a nullable field expression rather than a conversion expression.

This is Web evidence. Native mobile/desktop execution and comprehensive screen-reader/browser-matrix audits remain unverified. Telerik feature parity is limited to the explicit [0.2 capability matrix](forms-and-dates.md).

## Data workspace (0.3)

Coordinated visible Chrome on local Linux iMac, CDP 9341, same isolated task profile. `xprop` confirmed the active `Google-chrome` window with the Flutter gallery title. Closed only that browser after review and explicitly released the slot to the other Codex session.

- Blazor `/data`: selected P001 and P006 across pages; returning to page one retained P001 selection. Numeric ascending budget order was P005, P011, P017, P001, P007. Search from the last page reset to the three matching Design system records; unmatched search showed the empty state. Team selection limited data to six Platform projects; Breadcrumb restored all 18. Required project-name validation blocked save. Saving Updated project / $333 updated the Grid, TreeList and Design total to $36,573; canceling a subsequent draft preserved the saved record. Portfolio search retained the team ancestor and matching child. Dark/compact and 390 px layout inspected, with no document overflow in Blazor.
- Flutter Web: repeated the same selection/page/numeric-sort/filter/empty/team/Breadcrumb scenarios. Empty project name and budget blocked save. Saving Updated project / $333 and canceling Discard me behaved correctly. Portfolio search displayed the ancestor and child; dark/compact and narrow stacked layout inspected. Table header sorting was exercised with real CDP pointer events, not synthetic DOM `.click()` (Flutter header semantics do not respond to synthetic clicks).
- Fixed during review: Flutter Pager and TreeView accessibility labels were duplicated; Pager now exposes one named action per button. Reordering keyed Flutter DataTable rows initially left stale accessibility DOM structure even though the canvas looked correct; table view identity now changes with sort/filter/page/visible row composition, and the repeat browser run verified both DOM row order and rendered behavior. Selected IDs remain external to the recreated table.
- Final automated checks: 37 .NET rendering/data/date checks; 29 Flutter tests (19 earlier tests plus 10 data tests), analysis without issues, .NET build without warnings, Flutter Web build and shared token/contrast checks. The data tests cover stable numeric sorting, ancestor retention, sibling-only sorting, duplicate IDs, selection across pages, source shrink, empty state, keyboard tree selection, disabled nodes, Breadcrumb navigation and required numeric input.
- Committed representative screenshots: [Blazor workspace](screenshots/data-blazor-dark.png), [Flutter workspace](screenshots/data-flutter-dark.png), [Blazor narrow](screenshots/data-blazor-narrow.png), [Flutter narrow](screenshots/data-flutter-narrow.png). Additional inspected screenshots remain under ignored `artifacts/browser`.

Full feature limits are in [data-workspace.md](data-workspace.md). No server-data, large-dataset/virtualization, full screen-reader certification or native mobile testing is claimed.

## Analytics and schedule (0.4)

Visible foreground Chrome on local Linux iMac, coordinated with the other session, isolated `/tmp/nextgen-components-review-04` profile and CDP 9341. `xprop` confirmed active class `Google-chrome` and title `Nextgen • Flutter - Google Chrome`. Closed the task browser with `Browser.close` and released the slot.

- Blazor `/analytics`: all six chart modes produced the expected 9 Cartesian / 5 circular point targets. Selected points by click and real Enter keyboard input. Toggled one/all series and empty data. Inspected area gaps, negative values and donut rendering. Verified gauges, week navigation, cross-midnight event in both day columns, event creation, rejected end-before-start, corrected save, draft cancel, edit and delete. Dark theme and 390 CSS px schedule inspected; document width 375 px, no page overflow.
- Flutter Web Analytics: switched all six modes; inspected column/bar/area/donut, legend colors and null gaps. Verified point selection through Chart data, series visibility and empty data. Used real keyboard input for schedule creation, invalid interval, corrected save, cancel, edit and deletion. Inspected light/dark/compact, gauges, weekly cards and the vertical 390 px schedule.
- A real mouse test with Flutter browser semantics enabled exposed a canvas click being intercepted by its generated semantic button. The plot now excludes that coordinate-free button; point actions remain available through Chart data. Final rebuilt Web test with semantics enabled selected `Variance · Tue: 8` by actual plotted-bar click and confirmed the parent selection callback. Hover tooltip was also visible.
- Other fixes: Blazor deferred legend rendering captured the loop index; chart tick calculation overflowed for otherwise valid large finite ranges; arc gauge zero fill now hides its foreground stroke. The legend SSR and large finite range checks cover the first two defects.
- Final automated results: .NET build has zero warnings/errors; **60 rendering and rule checks** pass. Flutter analysis has no issues; **36 widget/rule tests** pass. Flutter release Web build succeeds with local renderer assets. The existing unused CupertinoIcons font-family warning remains; no missing glyphs were observed in the reviewed controls.

Representative inspected screenshots: [Blazor area/gauges](screenshots/analytics-blazor-area.png), [Blazor weekly schedule](screenshots/analytics-blazor-schedule.png), [Blazor narrow](screenshots/analytics-blazor-narrow.png), [Flutter donut](screenshots/analytics-flutter-donut.png), [Flutter interval validation](screenshots/analytics-flutter-invalid.png), [Flutter dark schedule](screenshots/analytics-flutter-schedule.png), [Flutter narrow schedule](screenshots/analytics-flutter-narrow-schedule.png). Additional mode and pointer evidence stays in ignored `artifacts/browser`.

This is a bounded implementation of phase 4: 4 additional public controls (31 total), mapped to 10 catalogue entries (37 total) including the six chart modes. Advanced features and remaining phase-4 entries stay planned. Native mobile platforms, complete keyboard/screen-reader certification, large-data performance and full Telerik parity are not verified. See the [capability matrix](analytics-and-schedule.md).
