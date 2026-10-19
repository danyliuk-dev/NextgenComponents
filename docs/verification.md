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

## Workbook and manual (0.5)

Coordinated visible foreground Chrome on Linux iMac, task profile `/tmp/nextgen-components-review-05`, port 9341. `xprop` identified active `Google-chrome` with the Flutter gallery title. Browser closed with `Browser.close`, slot released to the other session.

- Blazor and Flutter Web: edited C2 from 10 to 12; E2 recalculated from 1000 to 1200, E7 and the pivot total from 13050 to 13250. Undo/Redo restored both calculated values and pivot totals. A self-reference in E2 showed #CYCLE! and excluded that invalid cost record from the demo pivot; Undo repaired it.
- Switched pivot to Average: source-weighted grand total 2650, Design/Q1 1600. Clicking that cell displayed its two original records with costs 1200 and 2000.
- Both platforms accepted a two-column TSV paste, recalculated dependent formulas, and rejected a paste beyond the sheet boundary without changing cells. The final Flutter overflow check was performed with the action scrolled visibly into view; an earlier offscreen semantic click did not exercise the action and is not counted as proof.
- Arrow navigation selected D2 from C2 in both platforms; Blazor also transferred actual DOM focus. Light/dark layouts and 390 CSS px layouts were visually inspected. Fixed an unanchored Blazor screen-reader span causing page overflow; final document width 375 px for a 390 px viewport, with the wide sheet scrolling inside its container. Flutter keeps the sheet/pivot in horizontal scroll containers; full touch/mobile-native behavior remains unverified.
- Fixed during verification: explicit Blazor ValueExpression and dynamic string bindings in the demo; cell focus for Flutter keyboard navigation; Blazor keyboard movement relative to the focused cell; narrow-page containment. Formula tests cover parsing precedence, reference updates, cycles, limits, memoized dependency fanout, large finite averages and atomic paste. Pivot tests cover weighted totals, blanks vs totals, null measures and duplicate IDs.
- Final automated checks: **80 .NET rendering/rule checks** and **44 Flutter tests** passed; Flutter analysis has no issues. The release Web build succeeded with local renderer assets (the existing unused CupertinoIcons warning remains). Shared theme/contrast checks passed.
- Added a Russian manual: 33 component pages, setup/state/validation guide, models/formulas reference. Every page has Blazor and Flutter code examples, parameter/event tables and behavior/limitations. All **33 Razor examples compile** with zero warnings/errors; all **33 Dart examples pass analysis**. This validates code syntax and API compatibility, not exhaustive runtime behavior of every sample. `scripts/check_manual_examples.py` makes these checks repeatable.

Representative inspected screenshots: [Blazor workbook](screenshots/workbook-blazor-initial.png), [Blazor pivot/drilldown](screenshots/workbook-blazor-pivot.png), [Blazor narrow fix](screenshots/workbook-blazor-narrow-fixed.png), [Flutter dark pivot](screenshots/workbook-flutter-pivot.png), [Flutter narrow](screenshots/workbook-flutter-narrow.png), [Flutter rejected paste](screenshots/workbook-flutter-paste-error.png).

Scope: two additional controls, 33 controls / 39 catalogue entries. [Workbook matrix](workbook.md) lists remaining XLSX/CSV, formatting, full Excel formulas, OLAP, multiple measures and virtualization work. Other phase-5 components remain planned. Mobile testing remains deferred.

## 0.6 — structured document editor (2026-10-18)

Added NgEditor on both platforms: immutable blocks, paragraphs/headings/lists/quotes, block-level emphasis/alignment, add/delete/reorder, draft application, 50-operation history, read-only, bounded JSON v1 and escaped HTML export. This is a structured editor with separate preview, not full HTML WYSIWYG parity. See [capabilities](editor.md) and [Russian manual](manual/NgEditor.md).

Validation:

- .NET solution build: zero warnings/errors; 95 rendering/model checks passed, including JSON roundtrip, immutable reorder, safe HTML, list grouping, invalid versions/properties/enums and size limits.
- Flutter: all 47 tests passed; targeted editor widget coverage includes formatting, undo/redo, reorder, add/delete, external replacement/history reset and read-only. Dropdown width overflow caught by the first run was fixed with expanded dropdown content and the tests were rerun successfully.
- Dart analysis: no issues. Flutter Web release built with local renderer assets. Existing unused CupertinoIcons font warning remains; the editor does not use CupertinoIcons.
- All 34 Blazor manual examples compiled and all 34 Flutter examples passed analysis. Manual links, 34-component/40-entry catalogue totals, generated themes and contrast checks passed.
- Normal foreground Chrome on local `kolizej-iMac` (Linux), isolated `/tmp/nextgen-components-review-06`, CDP 9341. The browser slot was coordinated with the other task. X11 active window `0x1600003` identified `google-chrome (/tmp/nextgen-components-review-06)` and `Nextgen • Document editor - Google Chrome`; no headless or remote-host substitution.
- Blazor: typed text containing `<script>`, applied Bold, checked escaped preview/export; Undo/Redo, Move down, add/apply/delete, JSON export, invalid import preserving the document, successful import clearing history, read-only, heading type and centered alignment.
- Flutter: typed/applied text, Bold, Undo/Redo, Move down, add/delete, JSON export, invalid import preserving the current document, successful import clearing history, read-only disabling actions. Imported actual Blazor JSON into Flutter; imported actual Flutter JSON back into Blazor with text/order/formatting preserved. The first automated import attempt did not wait for Flutter text-field focus and did not enter the payload; only the retried import with confirmed source text and success state is counted as evidence.
- Inspected light/wide and dark/compact at 390 CSS px on both platforms. The first Blazor narrow check exposed inherited gallery nav wrapping; fixed the component outline to a non-wrapping vertical scroller. Final outline content width matched client width (286px); document width 375px at viewport 390px. Flutter narrow view showed wrapping content and no visible overflow markers.
- Closed only the task Chrome profile with `Browser.close`, then released the browser slot. Mobile/desktop-native and screen reader tests remain deferred; screenshots at narrow desktop width do not establish native mobile support.

Screenshots inspected:

- [Blazor: Flutter JSON import and centered heading](screenshots/editor-blazor-cross-import.png)
- [Blazor: fixed narrow dark editor](screenshots/editor-blazor-narrow-fixed.png)
- [Flutter: initial light editor](screenshots/editor-flutter-initial.png)
- [Flutter: successful Blazor JSON import](screenshots/editor-flutter-import-success.png)
- [Flutter: narrow dark preview/read-only](screenshots/editor-flutter-narrow.png)

## 0.7 — interactive diagrams (2026-10-18)

Added NgDiagram and shared validated graph model on Blazor/Flutter: three shapes, straight directed/undirected connections, selection, drag preview with commit on release, Escape cancellation, keyboard moves, zoom/fit/scroll and read-only. Gallery forms cover node/edge CRUD, cascade delete, 20-change undo and JSON. [Capabilities](diagram.md) and [Russian manual](manual/NgDiagram.md) describe the implemented subset and remaining gaps.

Validation:

- .NET solution built without warnings/errors. 114 rendering/model checks passed, including boundary anchors, finite geometry, duplicate IDs, dangling/self links, cascade removal, immutable moves, required JSON coordinates and maximum-size Unicode roundtrip. The JSON limit was raised to 1000000 characters so a valid 100-node/200-edge graph with maximum Unicode labels and long IDs also roundtrips after .NET escaping.
- Flutter full suite: 51 tests passed. Diagram tests exercise drag committing once, 10/1-unit keyboard movement, Escape, selection, read-only, empty replacement, bounds, JSON and Fit width without horizontal overflow. The latter caught/fixes the viewport's 2px border allowance.
- All 35 Blazor examples compiled and all 35 Flutter examples passed analysis. Dart analysis found no issues; manual links, theme/contrast checks and 35-component/41-entry catalogue totals passed. Web build includes local renderer assets; the existing unused CupertinoIcons font warning remains.
- Normal visible foreground Chrome on local Linux `kolizej-iMac`, isolated `/tmp/nextgen-components-review-07`, CDP 9341, coordinated with the other task. No headless/remote-host substitution.
- Both platforms: pointer drag from (50,180) to (130,220); Escape kept that position; ArrowRight produced (140,220). At 50% zoom a 60×20 CSS-pixel drag produced a 120×40 model-unit change to (260,260). Read-only drag did not change coordinates. Fit width, light/dark and compact at desktop and 390px widths were inspected.
- Blazor: node rename/add, edge add, self-link rejection, node removal cascading edges, Undo restoring both, invalid import preserving the graph, actual Flutter JSON import. Space selects a focused edge without scrolling the page.
- Flutter: node rename/add, endpoint selection with arrow keys/Enter, connection creation, selected-edge deletion, invalid JSON rejection, actual Blazor JSON import. Input focus was awaited before typing. One early browser check raced the next render after Add node; it was stopped and the resulting graph was inspected before continuing. Only confirmed state transitions are counted.
- Exchanged actual gallery JSON in both directions: Blazor → Flutter included 5 nodes/5 edges and a rectangular Archive; Flutter → Blazor included 5 nodes/4 edges and an elliptical Archive. IDs, geometry, text and shape survived the imports.
- Blazor narrow document width was 375px at a 390px viewport. Flutter Fit width was corrected to account for the 2px viewport border and verified by widget geometry and a final browser check. Fit width still fits the whole canvas, making small graphs tiny on narrow screens; a separate Fit diagram action has been proposed and is not included here.
- Native mobile, screen reader certification, automatic layout/obstacle routing and export to image/PDF remain unverified/unimplemented as documented. Chrome was closed after final evidence capture; unrelated browser sessions were preserved.

Screenshots inspected:

- [Blazor: Flutter JSON and edge selection](screenshots/diagram-blazor-cross-import.png)
- [Blazor: narrow dark/compact/read-only](screenshots/diagram-blazor-narrow.png)
- [Flutter: imported Blazor graph](screenshots/diagram-flutter-import.png)
- [Flutter: final narrow Fit width](screenshots/diagram-flutter-narrow-final.png)

## 0.7.1 — Fit diagram (2026-10-18)

- .NET build and 119 rendering/model checks passed; Flutter web build, 53 tests and analyzer passed.
- All 35 Blazor and 35 Flutter manual examples compiled/analyzed; theme asset/contrast checks passed.
- Foreground Google Chrome on local Linux iMac, isolated profile/CDP 9341 coordinated with the other task: Fit diagram showed all four sample nodes at 116%; dragging after fitting updated Blazor coordinates to 84.6/197.3 and Flutter to 111/206. Graph coordinates are unchanged by fitting itself.
- 390px web viewport reviewed in both implementations; toolbar wraps and the sample nodes remain visible at reduced zoom. Automated Flutter widget coverage additionally verifies scrolling to a distant node in a 5000×5000 canvas in read-only mode; model tests cover padding, zoom bounds, empty data and invalid viewport sizes.
- Inspected screenshots: [Blazor](screenshots/fit-blazor.png), [Flutter](screenshots/fit-flutter.png), [Blazor narrow](screenshots/fit-blazor-narrow.png), [Flutter narrow](screenshots/fit-flutter-narrow.png).
- Native mobile remains untested. Fit includes node bounds, not overflow from long connection labels; 25% minimum can leave very large graphs partly outside the viewport.

## 0.8 — PDF Viewer (2026-10-18)

- .NET build: zero warnings/errors; 121 rendering/model checks passed. Flutter: web build, 56 tests and analyzer passed. All 36 Blazor + 36 Flutter manual examples compiled/analyzed. Theme/contrast checks passed.
- Original three-page gallery PDF generated with ReportLab; page 2 rendered with Poppler and visually inspected before browser review.
- Normal foreground Chrome on local Linux iMac, isolated profile nextgen-components-review-08 / CDP 9341, coordinated with the other Codex task. Shared browser regression script: scripts/pdf-browser-check.mjs blazor|flutter.
- Both frameworks: three-page load, previous/next and invalid page entry, search across all pages, result navigation and extracted text, clearing search, fit width vs fit page, zoom, original-byte download (SHA-256), malformed file rejection and local File API recovery passed. Local-file automation exercised browser File inputs; the native OS file picker itself was not automated.
- Missing URL and source recovery verified in both galleries; empty source verified in Blazor. Dark mode and 390px web layouts visually inspected in both; no horizontal document overflow in the Flutter iframe.
- Search status was separated from page-render status after a resize-triggered fit obscured the match count during the initial browser run; the final regression passed.
- Screenshots: [Blazor](screenshots/pdf-blazor.png), [Blazor narrow dark](screenshots/pdf-blazor-narrow.png), [Flutter](screenshots/pdf-flutter.png), [Flutter dark](screenshots/pdf-flutter-dark.png), [Flutter narrow](screenshots/pdf-flutter-narrow.png).
- Native platforms display an explicit unsupported placeholder. Screen-reader certification, non-Chrome browsers, CJK/font edge cases, password-protected and very large PDF stress tests remain unverified. Current feature limits are in pdf-viewer.md and the component manual.

## 0.8.1 — PDF text selection and search highlights (2026-10-18)

- .NET and Flutter Web builds passed; 121 Blazor checks, 56 Flutter tests, 6 JavaScript text-search/range tests and all 72 manual examples passed. Shared PDF asset byte equality verified.
- Visible foreground Chrome on local Linux iMac, isolated profile nextgen-components-review-081 / CDP 9341, coordinated with the other task. Final scripts/pdf-browser-check.mjs passed for both framework galleries.
- Browser pointer double-click selected the actual word Approval in the PDF text layer. Search marked exact ranges (two matches on page 2), survived zoom, and cleared after Clear or invalid document replacement. Existing page/search/open/download/error recovery checks passed, including original-byte download SHA-256.
- Inspected [Blazor highlights](screenshots/pdf-text-blazor.png), [Flutter highlights](screenshots/pdf-text-flutter.png), [Blazor narrow dark](screenshots/pdf-text-blazor-narrow.png) and [Flutter narrow](screenshots/pdf-text-flutter-narrow.png). Text layer and highlights align with rasterized glyphs; 390px layouts retain page search without horizontal document overflow.
- Additional PDF fixture generated from the original gallery sample using pypdf: UserUnit=2, page rotations 90 and 270 degrees. Highlight bounds stayed inside the page and screenshots were inspected, including [90-degree rotation](screenshots/pdf-text-rotation.png). Reproduce the fixture with tests/pdf/create_orientation_fixture.py, then open artifacts/browser/pdf-text-rotated.pdf in the viewer.
- Native OS clipboard contents were not read; browser selection was verified. OCR, complex-script/ligature coverage, screen-reader certification, non-Chrome browsers and native mobile support remain outside this verification. CSS Custom Highlight support is required for painted search matches; native text selection remains available without it.

## Map 0.9.0 — 2026-10-18

Local visible Google Chrome on Linux / kolizej-iMac, task profile `/tmp/nextgen-components-review-09`, CDP 9341. Browser slot coordinated with the other Codex session. Blazor `/map` on 5180 and Flutter Web → Map on 5181. Both used the same packaged Leaflet 1.9.4 engine.

Observed on both frameworks: all 3 markers and 2 paths appear over loaded OSM tiles (256 px natural tile width, linked attribution visible); selecting an object updates the parent selected ID; zoom changes update the parent view; theme updates preserve the iframe; no-basemap mode preserves objects; broken local tile URLs show the error while objects remain usable; empty data disables Fit data; reset and Fit data work; actual pointer clicks add a fourth marker through the parent callback. Flutter additionally passed real pointer drag, Enter selection of a focusable SVG path, and Clear selection back to null. Most interaction checks used no basemap to avoid unnecessary requests to the public tile service.

At 390 CSS px, both interfaces fit without horizontal document overflow; object buttons move below the map with their own horizontal scroll. Visual review found the original 110 px object panel caused unnecessary vertical scrolling, corrected to 130 px and verified on both final assets. Dark theme retains unmodified provider imagery. These are narrow Web tests, not native mobile tests.

Screenshots opened and visually inspected: [Blazor with tiles](screenshots/map-blazor-initial.png), [Flutter with tiles](screenshots/map-flutter-light.png), [Blazor narrow](screenshots/map-blazor-narrow.png), [Flutter narrow](screenshots/map-flutter-narrow.png), [Flutter dark / missing tiles](screenshots/map-flutter-dark-error.png). The dark/error Blazor screenshot and action logs are also in ignored `artifacts/browser/map-*`.

Validation: .NET build zero warnings/errors; 131 Blazor rendering/model checks; 60 Flutter tests; library and gallery analysis clean; release Flutter Web build successful; 37 Blazor + 37 Flutter manual examples compiled/analyzed; shared Map/PDF asset equality and shared theme checks passed. Map tests cover finite/projected coordinate bounds, zoom, geometry minimums, copied immutable collections, cross-layer ID collisions, invalid IDs, marker limit, native placeholder and unsafe/missing tile provider configuration. The pre-existing Flutter CupertinoIcons build warning remains; no missing glyphs observed in the exercised map UI.

Limits: no native Flutter validation; no routing/geocoding/clustering; no broad browser/screen-reader certification or provider availability guarantee. See [capabilities](map.md) and [manual](manual/NgMap.md).

