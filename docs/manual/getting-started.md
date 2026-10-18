# Getting started

[Manual](README.md) · [Code examples](code-examples.md)

NextgenComponents is a UI library. Your application owns data, persistence, authentication and external AI calls. Use the components in an existing host or run the included galleries as complete working applications.

## Blazor: install and host

Requires .NET 10. Add the project reference from your application directory, adjusting the path to your checkout:

```bash
dotnet add reference /path/to/NextgenComponents/src/NextgenComponents.Blazor/NextgenComponents.Blazor.csproj
```

Add `@using NextgenComponents.Blazor` to `_Imports.razor`. In the host document include:

```html
<link rel="stylesheet" href="_content/NextgenComponents.Blazor/nextgen.css" />
```

Register interactive rendering in `Program.cs` (using your application's App component):

```csharp
builder.Services.AddRazorComponents().AddInteractiveServerComponents();
// After builder.Build(), use your normal middleware and static asset setup.
app.MapStaticAssets();
app.MapRazorComponents<App>().AddInteractiveServerRenderMode();
```

The host must load `_framework/blazor.web.js`. The gallery's [Program.cs](../../examples/BlazorGallery/Program.cs) and [App.razor](../../examples/BlazorGallery/Components/App.razor) show the complete setup, including PDF/Map asset MIME types.

Create a Razor page:

```razor
@page "/example"
@using NextgenComponents.Blazor
@using static Microsoft.AspNetCore.Components.Web.RenderMode
@rendermode InteractiveServer
<div class="ng-scope" data-ng-theme="light" data-ng-density="normal">
    <NgTextBox Label="Name" @bind-Value="name" />
    <NgButton Primary OnClick="Save">Save</NgButton>
    <p>@status</p>
</div>
@code {
    private string? name;
    private string? status;
    private void Save() => status = $"Hello, {name}";
}
```

If the host already makes routes interactive, omit the page's `@rendermode`. Static SSR alone renders markup but does not run browser event callbacks.

`@bind-Value` supplies Value, ValueChanged and ValueExpression. With manual binding to InputBase/InputSelect/InputNumber wrappers, provide `ValueExpression="()=>model.Field"`, even outside a form. For a string parameter use `Value="@variable"`; `Value="variable"` may pass literal text.

Apply `data-ng-theme="light"` or `"dark"` and `data-ng-density="normal"` or `"compact"` to the outer `.ng-scope`. Shared tokens keep colors and focus states consistent.

## Flutter: install and host

Requires Flutter >= 3.38 and Dart >= 3.10. Add a path dependency relative to your application's pubspec.yaml:

```yaml
dependencies:
  flutter:
    sdk: flutter
  nextgen_components:
    path: ../../packages/nextgen_components
```

Run `flutter pub get`. A complete application shell:

```dart
import 'package:flutter/material.dart';
import 'package:nextgen_components/nextgen_components.dart';

void main() => runApp(MaterialApp(
  theme: NgTheme.light(), darkTheme: NgTheme.dark(),
  home: const Demo(),
));
class Demo extends StatefulWidget {
  const Demo({super.key});
  @override State<Demo> createState() => _DemoState();
}
class _DemoState extends State<Demo> {
  bool enabled = true;
  @override Widget build(BuildContext context) => Scaffold(
    body: Padding(padding: const EdgeInsets.all(24), child: NgSwitch(
      label: 'Notifications', value: enabled,
      onChanged: (v) => setState(() => enabled = v),
    )),
  );
}
```

Use `NgTheme.light(compact: true)` and its dark equivalent for compact density. Component-page Flutter examples are fields and methods inside a State class such as `_DemoState`; do not combine several build methods. Import Material for Text, Widget and BuildContext.

Most components use `value → action → onChanged → setState → new value`. Store callback values or the component will retain the old state. For text fields, initialValue is only the initial draft. Use TextEditingController for programmatic changes, never combine it with initialValue, and dispose it in its owner.

## Forms and persistence

1. Keep an editable draft separate from the saved record.
2. Wrap validated fields in NgForm: DataAnnotations in Blazor, validator/required in Flutter.
3. On successful validation call your own save service. Display network errors separately from field parsing errors.
4. Cancel discards the draft; Save replaces the changed record and its collection.
5. Use stable unique IDs and replace input collections instead of mutating them silently.

Blazor dates use DateOnly/TimeOnly/DateTime; Flutter uses DateTime/TimeOfDay. Normalize timezones at application boundaries.

## Run the included applications

```bash
dotnet run --project examples/BlazorGallery --urls http://127.0.0.1:5180
```

In `examples/flutter_gallery`:

```bash
flutter pub get
flutter run -d chrome --web-port 5181
```

Use **Code examples** in either gallery or the desktop portal. Documentation links in the local demos point to port 5182. To serve the manual without opening a browser, run `python3 scripts/desktop_launcher.py --page manual --no-browser`. The portal starts the local demos and serves these manuals. Native/mobile validation remains a separate phase; current evidence is in [verification](../verification.md).
