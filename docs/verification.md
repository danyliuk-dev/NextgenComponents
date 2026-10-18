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
