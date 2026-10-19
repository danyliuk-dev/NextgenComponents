# Nextgen Components

Blazor and Flutter component libraries with a shared design-token source and a Telerik Blazor component roadmap.

**Current release: 0.62.0 cascading tree checkboxes, 47 controls on each Web platform (53 catalogue entries including chart modes).** This is not a complete Telerik replacement or API-compatible clone. The [catalog](docs/catalog.md) tracks 139 named entries from the published Telerik Blazor index; chart variants are counted separately. See [foundation capabilities](docs/foundation.md) and [forms/date capabilities](docs/forms-and-dates.md) and [data workspace capabilities and gaps](docs/data-workspace.md) and [analytics/schedule capabilities](docs/analytics-and-schedule.md).

## Manual

[English developer manual](docs/manual/README.md): all 47 components, behavior, parameters, events and working Blazor/Flutter examples. Start with [Getting started](docs/manual/getting-started.md) and [Code examples](docs/manual/code-examples.md). Both demos include an interactive code browser. The local manual has a searchable category tree on the left, syntax-highlighted examples, and a live appearance preview for every component. Switch between Blazor and Flutter Web, try the component, reload its state, or open it full-page. Both local demos must be running.

## Layout

- `src/NextgenComponents.Blazor` — Razor component library, namespace `NextgenComponents.Blazor`.
- `packages/nextgen_components` — native Flutter widgets, import `package:nextgen_components/nextgen_components.dart`.
- `design/tokens.json` — shared light/dark colors, radii and density dimensions.
- `examples/BlazorGallery` and `examples/flutter_gallery` — interactive galleries.
- `docs/catalog.json` — machine-readable coverage and source links.

## Run

Requires .NET 10 and Flutter >= 3.38 with Dart >= 3.10. Dependencies must be restored before offline runs.

```sh
python3 scripts/generate_theme.py
dotnet run --project examples/BlazorGallery --urls http://127.0.0.1:5180
```

Flutter, from `examples/flutter_gallery`:

```sh
flutter pub get
flutter run -d chrome --web-port 5181
```

For a standalone web build (including local renderer assets):

```sh
flutter build web --no-web-resources-cdn
python3 -m http.server 5181 --bind 127.0.0.1 --directory build/web
```

## Linux desktop launcher

```sh
python3 scripts/install_desktop_launcher.py
```

Creates **Nextgen Components** on the desktop and in the applications menu. It opens a dedicated Chrome app window with Documentation, Blazor demo and Flutter demo sections. Each section retains its page and in-memory state while switching; Reload resets the active demo to its entry page (documentation reload preserves the page). Open in browser opens the active documentation page or demo entry page. Closing the window leaves the local services running. This is a Linux desktop shell for the Web demos, not a native Flutter Desktop build.

Run without installing a shortcut:

```bash
python3 scripts/desktop_launcher.py --desktop
```

The app uses its own Chrome profile under `artifacts/launcher/chrome-profile`; personal tabs are separate. Desktop shortcut actions select the initial section. A manual-only browser launch remains available with `python3 scripts/desktop_launcher.py --page manual`. The desktop shell starts both demos so all three sections are available.

The launcher starts missing services on loopback ports 5180–5182 through the user systemd manager and reuses running galleries. It does not replace unrelated processes on occupied ports. Logs: `artifacts/launcher/`. Existing demo builds are reused; after source changes rebuild the galleries using the commands above. Missing builds are built on first launch (.NET/Flutter SDK required). Documentation reads the current Markdown files without a separate build.

Requirements: Linux desktop with Google Chrome, user systemd, Python 3 and `markdown_it` (Ubuntu package `python3-markdown-it`). Optional `notify-send` reports launch errors. Install again if the repository moves. The launcher does not run at login. To stop servers it started: `systemctl --user stop nextgen-components-blazor nextgen-components-flutter nextgen-components-documentation`. Previously running servers are left under their original owner.

## Use in Blazor

Reference the library project/package and load `_content/NextgenComponents.Blazor/nextgen.css`. Wrap your UI in `.ng-scope`; set `data-ng-theme="light"` or `"dark"`, and optionally `data-ng-density="compact"`. Use an interactive Blazor render mode for callbacks, tabs and dialogs.

