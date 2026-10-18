# Nextgen Components

Native Blazor and Flutter foundation libraries with a shared design-token source and a Telerik Blazor component roadmap.

**Current release: 0.1 foundation, 11 components on each platform.** This is not a complete Telerik replacement or API-compatible clone. The [catalog](docs/catalog.md) tracks 139 named entries from the published Telerik Blazor index; chart variants are counted separately. See [implemented capabilities and gaps](docs/foundation.md).

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
cd packages/nextgen_components
flutter analyze
flutter test
```

`BlazorChecks` verifies server-rendered output and accessibility attributes; it does not replace real browser interaction tests. Visual review must use visible Chrome locally on Linux on iMac. See [verification](docs/verification.md) for this run's actual results.

## Roadmap

1. Shared theme, catalog, 11 foundation components and galleries (current scope).
2. Calendars, remaining inputs/forms and layout primitives.
3. Grid, TreeList, TreeView and data/navigation features.
4. Charts, gauges and scheduling.
5. Editors, Spreadsheet, PDF Viewer, PivotGrid, diagrams, maps and AI interfaces.

Each planned component needs a feature-level audit of its reference before implementation. Basic rendering is not completion: sorting/filtering/editing, keyboard behavior, accessibility, localization and performance must be tracked where applicable.

## Source and licensing

This repository currently contains original component implementations; no Telerik component source or theme package is vendored. Telerik Default is a visual reference. Styling is an initial approximation, not a verified pixel match. See [provenance](docs/provenance.md).