## Map marker clustering 0.9.1 — 2026-10-18

Checked in local visible Chrome on Linux / kolizej-iMac, isolated profile `/tmp/nextgen-components-review-091`, CDP 9341, coordinated with the other Codex session. Closed only this test browser and released the slot afterwards.

Both Blazor and Flutter Web: 60 close markers aggregate into a single count-60 group; group activation increases zoom from 13 to 16 and splits it. Selecting a member through Objects displays that marker separately with a count-59 group; Clear selection restores count 60. Dark theme preserves iframe and selection. Disabling clustering restores all 60 individual markers. Three coincident objects at zoom 19 open a member chooser; selecting Office 2 updates the parent's selected ID. Empty data removes all marker and cluster DOM. Checks use no-basemap fixtures to avoid bulk public tile requests.

At 390 px, both iframe documents fit their width. Blazor Enter and Flutter Space open the cluster; Flutter Enter on Office 3 selects its ID. Visual inspection found two defects: cluster keyboard activation was missing, and automatic popup panning triggered a parent View update that closed the chooser. Both fixed and retested: after a 1.2-second settling interval popup opacity remains 1 with all three member buttons. Also checked ordinary marker click with clustering disabled: selection and popup remain visible after the rerender. Browser regression action files are retained under `tests/map/`.

Inspected evidence: [Flutter dense group](screenshots/cluster-flutter-dense.png), [Blazor narrow chooser](screenshots/cluster-blazor-narrow.png), [Flutter narrow chooser](screenshots/cluster-flutter-narrow.png). Additional desktop/chooser snapshots and interaction logs are under ignored `artifacts/browser/cluster-*`.

Automated validation: .NET build zero warnings/errors; 134 Blazor checks; 61 Flutter tests; 4 JS grouping tests (radius boundary/validation, deterministic order, pan invariance, no transitive chaining, zoom split and 500 coincident points); library and gallery analysis clean; 74 manual examples passed. Final Flutter Web build passed and its Map JS matches the shared source byte-for-byte. Shared Map assets and theme checks pass. The existing CupertinoIcons build warning remains unrelated. Native mobile and broader browser/screen-reader verification remain deferred.

## Linux desktop launcher — 2026-10-18

Installed `Nextgen Components` on `/home/kolizej/Desktop/nextgen-components.desktop` and in the user's applications menu. `desktop-file-validate` passed; execute permission and `metadata::trusted=true` confirmed. Default action opens the local portal on 5182; desktop actions target Blazor, Flutter or the manual. The repository installer can recreate these files after moving the checkout.

Stopped only the previously owned gallery processes and verified that the launcher starts fresh Blazor/Flutter user systemd services on 5180/5181. Documentation runs as a third user service on 5182. Repeated home/manual/Blazor/Flutter launches retain all three server PIDs. Manual-only launch does not require or start either demo build. These are on-demand services, not login autostart. Existing builds are reused; source changes require the documented rebuild commands.

The real `.desktop` file was invoked with `gio launch` in a persistent GUI test service, with a temporary PATH wrapper directing Chrome to an isolated visible profile on CDP 9341. This avoids the command runner terminating GUI child processes when its command exits. Verified on local Linux/iMac: portal → manual contents → NgMap, rendered code blocks and API tables, portal/header links → both interactive galleries, and portal layout at 390 px. Screenshots opened and inspected: [portal](screenshots/launcher-home.png), [code examples](screenshots/launcher-code.png); manual/table/narrow captures remain in `artifacts/browser/launcher-*`. Test Chrome and temporary GUI test service were closed; demo/documentation services remain available.

HTTP checks verified HTML code/table rendering, heading anchors, current manual links, and 404 responses for private files and parent traversal. Python syntax checks passed. Component code was unchanged, so the component test suites were not rerun.

## AI interface 0.10.0 — 2026-10-18

Verified in local visible Google Chrome on Linux / kolizej-iMac, isolated profile `/tmp/nextgen-components-review-010`, CDP 9341, after coordinating the slot with the other Codex session. Blazor `/ai` on 5180 and Flutter Web AI interface on 5181 use deterministic local handlers without an AI provider.

Both platforms: initial generation, regenerate, helpful/cleared feedback, simulated error and Retry request, external prompt replacement, cancellation followed by a new successful request, and clipboard content verified through the real browser clipboard. A handler deliberately ignoring cancellation completed late: history remained at 4 responses and OnCompleted at 4 after 6 attempts (one error and one cancellation). Read-only states and light/dark presentation were inspected. Flutter additionally checked read-only history selection, disabled Regenerate, clear history, suggestion filling without automatic submission, and increasing response ID after clear. Standalone PromptBox accepted actual pointer/keyboard multiline input and trimmed submission on both platforms.

At 390 CSS px the composition and response stack vertically; Blazor has no horizontal document overflow, and Flutter response/actions fit within the narrow viewport. These are Web layout checks, not native mobile certification. Inspected screenshots: [Blazor light](screenshots/ai-blazor-light.png), [Blazor narrow dark](screenshots/ai-blazor-narrow-dark.png), [Flutter dark](screenshots/ai-flutter-dark.png), [Flutter narrow response](screenshots/ai-flutter-narrow-response.png). Additional action specifications and captures are in ignored `artifacts/browser/ai-*`. Flutter semantics textarea value is not a reliable unfocused controlled-value assertion; the rendered text and generated/copied response confirmed replacement.

Validation: .NET gallery build with zero warnings/errors, 147 Blazor checks, all 67 Flutter tests, clean library/gallery analysis, 39 Blazor and 39 Flutter manual examples checked, theme checks passed, Flutter release Web build passed. The existing CupertinoIcons font build warning remains; no missing glyphs were observed in the exercised interface. Added regression coverage for initial Blazor prompt binding, UTF-16 limits, duplicate requests, cancellation/disposal, immutable history, response limits, failure recovery and feedback. See [capabilities and omissions](ai-interface.md).

## Stepper/Wizard and English developer hub 0.11.0 — 2026-10-18

Used visible local Chrome on Linux / kolizej-iMac, isolated profile `/tmp/nextgen-components-review-011`, CDP 9341, coordinated with the ReportEngine session. Closed only this test Chrome and released the slot. Gallery/documentation services remain running for the installed launcher.

Both frameworks: empty-name validation blocks Next; real pointer/keyboard entry permits moving from step 1 to step 3 over the disabled step; Back preserves the draft; a simulated asynchronous exception displays a recoverable message; correction allows Review and Finish. Duplicate Finish activation saves once and leaves Completed. Reset during a pending validator leaves step 1 without the old error. Light/dark and horizontal/vertical presentation inspected, including 390 px Web layouts. Flutter's merged parent semantics initially obscured the field/status names; explicit child semantics fixed it and the full scenario was repeated on the rebuilt Web app. Scoped the Blazor gallery header CSS so it does not style the Stepper navigation element.

All component manuals, sample labels, installation guidance, models/formulas and portal text are now English. Both demo code browsers expose all 41 components using identical generated assets from the manual source. Verified framework switching, component selection and actual clipboard content for the initial Blazor and Flutter examples. The documentation portal provides colored workflow cards, Install/Run/Connect steps, searchable component navigation, page contents, language-labeled code blocks and Copy code. Search reduced the navigation to Wizard, the manual copied exact Razor source, and the 390 px page had no horizontal document overflow with collapsed navigation. Code blocks scroll independently. Installed desktop/menu entries were refreshed in English and desktop-file-validate passed.

Screenshots opened and inspected: [developer hub](screenshots/docs-hub-011.png), [manual with code](screenshots/docs-wizard-code-011.png), [narrow manual](screenshots/docs-wizard-narrow-011.png), [Blazor steps](screenshots/steps-blazor-final.png), [Flutter completed workflow](screenshots/steps-flutter-light.png), [Flutter narrow](screenshots/steps-flutter-narrow.png), [Flutter code browser](screenshots/examples-flutter.png). Further actions/captures remain in ignored artifacts/browser.

Validation: .NET gallery build zero warnings/errors; 158 Blazor rendering/model checks; all 73 Flutter tests (and the 6 step-specific tests repeated after the semantics change); clean library/gallery analysis; 41 Blazor and 41 Flutter manual examples compiled/analyzed. Final Flutter Web build passed; the existing CupertinoIcons build warning remains. Shared theme checks, documentation language scan, manual relative-link checks, generated code-asset equality and Python syntax checks passed. The JSON capability catalogue now agrees with the Markdown statuses, including the earlier AI controls. Native/mobile verification remains deferred.

## Menu and Drawer 0.12.0 — 2026-10-18

Used visible local Chrome on Linux / kolizej-iMac, isolated profile `/tmp/nextgen-components-review-012`, CDP 9341, coordinated with the other Codex session. Closed only our browser and released the slot; local demo/documentation services remain running.

Blazor: keyboard opened Workspace → Export → PDF, focus moved into each level, a single leaf invocation closed both popovers and restored the root opener. Drawer selected Reports, closed after selection, and Escape restored the opening button. Push mode preserved an entered draft. Dark desktop and 390 px stacked Push layout inspected; no horizontal page overflow. Flutter: nested Export opened by keyboard and PDF selection invoked once; Drawer selection, Escape, Push and retained draft verified. Light and dark desktop layouts inspected. Flutter was reloaded under the 390 px viewport before narrow gallery and modal checks; resizing its existing canvas through CDP alone produced a scaled stale surface, so that initial capture was discarded. Unfocused semantics inputs can be empty: the rendered note and application status confirmed retained state.

The English manual now covers 43 components with 86 compiling/analyzed examples. Inspected the Drawer manual's navigation, content hierarchy and language-labeled code sections. The Blazor code browser lists 43 entries and loads the new Menu snippet; both generated snippet assets are identical. Existing clipboard functionality was unchanged.

Validation: .NET gallery build zero warnings/errors; 168 Blazor model/render checks; all 76 Flutter tests; library and gallery analysis clean; 43 Blazor and 43 Flutter manual examples passed. Flutter Web release build and shared theme checks passed. Tests cover menu limits/duplicate IDs/disabled ancestors, leaf invocation, Drawer selection/Escape/backdrop/Push and disposal without removing an unrelated Navigator route. The existing CupertinoIcons build warning remains. Native mobile and broader browser/screen-reader checks remain deferred.

Inspected evidence: [Blazor nested menu](screenshots/navigation-blazor-menu.png), [Blazor dark Push](screenshots/navigation-blazor-dark-push.png), [Flutter dark Push](screenshots/navigation-flutter-dark-push.png), [Flutter narrow overlay](screenshots/navigation-flutter-narrow-drawer.png), [English manual](screenshots/navigation-manual.png). See [scope and omissions](navigation.md).

### Syntax highlighting follow-up

Added the requested syntax colors to both demo code browsers and the rendered manual, using a shared lossless tokenizer for Razor/C#, Dart and fenced web/shell/JSON examples. Unknown languages stay plain. Token text is escaped in HTML and is rendered as selectable TextSpans in Flutter; copy actions continue to use the unmodified source. No external CDN or runtime package is needed. All 86 examples round-trip exactly through highlighting; malicious HTML stays escaped. Every syntax color exceeds 7.4:1 contrast on the code background.

Rebuilt Blazor and Flutter Web and rechecked the 86 manual examples. Python tokenizer/asset checks and Dart analysis passed. In a second coordinated visible Chrome run, inspected [Blazor colors](screenshots/syntax-blazor.png), [Flutter colors](screenshots/syntax-flutter.png) and [manual colors](screenshots/syntax-manual.png). Actual clipboard text matched source exactly in all three surfaces. Manual copy was retried after smooth scrolling settled and browser clipboard focus was enabled. Closed the task browser and released the slot.

## ToggleButton and ButtonGroup 0.13.0 — 2026-10-18

Verified in visible local Chrome on Linux / kolizej-iMac with isolated profile `/tmp/nextgen-components-review-013`, CDP 9341, coordinating each GUI slot with the other Codex session. Blazor `/selection` and Flutter **Toggle buttons** demonstrate a border toggle, exclusive text alignment, multiple styles and external reset.

Both platforms passed pointer selection, repeated Space toggling with retained focus, last-choice protection without extra callbacks, multi-selection, disabled controls, reset while disabled, optional clearing and empty options. Light/dark desktop presentation and 390 px Web layouts inspected. Flutter narrow rendering was checked after reload at that viewport. Blazor vertical groups fit without horizontal document overflow; Flutter horizontal groups wrap onto extra lines.

Testing caught Flutter focus loss when replacing an outlined button with a filled button: the toggle now retains one OutlinedButton and changes only its style. Browser inspection also caught duplicate switch/button semantics; MergeSemantics now exposes one checked, enabled/disabled action with its label. Added a regression assertion for that merged node, along with repeated keyboard activation. The final browser run confirmed one accessible element and correct event counts.

Validation: .NET gallery build zero warnings/errors, 181 Blazor rendering/rule checks, all 79 Flutter tests before the semantics adjustment and all 3 selection tests repeated after it, clean library/gallery analysis, 45 Blazor and 45 Flutter manual examples compiled/analyzed. Both generated example assets and all 90 highlighted-source round trips passed. Flutter Web build and shared theme checks passed; the existing CupertinoIcons font warning remains. Manual syntax highlighting and the 45-entry Blazor code browser were verified. Native mobile and broader screen-reader certification remain deferred.

Inspected evidence: [Blazor selection](screenshots/selection-blazor-light.png), [Blazor narrow vertical groups](screenshots/selection-blazor-narrow.png), [Flutter dark selection](screenshots/selection-flutter-dark.png), [Flutter narrow wrapping](screenshots/selection-flutter-narrow.png). See [capabilities and reference audit](selection.md).

### Categorized manual tree

Replaced the flat left-hand component list with a two-level disclosure tree derived from the catalogue: 45 distinct component pages under 11 categories. Chart variants are deduplicated into their single NgChart manual. Folder markers, branch guides, counts and the highlighted current page make the hierarchy visible. The current category opens automatically; other categories can be expanded with pointer or keyboard. Search accepts a component or category name, opens matching branches, reports no results and restores the previous branch expansion when cleared.

Verified in a separately coordinated visible Chrome run: initial counts/current branch, category expansion, Left-arrow collapse, Chart-only search, all 15 Editors matches, no-results state, clearing/restoring branches and navigation to NgMenu. At 390 px the navigation starts collapsed, can be opened and scrolls internally without document overflow. Python syntax and rendered-tree counts passed. Inspected [desktop tree](screenshots/manual-tree-desktop.png) and [narrow tree](screenshots/manual-tree-narrow.png). The task Chrome window was closed and the GUI slot released.

## 0.14 — Chip and ChipList (2026-10-18)

- Blazor gallery build: zero warnings/errors; 186 rendering/rule checks passed, including enabled removal and escaped labels.
- Flutter: final full suite passed, 82 tests including three new Chip/ChipList tests. Tests cover controlled multi-selection, removal rejection/acceptance, atomic selected-ID cleanup, disabled actions, nonselectable removal, empty lists and consecutive keyboard Space toggles.
- Both package/gallery analyzers clean; package analyzer repeated after the static-chip presentation fix. Final Flutter Web build passed after that fix. Existing CupertinoIcons font warning remains unrelated to these components.
- All 47 Razor and 47 Dart manual examples compile/analyze. All 94 highlighted snippets round-trip exactly; shared theme checks passed.
- Visible foreground Chrome on local Linux/iMac, task profile/CDP 9341, coordinated with the other thread: both platforms passed multi/single selection, protected removal rejection, accepted removal, disabled controls, external reset, and click then Space toggling with preserved focus. Screenshots inspected in light/dark and 390px layouts. Blazor native disabled-attribute bug and a missing gallery ValueExpression were found during this run and fixed before the successful repeat.
- Manual tree contains 47 component entries; NgChipList is current inside Navigation. Code tokens render with syntax highlighting. No mobile-platform or screen-reader certification is claimed. Flutter's native Chip semantics expose a checked state even for a noninteractive static chip; specialized static semantics and focus transfer after removal remain follow-up accessibility work.
- Evidence: [Blazor](screenshots/chips-blazor-light.png), [Blazor narrow](screenshots/chips-blazor-narrow.png), [Flutter](screenshots/chips-flutter-light.png), [Flutter narrow](screenshots/chips-flutter-narrow.png), [manual tree](screenshots/chips-manual.png).

## 0.15 — Feature audit and chip presentation (2026-10-18)