```razor
@using NextgenComponents.Blazor
<div class="ng-scope" data-ng-theme="light">
    <NgTextBox Label="Name" @bind-Value="name" />
    <NgButton Primary OnClick="Save">Save</NgButton>
</div>
@code {
    private string? name;
    private void Save() { /* application action */ }
}
```

Inputs integrate with `EditForm`. Use application model validation attributes for business rules. The gallery demonstrates `Required` and `Range`.

## Use in Flutter

Add a path dependency on `packages/nextgen_components` (or your published package), apply `NgTheme.light()` / `NgTheme.dark()` to `MaterialApp`, and use controlled values/callbacks. `NgTextBox` and `NgNumericTextBox` integrate with `Form`.

```dart
NgButton(primary: true, onPressed: save, child: const Text('Save'))
```

## Checks

```sh
dotnet build -m:1
dotnet run --project tests/BlazorChecks
node tests/pdf/text-search.test.mjs
python3 scripts/sync_pdf_assets.py --check
python3 scripts/sync_map_assets.py --check
node tests/map/clusters.test.mjs
cd packages/nextgen_components
flutter analyze
flutter test
```

`BlazorChecks` verifies server-rendered output and accessibility attributes; it does not replace real browser interaction tests. Visual review must use visible Chrome locally on Linux on iMac. See [verification](docs/verification.md) for this run's actual results.

## Feature parity tracking

**47 implemented components does not mean 47 complete Telerik equivalents.** See the [feature parity matrix](docs/parity.md) for implementation, verification and remaining work separately. No component currently carries a full-parity claim. Existing groups are audited and completed before adding new component names; Chip/ChipList is the first detailed audit in this process.

## Roadmap

1. Shared theme, catalog, 11 foundation components and galleries (implemented subset).
2. Forms and dates: 11 more controls and a complete booking example (0.2 implemented subset). Stepper and Wizard added in 0.11: [workflow capabilities](docs/steps-and-wizard.md). Menu and Drawer added in 0.12: [navigation capabilities](docs/navigation.md). ToggleButton and ButtonGroup added in 0.13: [selection capabilities](docs/selection.md). Chip and ChipList added in 0.14: [tag capabilities](docs/chips.md). Remaining input/layout features stay in the catalogue.
3. Grid, TreeList, TreeView, Pager and Breadcrumb (0.3 implemented subset); advanced data features remain in the capability matrix.
4. Charts (six modes), linear/arc gauges and weekly scheduling (0.4 implemented subset); advanced visualization and scheduling remain planned.
5. Spreadsheet and PivotGrid: linked workbook (0.5 implemented subset). Structured document editor (0.6 implemented subset); see [editor capabilities](docs/editor.md). Interactive diagrams (0.7 implemented subset); see [diagram capabilities](docs/diagram.md). PDF Viewer (0.8 implemented subset); see [PDF capabilities](docs/pdf-viewer.md). Map (0.9 implemented subset); see [Map capabilities](docs/map.md). AI Prompt and PromptBox (0.10 implemented subset); see [AI interface capabilities](docs/ai-interface.md). Full rich-text editing and advanced AI integrations remain planned.

Each planned component needs a feature-level audit of its reference before implementation. Basic rendering is not completion: sorting/filtering/editing, keyboard behavior, accessibility, localization and performance must be tracked where applicable.

## Source and licensing

This repository currently contains original component implementations; no Telerik component source or theme package is vendored. Telerik Default is a visual reference. Styling is an initial approximation, not a verified pixel match. See [provenance](docs/provenance.md).

## Maintaining component previews

`python3 scripts/generate_manual.py` generates every component page, code assets and runnable previews from `scripts/manual_content.py`. Add a curated Blazor and Flutter snippet for each new public component; the generator rejects missing manuals. Previews execute those exact snippets, so code and appearance share one source. Do not edit the generated `ManualPreviews/*Example.razor` or `manual_previews.g.dart` files directly.

Build both galleries after regeneration. The local documentation embeds `/preview/NgComponent` (Blazor) or `/?preview=NgComponent` (Flutter). Static Markdown readers receive links to these same examples. Previews are local, stateful examples; Reload example resets them. Modal/tooltip examples require their documented trigger. The visible Chrome smoke runner is `node scripts/manual-preview-check.mjs blazor` or `flutter`; coordinate Chrome use first. It saves runtime diagnostics and screenshots under ignored `artifacts/browser/manual-*` for visual review.