- The new [parity matrix](parity.md) separates availability, complete-reference audit, verification and remaining differences for all 139 catalogue entries. Chip/ChipList has a 22-row detailed matrix; no complete-parity verdict is assigned.
- Blazor gallery build: no warnings/errors; 193 rendering/rule checks passed. Chip validation accepts all 120 appearance combinations and rejects unknown values; rendered templates retain accessible labels, custom remove content and conditional removal.
- Flutter full suite: 85 tests passed. New tests cover all appearance values, invalid values, custom accessible names, selection-before-click ordering, removal isolation, command-only activation, conditional removal and per-item size overrides. Both analyzers clean; Web build succeeded (existing CupertinoIcons warning unchanged).
- All 47 Razor and 47 Dart manual examples compile/analyze; 94 highlighted examples preserve raw source. Semantic palettes match CSS/Dart and enabled foreground/background contrast ranges from 6.67:1 to 8.47:1. This is a palette check, not a WCAG certification.
- Visible local Chrome on Linux/iMac, coordinated CDP9341: both galleries exercised custom templates, lg/sm corner/solid settings, all five visible semantic colors, selection and independent click, command-only activation and nonremovable Flutter item. Light/dark screenshots inspected; 390px wrapping inspected. Flutter static Published label no longer exposes a checkbox. Manual parity link and 139 inventory rows verified.
- Evidence: [Blazor presentation](screenshots/chips015-blazor-light.png), [Blazor dark](screenshots/chips015-blazor-dark.png), [Blazor narrow](screenshots/chips015-blazor-narrow.png), [Flutter presentation](screenshots/chips015-flutter-light.png), [Flutter dark](screenshots/chips015-flutter-dark.png), [Flutter narrow](screenshots/chips015-flutter-narrow.png), [parity matrix](screenshots/chips015-parity.png).
- Still incomplete: reference listbox semantics, arrow/delete keyboard navigation, focus transfer, generic field binding, arbitrary collection size, public accessibility hooks, localization/RTL and screen-reader verification. Command-only Flutter chips still inherit native checked-state semantics; this is part of the remaining accessibility audit. New component names are paused while the current group is completed.

## 0.16 — Chip keyboard navigation and focus (2026-10-18)

- Blazor build succeeded without warnings/errors; 193 rendering/rule checks passed. Flutter final full suite: 89 tests passed. Package analyzer clean; 47 Razor and 47 Dart manual examples compile/analyze. Highlighting and chip palette checks passed. Flutter Web build succeeded with the existing CupertinoIcons warning.
- Added widget tests for semantic activation without pointer-down, arrows/Home/End (including RTL), disabled-neighbor skipping, accepted removal next/previous/container focus, rejected removal, and external focus preservation during delayed parent updates. Focus nodes are keyed by item ID and retired/disposed with their items.
- Visible Chrome on local Linux/iMac, CDP9341 after coordinating the GUI slot: both galleries passed click → arrow → Space → Delete, rejected Backspace, nonremovable chips, Home/End and skipping disabled items. Blazor FocusAsync and all-disabled container fallback passed. Flutter command-only Open activity now exposes a button rather than checkbox; full listbox semantics remain pending.
- The browser caught a Flutter Web-specific problem: semantic click invoked selection without raw pointer-down, leaving the wrapper unfocused. Focus is now explicitly established by activation/removal callbacks; the final visible Chrome repeat and a regression test passed.
- Blazor JS focus module edge cases (next enabled neighbor, no-target container, outside focus, RTL, disposal) were checked in the real browser with a temporary DOM fixture. Reproduce with `node scripts/chrome-review.mjs scripts/chips-focus-checks.json` while a coordinated visible CDP9341 tab is on the Blazor origin. The fixture removes itself afterward.
- Screenshots inspected: [Blazor focus](screenshots/chips016-blazor-focus.png), [Flutter focus](screenshots/chips016-flutter-focus.png), [Flutter dark focus](screenshots/chips016-flutter-dark-focus.png), [Flutter 390px focus](screenshots/chips016-flutter-narrow-focus.png).
- Still pending: one-tab-stop listbox/option semantics, public Flutter focus controller, screen-reader certification and the other binding/localization gaps in the matrix. Flutter async removal is application-owned; Blazor guards pending remove callbacks. Standalone chip removal requires application-owned focus transfer.


## 0.17.0 — ChipList single Tab entry (2026-10-18)

Both Web platforms now keep one remembered keyboard entry per list. Initial entry prefers an enabled selected item. Tab exits forward, Shift+Tab exits backward and returns to the remembered chip. Arrow navigation does not select. Flutter's internal focus scope explicitly passes traversal to its parent, fixing the closed-loop Tab trap found by the new regression test.

Validation: 193 Blazor rendering/rule checks, 90 Flutter tests, library analyzer, 47 Blazor + 47 Flutter compiled/analyzed manual examples, 94 lossless highlighted snippets and palette checks passed. Blazor build has no warnings/errors. Flutter Web build passed with the existing CupertinoIcons font warning.

Visible foreground Chrome on local Linux/iMac, coordinated separate profile/CDP 9341: both real galleries passed ArrowRight → Tab exit → Shift+Tab remembered reentry → Shift+Tab exit → Tab reentry → Delete with focus recovery. Final English help and focus indicators inspected in screenshots: [Blazor](screenshots/chips017-blazor-tab.png), [Flutter](screenshots/chips017-flutter-tab.png). Reproducible CDP actions: `scripts/chips-tab-blazor-checks.json` (opens /chips), `scripts/chips-tab-flutter-checks.json` (run after opening Chips and tags and enabling Flutter semantics). `scripts/chips-focus-checks.json` also passed selected initial entry, roving entry, disabled skipping, empty fallback, outside-focus protection and RTL. Review Chrome closed and GUI slot released.

Scope limitation: one keyboard Tab entry does not mean one accessibility-tree node. Blazor remains a group of native buttons; Flutter retains native chip/checkbox and remove actions. The installed Flutter SemanticsRole enum lacks listbox/option roles. Full listbox semantics and screen-reader certification remain open; no complete Telerik accessibility parity is claimed. Mobile platforms were not tested.


## 0.18.0 — Application focus and configurable chip labels (2026-10-18)

Added NgChipListController for Flutter: focus the first enabled action or a stable item ID, report unavailable targets, detach when the list disappears/controller changes, reject sharing and disposed reuse. No focus request selects or clicks an item. Both implementations accept custom complete removal labels and empty-list text. Defaults remain English. Applications own translations and locale changes.

Validation: 196 Blazor rendering/rule checks; all 93 Flutter tests; 47 compiled Blazor and 47 analyzed Flutter manual examples; lossless highlighting for 94 snippets; palette checks; clean library analyzer and successful Web builds. Flutter build retains the known CupertinoIcons font warning. Controller lifecycle tests include detached/disposed handles, replacement, unknown/disabled IDs, empty fallback and shared-owner rejection; label tests include runtime replacement, rejected deletion, escaping and blank-value rejection (Flutter).

Visible foreground Chrome on local Linux/iMac, separate coordinated profile/CDP 9341: both demos passed custom/default label switching, application focus, clearing/restoring topics and custom empty text. Flutter additionally passed ArrowRight/Delete with focus recovery after programmatic entry. During review an invisible empty-list focus state was found and fixed with a themed outline; all 14 chip tests, analyzer, Web build and the visible Flutter scenarios passed again after that change. No extra Tab stop was introduced. Manual sidebar and syntax-highlighted controller/disposal example were inspected. Chrome closed and GUI slot released.

Evidence: [Blazor](screenshots/chips018-blazor-focus.png), [Flutter](screenshots/chips018-flutter-focus.png), [Flutter empty focus](screenshots/chips018-flutter-empty.png), [manual example](screenshots/chips018-manual.png). Repeat with `scripts/chips-labels-blazor-checks.json` on a fresh /chips page, or `scripts/chips-labels-flutter-checks.json` after opening Chips and tags with Flutter semantics enabled; run via `scripts/chrome-review.mjs` against a visible, coordinated Chrome on port 9341.

Remaining: listbox/option semantics, generic model binding, collection-size limits, broader public accessibility hooks, full RTL layout and screen-reader validation. This release does not establish complete Telerik parity or native mobile support.


## 0.19.0 — Larger ChipList collections and documentation refresh (2026-10-18)

ChipList no longer uses the shared 50-option guard. Both implementations use set-based validation of IDs/selection; the Blazor rendering pass also caches selected membership, and Flutter uses sets for selected membership and retired focus-node detection. ButtonGroup's 50-item and Drawer's 100-item limits remain unchanged. Flutter reveals focused items in scrollable ancestors without scrolling an already visible chip unnecessarily.

Validation: 201 Blazor checks and 95 Flutter tests passed, including 500-item rendering, disabled final items, End/Home, selection and removal recovery. Flutter data rules were also exercised with 5,000 items and invalid/duplicate IDs. Library analyzer and both Web builds passed; the existing Flutter CupertinoIcons warning remains. All 47 Blazor + 47 Flutter manual examples compile/analyze and 94 highlighted snippets are lossless.

Visible Chrome on local Linux/iMac: both galleries loaded 500 tags, focused Topic 499 with End (500 is disabled), selected it with Space, deleted it and focused Topic 498, then returned to visible Topic 001 with Home. See [Blazor](screenshots/chips019-blazor-end.png) and [Flutter](screenshots/chips019-flutter-end.png). Replay `scripts/chips-large-blazor-checks.json` from /chips and `scripts/chips-large-flutter-checks.json` from Chips and tags with semantics enabled.

Documentation was restyled at the user's request: component cover cards, platform badges, numbered section cards, softer navigation, updated API tables and code toolbars. Wrap lines preserves source content and has an explicit pressed state. Copy code, component search, heading links, normal desktop and 390px layouts were checked in visible Chrome; NgChipList and NgDataGrid pages were exercised. The English text, category tree and syntax highlighting remain. Screenshots: [desktop](screenshots/manual019-desktop.png), [wrapped code](screenshots/manual019-wrapped.png), [narrow layout](screenshots/manual019-narrow.png). Repeat `scripts/documentation-design-checks.json` via the CDP review helper. Styling is maintained in `scripts/documentation.css`.

This is eager rendering, not virtualization or a performance guarantee for arbitrary collection sizes. Full listbox/option semantics, generic model binding, remaining accessibility hooks and screen-reader validation remain open. Native mobile is not part of this verification.

## 0.20.0 — Typed ChipList application models (2026-10-18)

NgChipData<T> now snapshots typed selectors for stable IDs, text, disabled/removable state and appearance on both platforms. Original records remain available by ID. Construction rejects invalid mappings; rebuilding refreshes changed fields. This is an alternative typed binding contract, not Telerik string property-name reflection.

Validation: 210 Blazor rendering/rule checks, 97 Flutter tests, library/gallery Dart analysis, both Web builds and all 47 + 47 manual examples passed. All 94 highlighted snippets remain lossless. Flutter retains the pre-existing CupertinoIcons font warning.

Visible foreground Chrome on local Linux/iMac verified both Business records examples: Finance is pinned, Archive disabled, clicking Operations resolves owner Morgan, rename and reverse preserve selection, and removal resolves the renamed original record while updating selection. Replay scripts/chips-model-blazor-checks.json from a fresh /chips page and scripts/chips-model-flutter-checks.json from a fresh Chips and tags page with semantics enabled. The Flutter removal selector explicitly targets the nested button rather than its parent checkbox. Screenshots: [Blazor](screenshots/chips020-blazor.png), [Flutter](screenshots/chips020-flutter.png).

The updated manual was checked at desktop and 390px widths, including Copy code, Wrap lines, tree search and heading links. See [highlighted model example](screenshots/manual020-wrapped.png). Remaining gaps include listbox/option semantics, broader accessibility hooks, full RTL layout and screen-reader validation. Native mobile verification remains deferred.

## 0.21.0 — Chip/ChipList bidirectional layout (2026-10-18)

The Blazor removal separator now uses border-inline-start so it stays between text and removal in RTL as well as LTR. Chip/ChipList inherit direction from HTML dir or Flutter Directionality; no data reversal or global switch is required. The Reading direction example on both platforms demonstrates a constrained wrapping region, leading decoration, a disabled item, a static chip and runtime switching. Demo and manual remain English.

Validation: both Web builds, 210 Blazor checks, 98 Flutter tests, Dart analysis of the gallery/new test, all 47 + 47 manual examples and 94 lossless highlighted snippets passed. The new Flutter regression checks mirrored content and wrapped rows, direction changes while an item has focus, selection retention, disabled-item skipping and removal recovery. The pre-existing Flutter CupertinoIcons warning remains.

Visible Chrome on local Linux/iMac checked RTL/LTR positions, the Blazor divider edge, preserved selection/remembered Tab entry, Left/Right navigation, End/Delete and previous-item focus recovery. Narrow wrapping was checked in a 250px Blazor region and a 390px Flutter viewport. Flutter was reloaded at the narrow viewport size before the final screenshot to synchronize canvas rendering with the emulated device metrics. Screenshots: [Blazor RTL](screenshots/chips021-blazor-rtl.png), [Flutter RTL](screenshots/chips021-flutter-rtl.png), [Flutter narrow](screenshots/chips021-flutter-narrow.png). Replay scripts/chips-direction-blazor-checks.json from /chips and scripts/chips-direction-flutter-checks.json from a fresh Chips and tags page with semantics enabled. The English manual's highlighted Directionality example was also inspected in Chrome.

This completes the scoped Chip/ChipList layout check, not suite-wide RTL, translation dictionaries, screen-reader pronunciation or native mobile validation. Public accessibility hooks and listbox/option semantics remain open. Reference behavior: [Telerik RTL support](https://www.telerik.com/blazor-ui/documentation/globalization/rtl-support).

## 0.22.0 — Chip/ChipList identity and accessibility hooks (2026-10-18)

Blazor exposes Id/Class on the outer element and AriaLabelledBy/AriaDescribedBy on the list group or standalone label action. Removal retains its independent name and receives the standalone description. A static chip with references uses a noninteractive group as its semantic target. Flutter exposes semanticIdentifier/semanticHint without replacing existing actions; shared heading text is supplied through the existing label parameter. These are platform-specific contracts, not identical DOM APIs.

Validation: 216 Blazor rendering/rule checks, 101 Flutter tests, both Web builds, Dart analysis and 47 + 47 compiled/analyzed manual examples passed. All 94 highlighted examples remain lossless. Tests cover invalid metadata, runtime changes, preserved selection and separate removal callbacks. The existing Flutter CupertinoIcons font warning remains.

Visible Chrome on local Linux/iMac verified both Business records examples, dynamic heading/help updates, unchanged identity/selection, and the Open activity command description. CDP Accessibility.getFullAXTree confirmed the group name `Assigned business records`, description `Choose assigned topics for this workspace.`, the selected Operations action and separate Remove Operations button. The static Blazor Published group exposes its description without becoming focusable. [Blazor screenshot](screenshots/chips022-blazor.png), [Flutter screenshot](screenshots/chips022-flutter.png).

Replay the corresponding scripts/chips-accessibility-blazor-checks.json or scripts/chips-accessibility-flutter-checks.json from a fresh Chips page (enable Flutter semantics), then run scripts/chips-accessibility-tree-check.mjs. The checker saves compact evidence under artifacts/browser. The English manual section and code highlighting were inspected visually.

Browser accessibility-tree inspection is not screen-reader certification. Configurable TabIndex, listbox/option semantics and ChipList Gap remain open; the latter was identified during this public API review. Native mobile validation remains deferred.

## 0.23.0 — Chip traversal participation and ChipList spacing (2026-10-18)

Chip and ChipList accept TabIndex/tabIndex 0 (default) or -1; other values are rejected. A skipped list retains pointer interaction, application focus, arrow navigation and selection. Restoring 0 restores the remembered enabled entry. Blazor synchronizes the roving entry when the data-chip-tab-index attribute changes. Flutter skips the list scope as well as its item nodes; empty/all-disabled scopes also stay out of Tab traversal. Standalone Chip excludes both action and removal from traversal without disabling them.

Gap/gap presets sm/md/lg map to 4/8/12 CSS or logical pixels for both horizontal and wrapped-row spacing. Default md preserves existing spacing. These are original design tokens; positive TabIndex ordering and exact Telerik theme pixels are not supported by this contract. The list-level traversal setting is a Nextgen extension; the reference integer TabIndex belongs to Telerik Chip.

Validation: 222 Blazor checks, 105 Flutter tests, both Web builds, Dart analysis and 47 + 47 manual examples passed. All 94 highlighted snippets remain lossless. The traversal regression caught and resolved scope participation when skipping a Flutter list and restoring it at runtime. It also covers programmatic focus, disabled neighbors, empty/all-disabled lists, standalone pointer/removal behavior and spacing changes without selection loss. Flutter retains its existing CupertinoIcons font warning.

Visible Chrome on local Linux/iMac verified forward/reverse Tab skipping, explicit focus into a skipped list, keyboard selection and restored remembered entry on both platforms. Blazor computed row/column gaps changed from 4 to 12px; Flutter geometry increased by 4 logical pixels when selecting lg from md. Both retained selection. Screenshots: [Blazor](screenshots/chips023-blazor.png), [Flutter](screenshots/chips023-flutter.png). Replay scripts/chips-traversal-blazor-checks.json from /chips or scripts/chips-traversal-flutter-checks.json from a fresh Chips and tags page with Flutter semantics enabled. The Flutter scenario was replayed end to end after aligning the focus assertion with its containing semantics node and selecting the visible dropdown menu item. The English manual's traversal and spacing sections were inspected in Chrome.

Remaining: listbox/option semantics, broader traversal/API compatibility and screen-reader validation. Web-only evidence does not establish native mobile support or complete Telerik parity.

## 0.24 — Blazor selection-only ChipList semantics

- 226 Blazor rendering/rule checks passed; gallery build: no warnings/errors. New assertions cover listbox/options, selected state, multiple-selection metadata and removable/selection-disabled group fallback.
- 105 Flutter tests passed. Flutter implementation is unchanged; package/demo release metadata and Web build were updated. Existing CupertinoIcons font warning remains.
- All 47 Blazor and 47 Flutter manual examples compile/analyze; 94 highlighted examples retain their exact source. The Blazor example now includes a selection-only list bound to the same model state.
- Visible foreground Chrome on local Linux/iMac, separate review-024 profile, CDP 9341: initial Tab entry on the selected option, disabled-item skip, focus distinct from selection, Space multiple selection, runtime group/listbox switching without losing selection or focus, single-mode normalization, End/Enter selection and Home navigation passed. Replay: `scripts/chips-selection-blazor-checks.json` (starts from a fresh page). Native Enter dispatch includes the carriage-return character; an initial incomplete CDP event did not activate the button.
- `scripts/chips-selection-tree-check.mjs` verified Chrome's actual accessibility tree: named horizontal listbox, selected Documentation option, disabled Locked option and single-select metadata. This is not screen-reader certification.
- Inspected screenshots of Blazor, Flutter Web and the English manual with highlighted code and left navigation: `screenshots/chips024-blazor.png`, `screenshots/chips024-flutter.png`, `screenshots/chips024-manual.png`.
- Remaining: removable-list listbox semantics, Flutter listbox/option roles, type-ahead/range selection and screen-reader verification. Mobile remains deferred. W3C listbox guidance does not support interactive controls inside options; removable lists deliberately retain separate accessible buttons.

## 0.25 — Independent accessible names for standalone Chip

- 229 Blazor rendering/rule checks passed; gallery build completed without warnings/errors. New coverage verifies independent main names, unchanged removal names, static named groups and rejection of blank overrides.
- 108 Flutter tests passed; Dart analysis is clean. Added checks for runtime name updates with controlled selection, fallback to the visible label, separate removal, static/command/disabled states and blank-name rejection.
- All 47 Blazor and 47 Flutter manual examples compile/analyze. All 94 code examples retain lossless syntax highlighting. Both gallery builds succeeded; Flutter's pre-existing CupertinoIcons font warning remains.
- Visible foreground Chrome on local Linux/iMac, separate review-025 profile, CDP 9341: `scripts/chips-name-check.mjs blazor` and `flutter` use real pointer interactions and inspect the actual accessibility tree. Each verifies the original full name, selected state, then the updated full name with selection retained. The visible CI abbreviation stays unchanged. Flutter exports checkbox/checked; Blazor exports button/pressed.
- Visually inspected both demos and the English manual with highlighted examples and tree navigation. Evidence: `screenshots/chips025-blazor.png`, `screenshots/chips025-flutter.png`, `screenshots/chips025-manual.png`.
- This is the standalone AriaLabel/semanticLabel contract; ChipList item labels, listbox limitations, mobile deferral and lack of screen-reader certification remain as documented in the parity matrix.

## 0.26 — ToggleButton and ButtonGroup component block

This delivery groups commands/selection, events, visibility, templates/icons, appearance, accessibility hooks and their complete manuals in one release. It does not declare full Telerik parity; the paired-component audit and remaining API differences are in `parity.md`.

- 235 Blazor rendering/rule checks passed. Gallery build: no warnings/errors. Added coverage for command versus toggle markup, display templates, metadata/traversal settings, hidden actions, invalid appearance and selected-command rejection.
- 113 Flutter tests passed. After improving selected-state visibility for custom bold content and disabled backgrounds, the 8 focused selection/button-contract tests passed again. Dart analysis is clean.
- 47 Blazor and 47 Flutter manual examples compile/analyze; all 94 examples retain lossless highlighting. Both gallery builds pass. Flutter's existing CupertinoIcons font warning remains.
- Visible foreground Chrome on local Linux/iMac, dedicated review-026 profile/CDP 9341: `scripts/selection-block-check.mjs blazor|flutter` checks initial selection, command semantics without pressed/checked state, selection-before-click ordering, hiding/restoring selected records, application-owned Clear formatting, Space activation, disabled semantics and vertical layout.
- `scripts/selection-appearance-blazor-checks.json` exercises size/corner/fill/color changes and dark mode, then 390 px wrapping without horizontal overflow. Computed CSS contrast across 220 enabled combinations (11 colors × 5 fills × 2 selected states × 2 themes) has a minimum of 5.17:1. Flutter's style test checks the same 220 combinations at >=4.5:1; these focused contrast checks are not WCAG or screen-reader certification.
- `scripts/selection-appearance-flutter-check.mjs` uses actual dropdown pointer actions to select lg/full/solid/tertiary, switches dark mode, then reloads at 390×844 to verify the Flutter canvas layout. Visual inspection identified and resolved insufficient selected-state distinction with custom bold content: Flutter now adds a decorative check mark; Blazor uses an inset selected outline. Disabled Flutter backgrounds use a neutral surface.
- Inspected demo screenshots in dark and narrow layouts and the rewritten English manual with highlighted examples and left tree navigation. Evidence: `screenshots/selection026-blazor-dark.png`, `screenshots/selection026-blazor-narrow.png`, `screenshots/selection026-flutter-dark.png`, `screenshots/selection026-flutter-narrow.png`, `screenshots/selection026-manual.png`.
- Existing boundaries remain explicit: data-driven NgOption callbacks differ from Telerik child-button APIs; 50 records, TabIndex -1/0, application-owned focus after hiding, no native submit/reset button types, no dedicated width API or ThemeBuilder compatibility. Mobile and real screen-reader validation remain separate work.

## Live component manuals (2026-10-19)

All 47 component manuals now embed a runnable appearance example with Blazor / Flutter Web switching, Reload example and a full-page link. The 94 preview components are generated from the same curated snippets displayed in the manual. New component documentation therefore creates both previews automatically; missing curated manuals still fail generation. Static Markdown readers receive direct local preview links. Both demo services must be running.

- Blazor gallery build passed with zero warnings/errors; Dart analysis of both preview integration files passed. Flutter Web release build passed (the existing CupertinoIcons font-family warning remains).
- All 94 snippets were checked against their generated preview sources. All 94 syntax-highlighted examples passed lossless highlighting checks.
- A coordinated visible Chrome session on Linux/iMac loaded all 47 Blazor and 47 Flutter previews at 1000 × 800. No captured runtime exceptions, console errors or Blazor error panels. Screenshots of every preview were reviewed; raw diagnostics/screenshots remain in ignored `artifacts/browser/manual-blazor` and `manual-flutter`.
- `scripts/manual-preview-interaction.mjs` exercised pointer clicks inside both embedded frameworks, the framework selector, Reload example resetting Blazor state, Blazor dialog and drawer opening, and the manual at 390 px with no horizontal document overflow. This is preview integration coverage, not an exhaustive interaction audit of every component.
- Fixed Blazor's default cross-origin framing restriction only on `/preview/*`: framing is allowed from self and the documentation origin `http://127.0.0.1:5182`. Verified `/selection` retains its original CSP and SAMEORIGIN headers.
- Visual evidence: [Blazor preview](screenshots/manual-live-blazor.png), [Flutter preview](screenshots/manual-live-flutter.png), [open dialog](screenshots/manual-live-dialog.png), [narrow manual](screenshots/manual-live-narrow.png).

This documentation work does not change the component library API or claim additional Telerik parity. The next planned component block remains Menu and Drawer.

## Menu and Drawer component block (0.27, 2026-10-19)

Original Menu and Drawer implementations were expanded together on both Web platforms. Menu adds immutable visibility/separator flags, decorative-leading and item templates, CloseOnClick and RTL. Drawer adds item/leading/header/footer templates, visibility/separator predicates, logical start/end placement, RTL, CloseOnSelect and global disabled behavior. Missing callbacks disable otherwise inactive destinations; disabling an open drawer does not remove dismissal. Accessible names continue to come from model labels.

- **242 Blazor rendering/data checks passed**. New cases cover hidden ancestor invocation, separator contracts, label/position validation and template/RTL markup.
- **117 Flutter tests passed**, including all prior tests and four new navigation contract/widget cases. Tested keep-open commands, hidden items, custom accessible labels, divider rendering, end-position RTL mirroring, overlay selection without closing, disabled selection with dismissal and missing callbacks.
- Blazor gallery build passed with zero warnings/errors. Flutter Web release build and Dart analysis passed; the existing CupertinoIcons build warning remains. **47 Blazor + 47 Flutter manual examples** compile/analyze; **94 highlighting checks** pass.
- Coordinated visible Chrome review on local Linux/iMac used a dedicated profile and CDP9341. `scripts/navigation-block-check.mjs blazor|flutter` passed nested repeated commands, hidden items, templates, retained Drawer selection, Escape, end position in LTR/RTL, dark theme, Push layout and a 390 px gallery with no horizontal document overflow. Blazor RTL arrow traversal skipped disabled siblings; Flutter nested submenu was opened using native pointer hover (clicking an already-hover-open submenu can toggle it closed) and keyboard opening was inspected separately.
- Updated live manual previews for Menu/Drawer loaded on both platforms without captured runtime errors. The manual integration check also exercised the new Drawer preview in its embedded frame.
- Screenshots: [Blazor menu](screenshots/navigation027-blazor-menu.png), [Blazor RTL drawer](screenshots/navigation027-blazor-rtl-dark.png), [Blazor narrow](screenshots/navigation027-blazor-narrow.png), [Flutter menu](screenshots/navigation027-flutter-menu.png), [Flutter RTL drawer](screenshots/navigation027-flutter-rtl-dark.png), [Flutter narrow](screenshots/navigation027-flutter-narrow.png), [manual appearance](screenshots/navigation027-manual.png).

No full Telerik parity or screen-reader/native-mobile certification is claimed. Mini mode, arbitrary model mapping, automatic URL handling, full drawer-template replacement and configurable popup timing/animation remain recorded gaps. The next paired implementation block is Stepper/Wizard.

## Stepper and Wizard component block (0.28, 2026-10-19)

Both Web implementations add indicator/label templates, three display modes, RTL, four Wizard stepper positions, custom action contexts and captions, asynchronous cancellable transition guards and same-step ResetKey. Remaining Telerik coverage is recorded in the parity matrix.

- **247 Blazor rendering/data checks** and **123 Flutter tests** passed. New widget tests cover cancellation, guard/validation ordering, duplicate actions, stale pending results, reset after completion, missing callbacks and logical layout positions.
- Blazor gallery build passed with zero warnings/errors. Flutter Web release build and Dart analysis passed; the existing CupertinoIcons font-family warning remains. **47 Blazor + 47 Flutter manual examples** compile/analyze; **94 lossless highlighting checks** pass.
- Coordinated foreground Chrome on local Linux/iMac: `scripts/steps-block-check.mjs blazor|flutter` passed blocked transitions, required-name validation, reset during an asynchronous check at the same step, custom Previous/Continue/Submit actions, disabled-step skipping, backward navigation, successful completion, RTL/dark and 390 px layouts.
- `scripts/steps-layout-check.mjs blazor|flutter` passed logical end placement with RTL, indicator-only accessible names and narrow custom actions. Screenshot inspection caught collapsed Blazor indicator-only buttons; explicit intrinsic sizing fixed the overlap and the regression check passed. The Blazor demo guard status now renders immediately on cancellation.
- The updated Stepper and Wizard live manual previews rendered on both platforms without captured runtime exceptions, console errors or error panels. Their source is the same highlighted code displayed in the manual.
- Visual evidence: [Blazor RTL indicators](screenshots/steps028-blazor-side-indicators.png), [Blazor narrow](screenshots/steps028-blazor-side-narrow.png), [Flutter RTL indicators](screenshots/steps028-flutter-side-indicators.png), [Flutter narrow](screenshots/steps028-flutter-side-narrow.png), [completed Flutter workflow](screenshots/steps028-flutter-completed.png).

Reset invalidates local pending results; it does not cancel network operations or undo external save effects. Automatic form integration, per-step event/template overrides, complete localization, focus transfer/arrow navigation, animation and native/mobile/screen-reader certification remain open. Next planned block: existing forms and input components.

## TextBox, TextArea and Form block (0.29, 2026-10-19)

Both Web implementations add text read-only mode, helper text, decorative prefix/suffix slots and focus hooks. TextBox adds a positive maximum length. TextArea validates row/length configuration. Form awaits asynchronous saves, prevents duplicate submission, blocks content interaction while saving, reports invalid submissions and displays configurable busy/failure text with retry.

- **250 Blazor rendering/data checks** and **127 Flutter tests** passed. New tests cover helper/ARIA merging, read-only rendering and focus, parameter validation, required read-only values, invalid submit, duplicate pending callbacks, retry and disposal during a failing save.
- Tests caught Flutter field state being lost when the validation summary disappeared. A stable content key now preserves the draft; the invalid-input → correction → failed save → successful retry regression passes.
- Blazor gallery builds passed with zero warnings/errors. Flutter Web release builds and Dart analysis passed. Existing CupertinoIcons font-family build warning remains. All **47 Blazor + 47 Flutter manual examples** compile/analyze, and **94 lossless highlighting checks** pass.
- Coordinated visible Chrome on local Linux/iMac: `scripts/text-form-check.mjs blazor|flutter` passed public focus, read-only typing protection, text editing, validation failure, simulated save failure, draft retention, retry, pending-save reset and 390 px layout.
- `scripts/text-form-gallery-check.mjs blazor|flutter` checked the actual Forms and dates gallery, read-only text, async workshop saving with the complete result, dark theme and narrow viewport.
- All six updated live manual previews loaded without captured runtime exceptions, console errors or error panels. Screenshot inspection also led to added spacing below Blazor text guidance.
- Evidence: [Blazor gallery](screenshots/forms029-blazor-gallery-dark.png), [Flutter gallery](screenshots/forms029-flutter-gallery-dark.png), [Blazor live form](screenshots/forms029-blazor-manual.png), [Flutter save error](screenshots/forms029-flutter-error.png), [Flutter narrow form](screenshots/forms029-flutter-narrow.png).

No full Telerik parity or native/screen-reader certification is claimed. Automatic form generation, conditional schema, appearance variants, debounce, clear/password modes and auto-resize remain tracked gaps. Browser and Flutter length counting and commit-event timing differ as documented. Reset does not cancel transport or roll back external save effects. Next block: existing AutoComplete, ComboBox and MultiSelect.

## AutoComplete, ComboBox and MultiSelect block (0.30, 2026-10-19)

Both Web implementations add configurable local filtering, minimum query lengths and read-only selection. ComboBox adds a labelled clear action, decorative item templates and selected-label refresh. MultiSelect adds item/tag templates and optional atomic filtered selection/clear, preserving disabled selections and enforcing user-addition limits. Flutter validation reads the current controlled selection.

- **257 Blazor rendering/data checks** and **131 Flutter tests** passed. Four selection contract/widget tests cover filter modes/minimum, option ID validation, free-text suggestions, renamed selected records, invalid ComboBox drafts, clear/read-only state, atomic bulk limits, immutable emissions, disabled selections and parent-driven required validation. The focused suite passed again after adding rejection of stale callbacks for newly disabled/removed/renamed Flutter ComboBox options.
- Blazor gallery builds passed with zero warnings/errors. Flutter Web release builds and Dart analysis passed; the existing CupertinoIcons font-family warning remains. **47 Blazor + 47 Flutter manual examples** compile/analyze; **94 highlighting checks** pass.
- Coordinated visible Chrome on local Linux/iMac: `scripts/selection-input-check.mjs blazor|flutter` passed prefix/minimum filtering, free text and read-only typing protection, selected-label refresh, invalid-draft submission blocking, clear, ArrowDown/Enter option selection, atomic bulk limit rejection, filtered selection, locked-item retention, read-only filtering, no-match state and 390 px layout. Browser datalist verification checks supplied matching options; its native popup remains browser-owned.
- Flutter browser verification focuses the editor before inspecting its active HTML value and checks merged semantics for no-match text. Screenshots confirm rendered labels and states; a passive Flutter semantics input value alone is not the canvas editor value.
- `scripts/selection-input-gallery-check.mjs blazor|flutter` passed the main Forms and dates gallery with read-only choices, async workshop saving, dark theme and narrow layout. Six updated live manual previews loaded without captured runtime errors or error panels.
- Visual review moved the Blazor clear action beside the ComboBox input and removed misleading delete marks from locked MultiSelect tags. Evidence: [Blazor ComboBox](screenshots/selection030-blazor-combo-options.png), [Flutter ComboBox](screenshots/selection030-flutter-combo-options.png), [Blazor narrow](screenshots/selection030-blazor-narrow.png), [Flutter narrow](screenshots/selection030-flutter-narrow.png), [Blazor gallery](screenshots/selection030-blazor-gallery-dark.png), [Flutter gallery](screenshots/selection030-flutter-gallery-dark.png).

Full Telerik parity is not claimed. Remote data, debounce/cancellation, virtualization, model mapping, grouping and popup APIs remain gaps; MultiSelect is still an inline checklist. Flutter cached suggestions refresh on the next query edit after data/filter changes, with stale selection callbacks guarded. Native/mobile and full screen-reader certification remain deferred. Next block: existing numeric and date/time inputs.


## Numeric and time editing block (0.31, 2026-10-19)

NumericTextBox now validates bounds inside the Blazor component instead of relying on native HTML min/max attributes. Both platforms provide labelled increment/decrement actions, clamping, read-only and helper text. TimePicker and DateTimePicker add read-only and positive minute intervals dividing 60. Flutter temporal editors discard stale popup results after parent rebuild, editor changes or disposal.

- **268 Blazor rendering/data checks** and **135 Flutter tests** passed. New cases cover invalid numeric syntax, inclusive bounds, empty input, spin recovery/clamping, read-only, time/date-time intervals, invalid configuration and stale/disposed temporal callbacks.
- Blazor gallery builds passed with zero warnings/errors. Flutter Web release build and Dart analysis passed; the existing CupertinoIcons font-family warning remains. **47 Blazor + 47 Flutter manual examples** compile/analyze; **94 lossless highlighting checks** pass.
- Coordinated visible Chrome on local Linux/iMac: `scripts/numeric-time-check.mjs blazor|flutter` passed invalid draft submission blocking, retained model, increment/decrement recovery, maximum clamping, read-only typing protection, off-step rejection/on-step acceptance for both temporal editors and 390 px layout.
- `scripts/numeric-time-gallery-check.mjs blazor|flutter` passed complete workshop saving, dark theme and narrow gallery layout. Updated manual previews were reviewed on both frameworks; screenshots were inspected.
- Evidence: [Blazor invalid draft](screenshots/numeric031-blazor-invalid.png), [Flutter invalid draft](screenshots/numeric031-flutter-invalid.png), [Blazor narrow](screenshots/numeric031-blazor-narrow.png), [Flutter narrow](screenshots/numeric031-flutter-narrow.png), [Flutter interval error](screenshots/numeric031-flutter-NgTimePicker-error.png), [Blazor dark gallery](screenshots/numeric031-blazor-gallery-dark.png), [Flutter dark gallery](screenshots/numeric031-flutter-gallery-dark.png).

This is interval validation, not a restricted-minute popup: native/Material dialogs still expose all minutes. Culture/currency/percent formatting, precision rounding, spinner acceleration, custom popup templates, time zones and full screen-reader/native certification remain gaps. Parent-supplied models need application validation. Blazor InputBase retains parsing-failed text; replace the component key to reset that draft reliably. Next block: Calendar, DateInput, DatePicker and DateRangePicker.


## Calendar/date editors and Linux desktop workspace (0.32, 2026-10-19)

Calendar, DateInput, DatePicker and DateRangePicker now support read-only on both Web platforms. Ranges forward unavailable-date predicates to both endpoints. Invalid bounds fail early; optional Blazor date clearing returns null. Flutter range state synchronizes parent replacements while still validating edits before the next parent rebuild. Temporal controller updates are deferred until after the form build to avoid notifying FormState during build.

- **273 Blazor checks** and **139 Flutter tests** passed. New cases cover optional clearing, leap days, read-only rendering/focus, invalid bounds, parent range replacement and unavailable endpoints. The existing immediate input-to-submit regression caught stale range validation and passes after the fix.
- Blazor gallery build: zero warnings/errors. Flutter Web build and Dart analysis passed; the existing CupertinoIcons font-family warning remains. **47 Blazor + 47 Flutter manual examples** compile/analyze; **94 highlighting checks** passed.
- Foreground Chrome on local Linux/iMac, isolated profile `/tmp/nextgen-components-review032`, CDP9341: `scripts/date-desktop-check.py` passed both embedded galleries, documentation search/page retention, retained Blazor input across section switches, three retained frames and 390 px shell layout. Blazor DateInput/DatePicker reject excluded Sundays, allow optional clearing and enforce read-only; Calendar blocks all actions in read-only.
- `scripts/date-flutter-check.py` passed excluded Sunday errors with retained model, optional clearing and read-only on both Flutter date editors. Focus the Flutter editor before inspecting its active HTML read-only state; passive semantics input alone is not proof. Screenshots were opened and inspected.
- The desktop shell uses a dedicated Chrome app window and profile, retaining Documentation / Blazor / Flutter frames across switches. Reload and Open in browser are provided. The gallery framing policy permits only self and the explicit local documentation origin for loopback requests. Other remote requests retain the default policy.
- Installed updated desktop/menu shortcuts; `desktop-file-validate` passed. Services remain on-demand and loopback-only. This is a Linux shell around Web demos, not a native Flutter Desktop component claim.

Evidence: [desktop documentation](screenshots/desktop032-manual.png), [Flutter demo](screenshots/desktop032-flutter.png), [narrow workspace](screenshots/desktop032-narrow.png), [Flutter unavailable date](screenshots/dates032-flutter-invalid.png). More captures and logs are under ignored `artifacts/`. Full Telerik parity, native/mobile and screen-reader certification remain open.

## RadioGroup and DropDownList (0.33, 2026-10-19)

Expanded the remaining choice editors on both Web frameworks: read-only/disabled guards, helper text, nonempty unique option IDs, horizontal/vertical radio layout and decorative item templates with model-based accessible names. Dropdowns retain missing selected keys as unavailable entries and reject form submission; Flutter rejects stale popup callbacks before changing local field state.

- **275 Blazor checks** and **143 Flutter tests** passed. New widget tests cover removed-option validation and recovery, stale callback after read-only rebuild, radio templates/disabled selection and duplicate keys. Existing external dropdown value replacement still passes.
- Blazor gallery builds passed without warnings/errors. Flutter Web build and Dart analysis passed; the existing CupertinoIcons warning remains. **47 Blazor + 47 Flutter manual examples** compile/analyze and **94 highlighting checks** pass.
- Visible Chrome on local Linux/iMac, dedicated `/tmp/nextgen-components-review033` profile: `scripts/choice-editors-check.py blazor|flutter` passed missing-value save rejection, selection recovery/successful save, radio template selection/layout switch and 390 px layout. Read-only is checked through Blazor DOM state and Flutter widget tests; screenshots confirm its native disabled presentation.
- Screenshot review caught the browser displaying the first available Blazor option after removal while the model retained the missing ID. Explicit selected-option markup fixes the mismatch; the regression now checks the actual DOM value and selected label before capturing evidence.
- Updated foundation galleries, English manuals, highlighted snippets and executable previews. The RadioGroup live preview was inspected inside the desktop documentation shell, which reports version 0.33.

Evidence: [Blazor missing selection](screenshots/choices033-blazor-missing.png), [Flutter missing selection](screenshots/choices033-flutter-missing.png), [narrow radio layout](screenshots/choices033-flutter-narrow.png), [desktop manual preview](screenshots/choices033-desktop-manual.png). These are Web checks, not full Telerik parity or screen-reader/native certification. Next planned block: data management.

## 0.34 — protected Grid selection (2026-10-19)

- Blazor: 278 render/data checks; gallery build with zero warnings/errors. Flutter: 145 tests passed; focused data/Grid suite (12 tests) repeated after selection callback and semantics changes. Dart analysis passed.
- Manual: all 47 Blazor and 47 Flutter examples compiled/analyzed; 94 highlighted examples passed lossless/escaping checks. Flutter release Web build passed (existing unused CupertinoIcons font-family warning remains).
- Visible foreground Chrome on local Linux/iMac, isolated profile and CDP 9341: `python3 scripts/grid-selection-check.py blazor` and `flutter` passed. Four eligible rows selected per page, Paused row excluded, individual/partial/page toggles, hidden selections preserved, read-only selection and continued page navigation checked.
- Blazor custom 18-row page and custom empty result checked; 390px previews checked for page overflow on both platforms. Desktop manual displayed updated Grid contract, category tree and embedded Blazor live preview.
- Browser verification found Flutter merged the header checkbox into a columnheader; an explicit semantic container preserves the checkbox. Current Flutter Web SemanticCheckable maps mixed to false: the accessible name now explicitly says “partially selected”; the visual dash remains. No screen-reader or native-platform certification claimed.
- Screenshots: [Blazor selection](screenshots/grid034-blazor-selected.png), [Blazor dark](screenshots/grid034-blazor-dark.png), [Flutter selection](screenshots/grid034-flutter-selected.png), [desktop manual](screenshots/grid034-desktop.png).
- Remaining: server loading/virtualization, multi-sort/grouping, range/cell selection, built-in CRUD, direct page entry. Next coherent roadmap block: TreeView/TreeList state and interaction.

## 0.35 — controlled TreeView/TreeList state (2026-10-19)

- 284 Blazor render/data checks and zero-warning gallery build passed. Flutter: all 149 tests passed, including independent state locks, rejected expansion changes, immutable sets, stale callbacks after removal/search/locks, whitespace search and leaf keyboard behavior. Dart analysis passed.
- All 47 Blazor and 47 Flutter manual examples compiled/analyzed; 94 highlighted code examples passed. Flutter release Web build passed; existing CupertinoIcons font-family warning remains.
- Visible foreground Chrome on local Linux/iMac, isolated profile/CDP 9341: `python3 scripts/tree-state-check.py blazor` and `flutter` passed for both TreeView and TreeList. Confirmed template labels, selection and expansion locks independently, search through a locked collapsed parent, clearing search restoring collapse, whitespace search permitting expansion, custom empty text.
- `python3 scripts/tree-keyboard-check.py` passed: ArrowRight on a leaf stays put; ArrowDown reaches sibling; ArrowLeft reaches parent; Enter selects. Both 390px TreeView previews stayed within the viewport. Desktop manual displayed the updated live preview with category navigation. Screenshots inspected visually.
- Evidence: [Blazor TreeView](screenshots/tree035-blazor-NgTreeView.png), [Flutter TreeList](screenshots/tree035-flutter-NgTreeList.png), [Flutter narrow](screenshots/tree035-flutter-narrow.png), [desktop manual](screenshots/tree035-desktop.png).
- Remaining: roving tabindex/focus recovery, type-ahead, checkbox/multiple selection, TreeList treegrid navigation, lazy/server loading, virtualization and drag/drop. No full Telerik parity, screen-reader or native certification. Next roadmap group: visualization.

## 0.36 — Chart legend ownership and point labels (2026-10-19)

- Blazor: 286 render/data checks, gallery build with zero warnings/errors. Flutter: 156 tests passed; seven chart-state tests repeated after adding equivalent-data replacement coverage. All six chart modes check selection reconciliation, read-only/stale point rejection and invalid-data recovery. Controlled legend proposals preserve input sets and can be rejected. Dart analysis passed.
- All 47 Blazor and 47 Flutter manual examples compiled/analyzed; 94 lossless highlighted examples passed. Flutter release Web build passed with the existing CupertinoIcons font-family warning.
- Visible foreground Chrome on local Linux/iMac in a dedicated profile: `python3 scripts/chart-state-check.py blazor` and `flutter` passed. Formatted point callbacks, independent selection/legend locks, rejected and accepted legend proposals, all-hidden empty text, parent-driven visibility reset, updated numeric values, invalid data and 390px previews checked. Blazor uses pointer actions; Flutter uses semantic control activation to avoid canvas/DOM coordinate drift after scrolling. This is not screen-reader certification.
- Updated Chart manual, category navigation and live preview inspected inside the desktop shell. Screenshot evidence: [Blazor selection](screenshots/chart036-blazor-selected.png), [Flutter selection](screenshots/chart036-flutter-selection-status.png), [Flutter narrow](screenshots/chart036-flutter-narrow.png), [desktop preview](screenshots/chart036-desktop.png).
- Remaining: index-based series identity, chart-owned point selection, advanced axes/formatting, arbitrary tooltip templates, stacking, zoom/pan, export and native platform verification. Next coherent block: gauges.

## 0.37 — Gauge ranges and readings (2026-10-19)

- 301 Blazor rendering/data checks and a zero-warning gallery build passed. All 161 Flutter tests passed; Dart analysis passed. Tests cover immutable range sorting, shared endpoints, maximum inclusion, gaps, invalid/overlapping ranges, extreme finite scale bounds, decimal precision and dynamic widget updates at narrow width.
- All 47 Blazor and 47 Flutter manual examples compiled/analyzed; 94 highlighted examples passed. Flutter release Web build passed with the existing CupertinoIcons font-family warning.
- Visible foreground Chrome on local Linux/iMac, isolated profile/CDP 9341: `python3 scripts/gauge-ranges-check.py` and `python3 scripts/gauge-ranges-check.py flutter` passed for both gauges. Checked fractional and out-of-scale readings, explicit status, clamped Blazor numeric ARIA value, dynamic range removal/restoration, external value updates and 390px layouts. Blazor controls used pointer clicks; Flutter used semantic DOM activation. Screenshots were visually inspected.
- Desktop documentation shell displayed the updated manual, left category navigation and embedded live ArcGauge example. Evidence: [Blazor narrow arc](screenshots/gauge037-blazor-NgArcGauge-narrow.png), [Flutter above maximum](screenshots/gauge037-flutter-NgLinearGauge-above.png), [Flutter narrow arc](screenshots/gauge037-flutter-NgArcGauge-narrow.png), [desktop manual](screenshots/gauge037-desktop.png).
- Remaining: pointers, advanced scale/ticks, animation, export, screen-reader certification and native platform checks. Next coherent roadmap block: Scheduler.

## 0.38 — Scheduler day/week state and guarded actions (2026-10-19)

- 310 Blazor rendering/data checks and zero-warning gallery build passed. All 167 Flutter tests passed; the six Scheduler tests were repeated after final presentation changes. Dart analysis passed. Coverage includes first weekdays, complete display boundaries, nonblank IDs, controlled view proposals, independent locks, missing callbacks, stale actions after data/date/lock changes and disposal, overnight intersection and midnight exclusion.
- All 47 Blazor and 47 Flutter manual examples compiled/analyzed; 94 highlighted examples passed. Flutter release Web build passed with the existing CupertinoIcons font-family warning.
- Visible foreground Chrome on local Linux/iMac, isolated profile/CDP 9341: `python3 scripts/scheduler-state-check.py` and `python3 scripts/scheduler-state-check.py flutter` passed. Confirmed rejected date/view proposals, accepted Day/Week mode, create callback for the visible day, navigation while editing is locked, editing while navigation is locked, programmatic reset under a lock, Sunday week start, empty-day text and 390px page layouts. Blazor navigation used pointer clicks; the event action used DOM activation. Flutter used semantic DOM activation. This does not certify screen-reader behavior.
- Final screenshots visually inspected: [Blazor locked day](screenshots/scheduler038-blazor-day-locked.png), [Blazor narrow week](screenshots/scheduler038-blazor-narrow.png), [Flutter day](screenshots/scheduler038-flutter-day.png), [desktop manual with live preview](screenshots/scheduler038-desktop.png). The desktop shell retains category navigation and highlighted source examples.
- Remaining: time-slot grids, month/year views, recurrence, resources, drag/drop, resize, timezone conversion, persistence and native platform verification. Next coherent roadmap block: Spreadsheet.

## 0.39 — Spreadsheet controlled edits and protected cells (2026-10-19)

- 317 Blazor rendering/data checks and zero-warning gallery build passed. All 173 Flutter tests passed; the 14 workbook/protection tests were repeated after final formula presentation changes. Dart analysis passed. Tests cover rejected proposals, accepted-only undo/redo, no-op edits, callback absence, protected paste including unchanged destinations, formula recalculation, lock changes, stale callbacks, replacement dimensions and disposal.
- All 47 Blazor and 47 Flutter manual examples compiled/analyzed; 94 highlighted examples passed. Flutter release Web build passed with the existing CupertinoIcons font-family warning.
- Visible foreground Chrome on local Linux/iMac, isolated profile/CDP 9341: `python3 scripts/sheet-protection-check.py` and `python3 scripts/sheet-protection-check.py flutter` passed. Confirmed accepted/rejected edits and Undo, draft retention, Redo, history protection, atomic paste rejection and acceptance after unlocking, single-step paste undo, protected formula inspection, external shrink/reset, read-only display and 390px layouts. Blazor buttons used pointer clicks; Flutter used semantic DOM activation. Text entry used Chrome keyboard/input events.
- Browser checks found Flutter's semantic text input did not expose readonly and could retain an old value while unfocused. Protected formulas now have explicit read-only text presentation. Editable fields are recreated for a new accepted sheet/selection; DOM value assertions focus the input first because Flutter populates it on focus. No screen-reader certification is claimed.
- Screenshots inspected visually: [Blazor protected paste](screenshots/sheet039-blazor-paste-rejected.png), [Flutter protected reading](screenshots/sheet039-flutter-protected.png), [Flutter narrow sheet](screenshots/sheet039-flutter-narrow.png), [desktop manual/live preview](screenshots/sheet039-desktop.png). Workbook galleries protect headers and calculated costs while editable source values continue to feed the pivot.
- Remaining: multi-cell selection, clipboard API, formatting, merged cells, file import/export, multiple sheets and native verification. Next coherent roadmap block: PivotGrid.

## 0.40 — PivotGrid presentation and guarded drilldown (2026-10-19)

- 325 Blazor rendering/data checks and a zero-warning gallery build passed. All 179 Flutter tests passed; Dart analysis passed. Coverage includes all four total visibility combinations, source-weighted averages, nullable formatting, raw keys versus display labels, original record identity, read-only callback collections, nonblank IDs, action locks and stale callbacks after replacement, aggregate/visibility changes and disposal.
- All 47 Blazor and 47 Flutter manual examples compiled/analyzed; 94 lossless highlighted examples passed. Flutter release Web build passed with the existing CupertinoIcons font-family warning.
- Visible foreground Chrome on local Linux/iMac, isolated profile/CDP 9341: `python3 scripts/pivot-presentation-check.py` and `python3 scripts/pivot-presentation-check.py flutter` passed. Confirmed formatted cell labels and raw drilldown keys/IDs, grand total records, disabled actions while locked, updated values, weighted averages, independent total visibility, custom empty state, data restoration and 390px layouts. Blazor used pointer clicks; Flutter used semantic DOM activation. This does not certify screen-reader behavior.
- Updated manual and live example inspected in the desktop documentation shell. Screenshots visually inspected: [Blazor hidden totals](screenshots/pivot040-blazor-totals.png), [Flutter locked values](screenshots/pivot040-flutter-locked.png), [Flutter narrow table](screenshots/pivot040-flutter-narrow.png), [desktop manual/live preview](screenshots/pivot040-desktop.png). Narrow tables scroll within their own region.
- Remaining: multiple dimensions/measures, arbitrary cell templates, OLAP, export, virtualization and native platform verification. Next coherent roadmap block: Editor.

## 0.41 — Editor controlled changes and draft recovery (2026-10-19)

- 327 Blazor rendering/data checks and zero-warning gallery build passed. All 186 Flutter tests passed, including seven new Editor state tests. Dart analysis passed. Tests cover rejected formatting/selection/insertion, accepted-only history, rejected Undo with draft retention, local discard, replacement, missing callbacks, read-only inspection, stale actions after selection/replacement/lock/disposal and deleting the final empty block without a proposal.
- All 47 Blazor and 47 Flutter manual examples compiled/analyzed; 94 lossless highlighted examples passed. Flutter release Web build passed with the existing CupertinoIcons font-family warning.
- Visible foreground Chrome on local Linux/iMac, isolated profile/CDP 9341: `python3 scripts/editor-state-check.py` and `python3 scripts/editor-state-check.py flutter` passed. Checked rejected edits/selection/insertion, accepted formatting and Undo/Redo, rejected history, draft discard, insertion/move/delete, replacement with selection clamping, final empty-block deletion, read-only inspection and 390px layouts. Blazor also checks rejection restoring the native block-type selector. Blazor buttons used pointer clicks; Flutter used semantic DOM activation. Text entry used Chrome keyboard/input events; Flutter input-value assertions focus the field first.
- Screenshots visually inspected: [Blazor rejected draft](screenshots/editor041-blazor-rejected.png), [Flutter read-only inspection](screenshots/editor041-flutter-readonly.png), [Flutter narrow editor](screenshots/editor041-flutter-narrow.png), [desktop manual/live example](screenshots/editor041-desktop.png). The desktop shell retains left category navigation and highlighted examples.
- Parent acceptance requires returning the exact proposal instance. Independent replacements reset history/draft; late async responses require host-side ordering. Inline rich-text ranges, HTML import, links/images/tables, collaboration, screen-reader certification and native platform verification remain open. Next coherent roadmap block: Diagram.

## 0.42 — Diagram interaction locks and guarded movement (2026-10-19)

- 330 Blazor rendering/data checks and zero-warning gallery build passed. All 193 Flutter tests passed, including seven new Diagram state tests. Dart analysis passed. Coverage includes raw IDs under formatted labels, independent movement/selection locks, missing callbacks, rejected graph proposals, replacement/lock/zoom during active drag and stale selection/keyboard/gesture callbacks after replacement or disposal.
- A short Flutter drag could lose displacement before its first update when selection was disabled. The drag-start preview now includes the initial pointer displacement; the independent-lock test covers this case. All 13 Diagram tests passed before the full suite.
- All 47 Blazor and 47 Flutter manual examples compiled/analyzed; 94 lossless highlighted examples passed. Flutter release Web build passed with the existing CupertinoIcons font-family warning.
- Visible foreground Chrome on local Linux/iMac, isolated profile/CDP 9341: `python3 scripts/diagram-state-check.py` and `python3 scripts/diagram-state-check.py flutter` passed. Both use native mouse drag and keyboard events; Flutter buttons use semantic DOM activation (node names include their tooltip text). Checks cover one callback per drag, raw selection IDs, keyboard movement, independent locks, navigation while locked, rejected coordinates, replacement and locking before pointer release, custom empty state, data restoration and 390px layouts. During active drag, replacement/lock controls are activated through DOM semantics without releasing the pointer first.
- Screenshots visually inspected: [Blazor rejected move](screenshots/diagram042-blazor-rejected.png), [Flutter movement locked](screenshots/diagram042-flutter-locked.png), [Flutter narrow canvas](screenshots/diagram042-flutter-narrow.png), [desktop manual/live preview](screenshots/diagram042-desktop.png). The canvas scrolls internally at narrow widths; the desktop shell retains category navigation and highlighted examples.
- Remaining: auto layout, obstacle routing, drag-to-connect, resize handles, groups, arbitrary templates, export, screen-reader certification and native platform verification. Parent-side asynchronous results still need ordering against newer graph data. Next coherent roadmap block: Map.

## 0.43 — Map controlled state and independent permissions (2026-10-19)

- 340 Blazor rendering/data checks and zero-warning gallery build passed. Ten new bridge checks cover valid/stale/unknown selection events, independent locks, malformed/out-of-range messages and disposal. All 194 Flutter tests passed; the new native test confirms that lock/configuration updates retain the explicit Web-only placeholder. Dart analysis passed. Flutter iframe behavior is verified separately in Chrome, not by the native widget tests.
- All 47 Blazor and 47 Flutter manual examples compiled/analyzed; 94 lossless highlighted examples passed. Flutter release Web build passed with the existing CupertinoIcons font-family warning. `python3 scripts/sync_map_assets.py --check` confirmed identical shared viewer copies in both packages.
- Visible foreground Chrome on local Linux/iMac, isolated profile/CDP 9341: `python3 scripts/map-state-check.py` and `python3 scripts/map-state-check.py flutter` passed. No external tile provider was configured. Checked rejected/accepted selection and zoom, no reconciliation feedback loop, independent navigation/selection/background-click locks, parent view updates under lock, stale revision packets with reused IDs, detached object actions, invalid coordinates, cluster chooser/member selection while navigation is locked, replacement labels, empty-state restoration and 390px parent/iframe layouts.
- Controls use DOM/Flutter semantic activation; background clicks use native mouse events. Tests also configure the shared viewer directly to verify local navigation without a view callback, persistence through unrelated configuration changes and disabled selection without a handler. Late host-side async results remain the application's responsibility.
- Screenshots visually inspected: [Blazor accepted cluster member](screenshots/map043-blazor-cluster.png), [Flutter interaction locks](screenshots/map043-flutter-locked.png), [Flutter narrow map](screenshots/map043-flutter-narrow.png), [desktop manual/live preview](screenshots/map043-desktop.png). Object selection opens an accepted popup without automatically panning; Fit data remains the explicit navigation action.
- Remaining: GeoJSON, bubble/vector layers, routing, editing, export/offline maps, screen-reader certification and native Flutter implementation. External tile-provider availability was not retested in this stage. Next coherent roadmap block: PDF Viewer.

## 0.44 — PDF page thumbnails (2026-10-19)

- Added a collapsible page rail shared by Blazor and Flutter Web: numbered native buttons, current-page indication and synchronization with direct page, toolbar and search navigation. Visible previews render sequentially, bounded to 224 × 288 pixels, and release their canvases when scrolled away or closed. Replacement clears the rail and guards stale work/actions.
- Both gallery builds passed; Blazor reported zero warnings/errors. Flutter retained its existing CupertinoIcons font warning. All 47 Razor and 47 Dart manual examples passed, as did 94 lossless highlighted examples and shared PDF asset synchronization. The platform component APIs were unchanged; the full C#/Dart unit suites were not rerun for this shared-renderer stage.
- `scripts/pdf-thumbnails-check.py blazor` and `flutter`: 16 checks each in foreground Google Chrome on Linux iMac. Real CDP Enter activated a focused thumbnail; other buttons used DOM clicks. A generated 30-page fixture verified lazy rendering, direct navigation to page 30, old-canvas release and raster bounds. Invalid PDF recovery rejected a retained old-document button. Search highlighting, closed-rail cleanup and 390 px layout passed on both platforms. Theme rendering was checked by changing the iframe theme; parent theme persistence is unchanged.
- Desktop documentation showed the updated English manual and its embedded live PDF demo. Reviewed screenshots: [Blazor](screenshots/pdf044-blazor-thumbnails.png), [Flutter](screenshots/pdf044-flutter-thumbnails.png), [narrow dark viewer](screenshots/pdf044-blazor-narrow.png), [desktop documentation](screenshots/pdf044-desktop.png). Only the dedicated review window was used; unrelated Chrome sessions were preserved.
- Remaining: parent page/load callbacks, controlled navigation, passwords, printing, annotations/forms/signatures, links, OCR and native Flutter support. Full screen-reader certification and thumbnail failure injection were not tested. Next coherent roadmap block: AI Prompt and PromptBox.

## 0.45 — AI permissions and recoverable prompt limits (2026-10-19)

- Added independent generation, history-clear and feedback permissions to Blazor and Flutter Web. Global read-only remains available; browsing/copying responses remain enabled. Missing provider/feedback handlers disable the corresponding actions. Action-time guards recheck permissions, lifetime, current response and history membership. Generation locks cancel pending work while preserving previous successful responses.
- PromptBox retains oversized drafts after a reduced limit, exposes a validation message and blocks Send while allowing incremental shortening. External values remain capped at 8000 UTF-16 units. Send/Cancel recheck current state and callbacks. Both manuals now include live controls for these scenarios; Flutter PromptBox explicitly displays its submit/cancel result.
- Passed **342 Blazor checks**, **198 Flutter tests**, Dart analysis without issues, both gallery builds, **47 Razor + 47 Dart manual examples**, and **94 lossless highlighted examples**. Flutter retained the existing CupertinoIcons font warning. Added widget tests cover retained Send/Clear/feedback callbacks, independent locks, missing providers and cancelled late responses.
- `scripts/ai-permissions-check.py blazor` and `flutter`: **20 checks per platform**, foreground Chrome on local Linux iMac. Verified independent locks, retained history after cancellation, clear while generation is locked, recovery/new request, 390 px layout, oversized-draft preservation and correction, busy cancellation and successful submission. Buttons used DOM/Flutter semantics clicks; text used CDP keyboard input (the final script also uses a native mouse click to restore Flutter text focus). Clipboard availability was checked through the enabled action; actual clipboard contents were not verified in this stage.
- Reviewed [Blazor locked state](screenshots/ai045-blazor-locked.png), [Flutter locked state](screenshots/ai045-flutter-locked.png), [narrow Flutter](screenshots/ai045-flutter-narrow.png), [length validation](screenshots/ai045-blazor-length.png), [Flutter recovery](screenshots/ai045-flutter-recovered.png) and [desktop documentation](screenshots/ai045-desktop.png). Updated English API documentation and live previews render inside the existing desktop shell. Unrelated Chrome windows were preserved.
- Remaining: streaming, Markdown/rich output, attachments, speech, command templates, model selection, provider integrations, durable conversations and native verification. Demo handlers remain deterministic and local; no external AI provider was called. The work order returns to remaining editor/form gaps; this stage does not establish full Telerik parity.

## 0.46 — Text clear actions and password presentation (2026-10-19)

- TextBox and TextArea now support opt-in clear actions that update form state, report one value change and restore editor focus. Empty, read-only and disabled fields cannot clear. TextBox adds optional masked input and reveal; clear, locks and focus exit restore masking. Defaults preserve ordinary plain-text editors.
- Flutter uses a shared internal editor while retaining external controller ownership, initialValue form reset and existing validation. Retained handlers are rejected after parameter/controller replacement and disposal. Both detailed English manuals and live previews now demonstrate the actions; TextBox preview reports length instead of duplicating the password value outside the field.
- Passed **344 Blazor checks**, **202 Flutter tests**, clean Dart analysis, both gallery builds, **47 Razor + 47 Dart manual examples** and **94 lossless highlighted examples**. Added tests cover clear/validation/focus, exactly one change callback without submission, programmatic controller updates, initial-value reset, read-only/disabled reveal, replacement and disposed handlers. Flutter build retained the existing CupertinoIcons font warning.
- `scripts/text-actions-check.py blazor` and `flutter`: **20 checks each** in foreground Chrome on Linux iMac. Verified masking/reveal, value preservation, read-only actions, clear/focus, native mouse reveal and keyboard Tab hiding, plain mode, 390 px layout, multiline clear and subsequent editing. Routine action buttons used DOM/semantics clicks; text entry used native CDP mouse/keyboard input. Flutter field values were checked after focusing the editor because unfocused semantics inputs do not expose the displayed value.
- Visually reviewed [Blazor narrow](screenshots/text046-blazor-narrow.png), [Flutter narrow](screenshots/text046-flutter-narrow.png), [multiline editing](screenshots/text046-flutter-multiline.png) and [desktop documentation](screenshots/text046-desktop.png). The existing desktop shell shows the updated manual and embedded preview. Unrelated Chrome sessions were preserved.
- Remaining: auto-resize, debounce, appearance variants, customizable action labels, password-manager integration and native/screen-reader certification. Password mode is presentation only. Blazor native change-on-blur and Flutter submission timing still differ; clearing does not explicitly commit or submit. Continue with remaining editor/form gaps; no full Telerik parity claim.

## 0.47 — Bounded automatic TextArea height (2026-10-19)

- Added opt-in AutoSize/autoSize and MaxRows/maxRows, with Rows as the minimum and internal scrolling above the maximum. Both bounds accept 1–30; inconsistent automatic bounds fail early. Typing, explicit line breaks, wrapping, external replacement, clear and width changes recalculate height without changing values or emitting callbacks. Read-only content still resizes.
- Blazor packages a measurement module with input, width and font observers, restores original inline height/overflow when disabled and detaches observers on disposal/DOM removal. Static SSR retains Rows. Flutter uses native minLines/maxLines and existing controller/form behavior. Manual/examples and desktop documentation were updated.
- Passed **346 Blazor checks**, **205 Flutter tests**, Dart analysis without issues, both gallery builds, **47 Razor + 47 Dart examples** and **94 lossless highlighted examples**. Flutter retained its existing CupertinoIcons font warning. New widget checks verify bounded growth, shrink, no spurious value callbacks, read-only external updates, fixed mode and invalid bounds.
- `scripts/textarea-size-check.py blazor` and `flutter`: **20 Blazor and 18 Flutter checks** in foreground Chrome on Linux iMac. Verified long/short external data, typing within bounds, cap stability, clear, 390 px wrapping and widening, read-only replacement, mode switching with preserved text and stable final layout. Blazor additionally verified actual DOM scroll overflow and observer cleanup/restored style after DOM removal. Text entry used native CDP mouse/keyboard input; buttons used DOM/semantics clicks. Flutter semantic input values were read after restoring focus.
- Visually reviewed [Blazor capped](screenshots/text047-blazor-capped.png), [Blazor narrow](screenshots/text047-blazor-narrow.png), [Flutter narrow](screenshots/text047-flutter-narrow.png) and [desktop documentation](screenshots/text047-desktop.png). The desktop shell displays the new API and embedded live example. Unrelated Chrome sessions were preserved.
- Limits: platform font metrics and decorations differ; equal rows do not promise equal pixels. Application CSS must not override automatic height/box sizing. Native platforms, screen-reader certification and custom-font loading races were not verified. Debounce and remaining editor/form gaps stay open.


## Text editor appearance — 0.48 (2026-10-19, Linux on iMac)

TextBox and TextArea now provide small/medium/large sizing and theme/outline/filled backgrounds. Defaults inherit the existing theme and density. Chrome exposed the legacy 80 px TextArea minimum overriding automatic row bounds; automatic mode now lets measured row bounds determine the height, while fixed small/large fields retain explicit minima.

Validation completed:

- 350 Blazor rendering/data checks and a zero-warning gallery build.
- 208 Flutter tests; the new interaction checks preserve selected text, form errors and callbacks through appearance changes, and reject invalid configuration. Dart analysis: no issues.
- 47 Razor and 47 Dart manual examples compiled/analyzed; 94 lossless highlighting checks. Flutter release Web build passed (existing CupertinoIcons font warning remains).
- Foreground local Chrome: 24 Blazor and 22 Flutter appearance checks via `scripts/text-appearance-check.py`. Both editors retain values, restore medium metrics, clear after appearance changes and fit a 390 px viewport; automatic TextArea metrics adjust to large size.
- 20 additional Blazor autosize regression checks via `scripts/textarea-size-check.py`, covering wrapping, cap/overflow, shrink, read-only external data, mode switching and removal cleanup.
- Desktop documentation shell opened the updated TextArea manual with category navigation and a live example. Screenshots were inspected directly.

Evidence: [Blazor narrow editor](screenshots/text048-blazor-NgTextArea-narrow.png), [Flutter filled password editor](screenshots/text048-flutter-NgTextBox-large.png), [Flutter narrow editor](screenshots/text048-flutter-NgTextArea-narrow.png), [desktop manual](screenshots/text048-desktop-manual.png).

Flutter retains theme-defined borders and native action hit targets. Pixel parity, native platforms and a full screen-reader audit are not claimed. Debounced notifications, further border/radius options and generated form schemas remain open.


## Debounced text notifications — 0.49 (2026-10-19, Linux on iMac)

TextBox and TextArea expose optional delayed callbacks with a bounded 0–60000 ms delay. Binding and validation remain immediate; bursts deliver the latest value. Locks, external replacement, delay changes, handler removal and disposal cancel pending work. Submit/blur remains independent.

Validation completed:

- 352 Blazor rendering/data checks; gallery build with zero warnings/errors.
- 212 Flutter tests and clean Dart analysis. New tests cover burst coalescing, selection/appearance rebuilds, external replacement, read-only/disabled locks, changed delay, handler removal, controller replacement, clear, zero delay, disposal, native form reset and invalid bounds.
- 47 Razor and 47 Dart manual examples compiled/analyzed; 94 lossless highlighting checks. Flutter release Web build passed with the existing CupertinoIcons font warning.
- Foreground local Chrome: 26 Blazor and 26 Flutter checks using `scripts/text-debounce-check.py`. Immediate values, delayed/coalesced callbacks, replacement/read-only cancellation, changed/zero delay, appearance rebuilds and delayed clear passed for both editors. Native mouse clicks confirmed blur neither flushes nor cancels the callback.
- Desktop shell opened the updated TextArea manual and live example. Screenshots were inspected directly.

Evidence: [Blazor notification count](screenshots/text049-blazor-NgTextArea.png), [Flutter password sample](screenshots/text049-flutter-NgTextBox.png), [desktop manual](screenshots/text049-desktop-manual.png).

Composition-specific suppression and cancellation of already-started application work are not supplied. Flutter Form.reset may schedule the reset value through native onChanged; same-value Blazor binding echoes cannot be distinguished from external resets. Native platforms and full screen-reader certification remain unverified.


## Responsive form fields and actions — 0.50 (2026-10-19, Linux on iMac)

NgForm adds explicit field lists, a maximum of 1–4 columns, preferred minimum cell width, configurable gaps and custom actions below the grid. Legacy child content retains its own layout. Columns adapt to available container width without rebuilding field state.

Validation completed:

- 358 Blazor rendering/data checks, including field/action markup and invalid layout configuration; gallery build passed with zero warnings/errors.
- 217 Flutter tests and clean Dart analysis. New tests cover responsive columns, retained values/focus/validation, keyed field reordering (including a GlobalKey), guarded custom submit, busy/disabled actions, invalid configuration, empty fields and a 100 px parent.
- 47 Razor and 47 Dart manual examples compiled/analyzed; 94 lossless highlighting checks. Flutter release Web build passed with the existing CupertinoIcons font warning.
- Foreground local Chrome: 19 Blazor and 19 Flutter checks via `scripts/form-layout-check.py`. Four fields, wide/two-column and narrow/one-column layout, explicit column/spacing switches, retained draft and actual validation error, 390 px overflow check, custom save, failure/retry, reset and disabled submission all passed.
- Desktop shell opened the updated Form manual and live preview. Wide/narrow screenshots were inspected directly.

Evidence: [Blazor narrow form](screenshots/form050-blazor-narrow.png), [Flutter wide form](screenshots/form050-flutter-wide.png), [Flutter narrow form](screenshots/form050-flutter-narrow.png), [desktop manual](screenshots/form050-desktop-manual.png).

This is explicit field layout, not model-driven editor generation. Spans, nested groups, conditional schemas and custom validation-summary templates remain open. Flutter requires bounded horizontal constraints. Native platforms and full screen-reader certification remain unverified.


## Live validation summaries — 0.51 (2026-10-19, Linux on iMac)

NgForm adds localized default headings, individual error lists and custom templates/builders receiving read-only snapshots. Hidden summaries still validate. Blazor subscribes to its current EditContext and releases subscriptions on replacement/disposal; Flutter refreshes registered validators after field changes following an attempted submit.

Validation completed:

- 358 Blazor rendering/data checks; gallery build passed with zero warnings/errors.
- 221 Flutter tests and clean Dart analysis. New tests verify live updates without automatic save/invalid callbacks, immutable/stable snapshots, hidden-summary validation, empty error strings blocking save, disposal with a queued refresh and form-key replacement.
- 47 Razor and 47 Dart manual examples compiled/analyzed; 94 lossless highlighting checks. Flutter release Web build passed with the existing CupertinoIcons font warning.
- Foreground local Chrome: 22 Blazor and 22 Flutter checks via `scripts/form-summary-check.py`. Two errors reduce to one and then none while editing; visibility and custom/default presentation switches preserve validation, layout changes retain errors, narrow layout fits, valid save succeeds and reset discards old errors. The Flutter browser test waits for native focus transfer before sending text.
- Desktop shell opened the updated Form manual and live example. Screenshots were inspected directly.

Evidence: [Blazor custom summary](screenshots/form051-blazor-two-errors.png), [Flutter narrow summary](screenshots/form051-flutter-narrow.png), [desktop manual](screenshots/form051-desktop-manual.png).

Platform timing remains explicit: Blazor follows validation notifications; Flutter starts summary collection at submit and later revalidates after field changes. Validators must have no side effects. Error-to-field focus mapping, automatic schemas and native/full screen-reader certification remain open.


## Responsive form field spans — 0.52 (2026-10-19, Linux on iMac)

NgForm adds FieldSpans/fieldSpans: one value per explicit field, 1–4 columns or 0 for a complete row. Requested spans clamp to the available columns. Fields retain source order with no dense backfilling. Blazor uses instance-specific container queries with a one-column fallback; legacy ChildContent does not acquire containment. Flutter uses its existing Wrap structure.

Validation completed:

- 363 Blazor rendering/data checks, including responsive CSS rules, full-row spans, invalid span arrays and unchanged legacy fieldset classes; gallery build passed with zero warnings/errors.
- 224 Flutter tests and clean Dart analysis. New tests cover fractional container widths, multi-column/full-row placement, clamping, invalid spans and retained draft/focus/validation after resizing and span changes.
- 47 Razor and 47 Dart manual examples compiled/analyzed; 94 lossless highlighting checks. Flutter release Web build passed with the existing CupertinoIcons font warning.
- Foreground local Chrome: 18 Blazor and 18 Flutter checks via `scripts/form-spans-check.py`. Full-row/two-column/single-cell transitions, three-column layout, sparse source-order flow, preserved notes/errors, 390 px clamping without horizontal overflow and successful save all passed.
- Desktop shell opened the updated Form manual and live example; screenshots were inspected directly.

Evidence: [Blazor two-column field](screenshots/form052-blazor-two-columns.png), [Flutter narrow form](screenshots/form052-flutter-narrow.png), [desktop manual](screenshots/form052-desktop-manual.png).

Nested groups, vertical spans, automatic/conditional schemas and native/full screen-reader certification remain open. Browser verification covers current local Chrome; fallback behavior on older browsers was not separately certified.

## Rounded text editors and flat fill — 0.53 (2026-10-19, Linux on iMac)

TextBox and TextArea add theme/none/small/medium/large/full rounded presets and flat fill. Default theme behavior is preserved. Flat suppresses idle/disabled borders without changing geometry; supplied-theme focus and validation indicators remain. Explicit Flutter focus/error border sides and outline/underline types are retained.

Validation completed:

- 377 Blazor checks, including all corner presets, flat fill and invalid values; gallery build passed with zero warnings/errors.
- 228 Flutter tests and clean Dart analysis. New tests check text, selection, focus, validation, unchanged dimensions and callback counts across all presets; custom focus/error sides, restoration, underline and explicit InputBorder.none behavior are covered.
- 47 Razor and 47 Dart manual examples compiled/analyzed; 94 lossless syntax-highlighting checks passed. Flutter Web release build passed with the existing CupertinoIcons font warning.
- Foreground local Chrome: 37 Blazor and 21 Flutter assertions via `scripts/text-shape-check.py`. Both editors retain drafts through appearance switches, clear correctly and fit at 390 px; multiline autosizing retains all 14 lines. Blazor additionally checks actual CSS radii and idle/focus border transitions. Flutter border properties are covered by widget tests and visible screenshots, not inferred from its semantic DOM.
- Desktop shell opened the updated TextArea manual with code, category navigation and working live preview. Screenshots were inspected directly.

Evidence: [Blazor flat editor](screenshots/text053-blazor-flat.png), [Flutter narrow TextArea](screenshots/text053-flutter-narrow.png), [desktop manual](screenshots/text053-desktop-manual.png).

Full corner rounding is best suited to short single-line editors. Custom InputBorder subclasses, arbitrary border styling, IME-specific debounce handling and full accessibility/native certification remain outside this stage. Pixel/API compatibility with Telerik is not claimed.

## Named form sections — 0.54 (2026-10-19, Linux on iMac)

NgForm accepts explicit NgFormSection descriptors with unique stable IDs, plain-text headings/descriptions and independent responsive layout settings. Section fields use the same layout implementation as flat fields. A single form owns validation, summary, disabled/busy behavior and submit actions. Whole-section reordering preserves editor state.

Validation completed:

- 389 Blazor checks: section rendering, escaped headings, independent layout settings, invalid IDs/titles/layout/spans and mutually exclusive content modes. Gallery build passed with zero warnings/errors.
- 231 Flutter tests and clean Dart analysis. New tests verify single-Form validation across sections, retained draft/focus/errors through reorder and resizing, guarded disabled content, semantic headings and rejected invalid descriptors.
- 47 Razor and 47 Dart manual examples compiled/analyzed; 94 lossless highlighting checks. Flutter Web build passed with the existing CupertinoIcons font warning.
- Foreground local Chrome: 19 Blazor and 16 Flutter section assertions. Headings/descriptions, independent span layout, section reorder, preserved drafts/errors, 390 px stacking without overflow and shared successful submit passed. Blazor also verifies one HTML form, legends and retained DOM focus; Flutter focus retention is covered by widget tests.
- Flat-field regression scenarios passed on both platforms: 18 assertions each via `scripts/form-spans-check.py`, including resize/span changes, retained values/errors and save. Total browser assertions: 71.
- Desktop shell opened the updated Form manual and switched its embedded live example to two named sections. Code and category navigation remained available. Screenshots were inspected directly.

Evidence: [Blazor reordered sections](screenshots/form054-blazor-sections.png), [Flutter narrow sections](screenshots/form054-flutter-narrow.png), [desktop manual](screenshots/form054-desktop-manual.png).

This stage provides one section level. Recursive groups, collapse/expand, automatic editors, conditional schemas and native/full screen-reader certification remain open. Removing sections and switching content modes have documented lifecycle and validation differences; the application owns persistence. Full Telerik API/pixel parity is not claimed.

## Nested form sections — 0.55 (2026-10-19, Linux on iMac)

NgFormSection can contain either fields or child sections. All descendants share the containing form's validation and submission. The complete tree is validated before rendering: exactly one content list, leaf-only spans, unique sibling IDs and a maximum depth of eight (cyclic trees also fail this bound). Existing leaf constructors remain usable; Fields/fields is now nullable for branches.

Validation completed:

- 398 Blazor checks: eight-level rendering, rejection at nine levels, cycles, mixed/missing node content, parent spans, duplicate child IDs, invalid descendants and reuse of IDs under different parents. Gallery build passed with zero warnings/errors.
- 234 Flutter tests and clean Dart analysis. New tests cover the same tree boundaries, one shared Form, parent/child sibling reorder with retained draft/focus/errors, responsive width and disabled descendants.
- 47 Razor and 47 Dart manual examples compiled/analyzed; 94 lossless highlighting checks. Flutter Web build passed with the existing CupertinoIcons font warning.
- Foreground local Chrome: 22 Blazor and 18 Flutter nested-section assertions. Parent headings/descriptions, descendant ordering, retained drafts/errors, leaf column spans, 390 px stacking without horizontal overflow and successful shared submit passed. Blazor additionally verifies a single form, all three legends, retained DOM focus and disabled descendant inputs.
- Previous one-level section scenarios passed again: 19 Blazor and 16 Flutter assertions. Total browser assertions: 75.
- Desktop shell opened the updated Form manual and activated the nested live example with one parent and two child sections. Code/category navigation remained available. Screenshots were inspected directly.

Evidence: [Blazor nested groups](screenshots/form055-blazor-nested.png), [Flutter narrow groups](screenshots/form055-flutter-narrow.png), [desktop manual](screenshots/form055-desktop-manual.png).

Moving nodes between parents or wrapping/unwrapping changes identity paths and may recreate editor state; persistence remains application-owned. Deep trees require enough width for custom field content. Collapse/expand, generated/conditional schemas and full native/screen-reader certification remain open. Full Telerik API/pixel parity is not claimed.

## Controlled form section expansion — 0.56 (2026-10-19, Linux on iMac)

NgFormSection adds Expanded/expanded (default true) and OnExpandedChanged/onExpandedChanged. A supplied callback creates a disclosure heading and requests the next state; the application decides whether to accept. Collapsed descendants remain mounted and registered for validation. Disabled/busy forms and collapsed ancestors guard toggles, including retained callbacks from replaced or disposed layouts.

Validation completed:

- 400 Blazor checks, including disclosure state/control attributes, retained hidden field content and disabled headings. Gallery build passed with zero warnings/errors.
- 237 Flutter tests and clean Dart analysis. New tests verify retained values/selection/errors, hidden required-field validation, removal of descendant focus, controlled rejection and guards for disabled/busy forms, collapsed ancestors, removed handlers and disposal.
- 47 Razor and 47 Dart manual examples compiled/analyzed; 94 lossless highlighting checks. Flutter Web build passed with the existing CupertinoIcons font warning.
- Foreground local Chrome: 27 Blazor and 23 Flutter expansion assertions. Independent leaf/parent collapse, retained child state/drafts/errors, hidden-field validation, save with collapsed valid fields, busy/disabled guards, reorder and 390 px layout all passed. Blazor also verifies mounted hidden inputs, aria-expanded/controls and Space activation.
- Nested-section regression scenarios passed: 22 Blazor and 18 Flutter assertions. Total browser assertions: 90. The test focus helpers wait for scrolling to settle before native clicks, preventing input into a different Flutter field during viewport movement.
- Desktop shell opened the updated Form manual and collapsed a child section in its nested live example. Screenshots were inspected directly.

Evidence: [Blazor collapsed errors](screenshots/form056-blazor-collapsed.png), [Flutter narrow disclosure](screenshots/form056-flutter-narrow.png), [desktop manual](screenshots/form056-desktop-manual.png).

Validation does not automatically expand invalid groups. Applications must keep hidden errors discoverable and manage focus when collapsing externally. Expansion is not conditional validation or authorization. Generated/conditional schemas and full native/screen-reader certification remain open; full Telerik API/pixel parity is not claimed.

## IME-aware text notifications — 0.57 (2026-10-19, Linux on iMac)

TextBox and TextArea suppress debounced notifications while text composition is active, including zero delay. Completion restarts the delay and notifies once even when the text string is unchanged. Draft binding and validation remain immediate. Native event observers are detached on disposal; Flutter retains framework-owned controller/reset behavior and also observes Web composition events because its semantics editing strategy can omit composing ranges.

Validation completed:

- 400 Blazor rendering/data checks and a gallery build with zero warnings/errors.
- 241 Flutter tests and clean Dart analysis. New tests cover both editors with framework-owned/external controllers, immediate draft changes, unchanged-string composition completion, same-text composition start during a pending delay, zero delay, locks and disposal. Existing debounce/reset regression tests pass.
- 47 Razor and 47 Dart manual examples compiled/analyzed; 94 lossless highlighting checks. Flutter Web build passed with the existing CupertinoIcons font warning.
- Visible local Chrome: 28 IME assertions per platform using CDP native composition and text insertion, including observed compositionstart/end, suppression, unchanged completion, zero delay, replacement/readonly cancellation, clear during composition and zero-delay clear. Flutter runs with browser semantics enabled, exercising the additional native event observer.
- Ordinary typing/debounce regression: 26 assertions per platform, including replacement, locks, delay changes, appearance rebuilds, clear and blur. Total editor browser assertions: 108.
- Desktop shell checked the 0.57 badge, IME manual content and nested live preview. Blazor, Flutter and desktop screenshots were inspected directly.

Evidence: [Blazor editor](screenshots/text057-blazor.png), [Flutter editor](screenshots/text057-flutter.png), [desktop manual](screenshots/text057-desktop-manual.png).

Physical OS IME keyboards, native mobile targets and assistive technology certification remain unverified. Commit/submission stays independent; already-started asynchronous application requests need their own stale-result protection. Full Telerik API/pixel parity is not claimed.

## Date range presets and atomic clearing — 0.58 (2026-10-19, Linux on iMac)

DateRangePicker adds named NgDateRangePreset descriptors, endpoint availability checks and optional localized clearing. A preset produces one complete range callback; clear produces null. Both actions reset the inner editors, repairing invalid drafts even when the accepted dates are unchanged. Actions honor current locks, bounds, disabled endpoints and descriptor membership. Flutter normalizes preset times to calendar dates; relative periods stay application-owned.

Validation completed:

- 405 Blazor rendering/data checks; gallery build passed with zero warnings/errors. New checks cover selected/disabled rendering, escaped labels and malformed descriptors (empty IDs/labels, duplicate IDs and reversed dates).
- 243 Flutter tests and clean Dart analysis. New tests cover atomic callback counts, date normalization, endpoint bounds/predicates, explicitly disabled periods, same-value draft repair, required clearing, malformed descriptors and retained callbacks after locking, disabling, descriptor removal, clear-action removal and disposal.
- 47 Razor and 47 Dart manual examples compiled/analyzed; 94 highlighting checks. Flutter Web build passed with the existing CupertinoIcons font warning.
- Foreground local Chrome: 21 assertions per platform (42 total). Checked initial state, unavailable periods, atomic selection, invalid/partial draft repair, validation recovery, weekend interiors, readonly/disabled guards, dynamic bounds, repeated clear and 390 px layout without horizontal overflow.
- Flutter semantics input values were read after native focus because inactive DOM text fields initially had empty value properties while the canvas displayed the dates. Both canvas screenshots and focused input values were inspected.
- Desktop shell verified the 0.58 badge, updated manual and a working preset in the embedded Blazor example. Both narrow layouts and the desktop screenshot were inspected directly.

Evidence: [Blazor narrow](screenshots/range058-blazor-narrow.png), [Flutter narrow](screenshots/range058-flutter-narrow.png), [desktop manual](screenshots/range058-desktop-manual.png).

Preset/clear resets close pickers and discard inner editor focus/selection. Date restrictions apply to endpoints, not interior days. Shared dual-calendar highlighting, relative-date engines, physical native targets and full accessibility certification remain open. Full Telerik API/pixel parity is not claimed.

## Configurable text counters — 0.59 (2026-10-19, Linux on iMac)

TextBox and TextArea add native/hidden/used/remaining modes and a plain-text count formatter. Native preserves existing platform defaults. Remaining requires a maximum; hidden never disables length enforcement. Counters follow draft updates, IME, clear, external replacement and native Flutter reset. Blazor counts UTF-16 units; Flutter counts grapheme clusters. Externally supplied overflow remains visible and is reported without truncation.

Validation completed:

- 410 Blazor rendering/data checks and a gallery build with zero warnings/errors. New checks cover Unicode overflow, helper/counter description IDs, polite live regions, escaped custom labels and invalid configurations.
- 247 Flutter tests and clean Dart analysis. Counter tests cover modes, composed emoji/combining marks, overflow, formatter updates, readonly replacement, hidden length enforcement, clear, unlimited counts and framework-owned form reset. The 12 counter/IME/debounce tests were rerun after the semantics correction.
- 47 Razor and 47 Dart manual examples compiled/analyzed; 94 highlighting checks. Flutter Web build passed with the existing CupertinoIcons font warning.
- Foreground local Chrome: 40 Blazor and 38 Flutter assertions (78 total), using native clicks after scroll settling. Verified Unicode differences, external overflow, custom/hidden/native counters, immediate clear/input updates, pending notifications across mode changes, native IME composition, readonly external replacement, hidden length enforcement and 390 px layout.
- Browser review found that a nested Flutter live-region wrapper lost its accessible counter text after focus. The implementation now uses TextField's own counter semantics; focused semantic-label widget checks and browser checks pass. Physical screen-reader output remains unverified.
- Desktop shell verified the 0.59 badge, counter manual and embedded live counter. Both narrow editor screenshots and the desktop screenshot were inspected directly.

Evidence: [Blazor counter](screenshots/count059-blazor.png), [Flutter counter](screenshots/count059-flutter.png), [desktop manual](screenshots/count059-desktop-manual.png).

Counter formatting receives counts rather than password text and must remain pure. Counters do not define a shared server length policy or add validation. Native targets and physical accessibility certification remain separate work; full Telerik API/pixel parity is not claimed.

## Remote Grid and lazy trees — 0.60 (2026-10-19, Linux on iMac)

- Grid async page/search adapters, stable ordered multi-sort, loading/error/retry, source-version invalidation, stale-response rejection and total shrink recovery.
- TreeView/TreeList lazy children, cached empty/successful branches, source invalidation, retry and duplicate-ID rejection. Expansion/selection locks rechecked after awaits.
- .NET build passed with zero warnings/errors; 416 rendering/data checks passed. Flutter analyze passed; all 254 tests passed, including 7 new async/data scenarios.
- All 94 manual examples compiled/analyzed; 94 highlighted examples passed. Web build passed (existing unused CupertinoIcons font warning).
- Dedicated foreground Chrome review060 on local Linux/iMac: both Web platforms passed remote page/search/sort/retry and both lazy-tree nested/cache/error/selection/reset scenarios. Evidence: artifacts/browser/data060-*.png; repeat with scripts/remote-data-check.py and its flutter argument.
- No full parity claim. Virtualization, grouping, built-in CRUD, drag/drop, checked tree selection and native/screen-reader validation remain open. Demo adapters simulate network delay; application transport is caller-owned.

## Independent tree checkboxes — 0.61 (2026-10-19, Linux on iMac)

- Optional TreeView/TreeList checked IDs, independent checking locks, per-node protection and localized checkbox names in Blazor and Flutter Web. No mutation/pruning of caller sets; no cascade or implicit lazy load.
- 422 .NET rendering/data checks; Blazor gallery build with zero warnings/errors. 258 Flutter tests passed, including controlled rejection/acceptance, hidden IDs, lazy caching, protected/disabled nodes, retained callbacks after collapse/hide/lock/disposal and keyboard Space without row selection.
- All 94 manual examples compiled/analyzed; 94 highlighting checks passed. Flutter Web build passed with the existing unused CupertinoIcons font warning.
- Visible local Chrome checks covered both tree controls and both Web frameworks: checking a lazy parent without loading/selecting, protected children, Space, preserved IDs and independent controls. Physical screen-reader/native certification remains unverified.
- Blazor controlled binding was verified with rejected pointer/Space changes in both controls: the DOM checkbox returns to the parent-owned state; acceptance still updates without selecting/loading.
- Browser review found merged checkbox/cell semantics in Flutter TreeList. Separate semantic containers fixed the issue; focused checkbox semantics and keyboard tests were rerun successfully.
- Public marketing sites remain deleted from Cloudflare. Local documentation/demo updates do not publish them.

## Cascading loaded tree checks — 0.62 (2026-10-19, Linux on iMac)

- TreeView/TreeList opt-in CheckChildren/checkChildren cascades over the parent record and eligible loaded descendants in one controlled callback. Protected/disabled nodes stop traversal into their subtrees. Mixed state selects the whole eligible branch; fully checked clears it. Unknown IDs are retained; no implicit fetching or upward normalization.
- 429 .NET rendering/data checks passed; gallery build passed without warnings/errors. 262 Flutter tests passed and clean analysis. Eight focused checking tests were rerun after the accessible-value addition. Tests cover rejected changes, partial aggregate semantics, protected subtrees, collapsed/filtered descendants, mode/lock changes, immutable input and newly loaded children without inherited marks/callbacks.
- All 47 Razor and 47 Dart manual examples compiled/analyzed; 94 lossless highlighting checks. Flutter Web build passed with the existing unused CupertinoIcons font warning.
- Visible Chrome on local Linux/iMac: Blazor and Flutter branch checks, keyboard Space, protected children, lazy nested loading, partial states, rejected proposals and filtering/collapse retention checked. No row selection was triggered by checkbox actions. Blazor native indeterminate indicators were visually inspected.
- Current Flutter Web SDK's legacy checkbox role maps internal CheckedState.mixed to aria-checked=false. The visual dash and internal semantics are correct; partialCheckText adds a localized accessible value. Exact Web ARIA mixed-state parity and physical screen-reader output remain unverified; the SDK was not modified.
- Public Cloudflare sites remain deleted. Local demos/documentation only; check-all, full-remote cascades, upward normalization, virtualization and drag/drop remain open.

## Bulk loaded-tree checking — 0.63 (2026-10-19, Linux on iMac)

- Optional localized check-loaded/clear-loaded actions in TreeView and TreeList on both Web platforms. Full loaded-forest scope is explicit and independent of search, collapse and per-node cascade mode; disabled/protected subtrees and unknown IDs are preserved. No implicit loading or row-selection change.
- 433 .NET rendering/data checks and gallery build without warnings/errors. 264 Flutter tests passed; analysis clean. New tests cover atomic proposed sets and rejection, protected subtrees, hidden/unknown IDs, lazy child arrival, filtered scope, disabled/no-op actions and stale callbacks after locking, hiding, source replacement and disposal.
- All 94 manual examples compiled/analyzed and 94 highlighting checks passed. Flutter Web build passed with the existing unused CupertinoIcons font warning.
- Visible Chrome checks exercised both platforms and both tree controls: parent rejection/acceptance, keyboard actions, lazy-load availability, filtering/collapse-independent scope, checking locks and preservation of an already checked protected node when clearing. Updated local desktop documentation includes the new API and live examples.
- Full-remote checking, upward normalization, virtualization, drag/drop and physical screen-reader/native validation remain open. The Flutter Web mixed-state ARIA limitation from 0.62 is unchanged. Cloudflare sites remain deleted.

## Local Grid grouping (0.64) — 2026-10-20

- Blazor library/gallery build passed with zero warnings/errors; 439 rendering/data checks passed. Added first-appearance/case-sensitive/empty key order, within-group order, null-key rejection, encoded group captions and remote-adapter rejection before requests.
- Flutter analysis passed; all 266 tests passed. New grouping regression covers headers across page boundaries, full filtered counts, data-only page selection with protected/off-page IDs, sorting/search composition, mode/version resets, shrinking data, empty results and invalid remote configuration without requests.
- All 47 Blazor and 47 Flutter manual examples compile/analyze; 94 lossless highlighting checks passed. Flutter release Web build passed with the existing CupertinoIcons font-family warning.
- Ordinary visible Chrome on local Linux/iMac, controlled through CUA: both Grid previews showed 20 matching Chair records with five data rows per page; page 2 repeated the full group count. Selected page-1 IDs survived paging and Desk filtering. Quantity ascending/descending changed row order; protected high-quantity rows remained disabled. Disabling grouping removed headers. Both layouts were visually inspected.
- Local desktop documentation reports 0.64 and includes the GroupBy manual plus a live preview. Documentation tab left open; browser automation slot released.
- Scope: one local grouping level only. No collapse, aggregates, multiple levels, remote grouping, virtualization, native target or full screen-reader certification claim. Cloudflare sites were not republished.

## Local grouping workspace (0.65) — 2026-10-20

This delivery combines nested local grouping, controlled collapse/expand, filtered bulk expansion, group summaries and demo configuration as one functional block.

- .NET library/gallery build: zero warnings/errors. All 451 rendering/data checks passed, including path identity, nested order, aggregate operations, invalid depth/operation, escaped summaries and externally collapsed/locked rendering.
- Flutter: complete 270-test suite passed. After the browser found unnamed toggle buttons, the semantic label and expanded state were moved into the native TextButton; the four grouping-workspace tests were rerun successfully, including explicit button/expanded semantic flags. Final static analysis is clean. Targeted scenarios cover rejected callbacks, immutable proposals, stale actions after lock/filter/mode changes, protected/hidden selection, empty aggregates, page stability and filtered bulk scope.
- All 94 manual examples compile/analyze; all 94 highlighting checks pass. Final Flutter Web release build passed with the pre-existing CupertinoIcons font-family warning.
- Ordinary visible Chrome on local Linux/iMac, CUA-controlled, both previews: two group levels; Chair total 1600 / average 80 and Available total 576 / average 48; Desk filtering gives total 1680 / average 84 and Available total 624 / average 52. Descending quantity moves Protected records first with subgroup total 1056 / average 132. Full counts/summaries remain independent of the five-row page.
- Both browsers: page selection survives keyboard collapse; the fully collapsed page has no selectable data rows, retains its range and repeats collapsed headers on page 2. Bulk expansion restores rows; bulk collapse and the independent expansion lock work. Single-level switching removes nested headers without losing sorting. Flutter Web now exposes named toggle buttons and expanded state on the actual button, verified after rebuilding. Both layouts visually inspected.
- Desktop manual reports 0.65, has readable grouping/expansion/summary sections and a live preview. Manual/model contracts document numeric null/nonfinite behavior, full-path IDs, caller-owned state and post-paging collapse. The documentation tab is left open; the Chrome slot is released.
- Scope limits: local grouping only (maximum eight levels); no remote group protocol, virtualization, built-in CRUD, drag-to-group UI, native target or physical screen-reader certification. Aggregates use double precision. Cloudflare sites remain unpublished; this task did not alter Cloudflare.

## Remote grouped Grid and real HTTP adapters (0.66) — 2026-10-20

- .NET gallery/library builds passed with zero warnings/errors; all 464 rendering/data checks passed. Added reference adapter, full-count/weighted-summary validation, duplicate/missing metadata, invalid counts, interleaved paths, wrong page lengths and grouped error/retry rendering.
- Flutter analysis is clean and all 274 tests passed. Grouped tests cover immutable requests/results, JSON decoding, complete metadata, nonfinite/duplicate summaries, incompatible modes before requests, stale success/error handling, reader-key/version changes, selection, collapse without requests, retry, shrinking totals and disposal.
- All 47 Blazor and 47 Flutter manual examples compile/analyze, including actual HTTP transports. All 94 highlighting checks pass. Flutter release Web build succeeded with the existing CupertinoIcons font warning.
- `python3 scripts/check_grouped_api.py` passed 13 scenarios against the running local API: full counts/aggregates, page-boundary paths, descending sort, search, one-level grouping, empty search, seven-record shrink, 503 errors, deliberately malformed metadata and rejected invalid queries. The endpoint serves synthetic data only and allows the local Flutter origin through explicit CORS.
- Ordinary visible Chrome on local Linux/iMac via CUA: both galleries successfully used the same HTTP endpoint. Initial Chair count 20 / quantity total 1600 / average 80 and Available count 12 / total 576 / average 48 were shown for five downloaded records. Page selection remained stored while groups collapsed; collapse did not increment the HTTP request counter, and page-selection controls became disabled when all rows were hidden.
- Blazor: page 2 retained collapse state; malformed metadata displayed only error/retry with no partial records; Retry restored data. Shrinking the dataset from page 8 through a page-7 read caused a corrected page-2 read and showed 6–7 of 7. Search Desk, descending quantity and switching to one level produced server totals 1680 / average 84 with rows 160, 152, 144, 136, 128.
- Flutter: 503 and malformed responses cleared rows and metadata; Retry recovered each. Shrinking from the last page corrected to page 2 and displayed 6–7 of 7, Desk count 3 / total 48 / average 16. Group-key changes requested page 1 with the new depth. Both layouts were visually inspected. Desktop manual reports 0.66 and links to the rendered JSON request/response, validation, lifecycle and HTTP exercise guide.
- Scope: record-page remote grouping, not lazy group paging or virtual scrolling. Group bulk actions cover only paths in the current response. The client checks metadata consistency; the backend remains responsible for truth of totals, query translation and snapshot consistency. No database provider, CRUD, export, native target or physical screen-reader certification is claimed. Cloudflare was not changed. The documentation tab is retained and the Chrome automation slot released.

## Grid create, edit and delete workflows (0.67) — 2026-10-20

- Library/gallery builds pass with zero .NET warnings/errors. All 479 .NET rendering/data checks pass, including isolated drafts, required/custom validation, create/update/confirmed delete, cancel, single-flight persistence, safe failures, retained drafts, server messages, current permissions, removed records and ignored obsolete completions.
- Full Flutter suite: 278 tests pass. The four new workflow tests additionally cover immutable commit maps and remote deletion with last-page correction. Flutter analysis is clean. Editing tests passed again after the final panel layout adjustment.
- All 94 manual examples compile/analyze; all 94 lossless highlighting checks pass. Flutter Web release builds pass with the existing CupertinoIcons font-family warning. The documentation, generated previews and code-browser assets include the complete editable inventory example.
- Visible ordinary Chrome on local Linux/iMac via CUA: Blazor and Flutter both exercised required validation, invalid negative quantity, creation, editing, generic persistence failure, retained draft/retry, cancelled deletion and confirmed deletion. Protected records expose disabled actions. Blazor additionally exercised duplicate-name server rejection and a live editing lock, then verified the corrected parent successful-write counter. Flutter showed Lamp quantity 7 after retry and removed it after confirmation; successful-write count reached 3.
- Both inline editor layouts and the new rendered Grid editing manual were inspected. Browser automation uses separate disposable demo pages; reload resets their synthetic records. Remote refresh/page correction is automated widget coverage, not a production database test.
- Scope: text-field descriptors, inline single-record editing and application-owned persistence. No batch/cell editing, custom editor widget templates, bundled write API/database provider, native/mobile or physical screen-reader certification. Backend authorization, concurrency and idempotency remain application responsibilities. Public Cloudflare sites were not changed.
