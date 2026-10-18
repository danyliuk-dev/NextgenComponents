# NgBreadcrumb — Breadcrumb

[Manual](README.md) · [Getting started](getting-started.md) · [Code examples](code-examples.md) · [Models](models.md)

## When to use it

Navigate the ancestors of the current location.

## Behavior and practical rules

Each NgBreadcrumbItem has an ID and visible label. The final item represents the current page. OnNavigate/onNavigate reports the ancestor ID; route navigation belongs to the host application. Keep IDs stable and do not use labels as database keys.

## Blazor example

```razor
<NgBreadcrumb Items="items" OnNavigate="id=>selected=id"/>
<p>@selected</p>
@code { private string? selected; private NgBreadcrumbItem[] items=[new("all","Projects"),new("design","Design")]; }
```

## Flutter example

```dart
String? selected;
Widget build(BuildContext context) => NgBreadcrumb(
  items: const [NgBreadcrumbItem('all','Projects'),NgBreadcrumbItem('design','Design')],
  onNavigate: (id) => setState(() => selected = id));
```

## Blazor parameters and events

Names are case-sensitive. `?` permits null. `EditorRequired` parameters are marked required; other values use the initializer or CLR default.

| Parameter | Type | Default / requirement | Purpose |
|---|---|---|---|
| `Label` | `string` | "Breadcrumb" | Visible label or accessible name. |
| `Items` | `IReadOnlyList<NgBreadcrumbItem>` | [] | Input collection. Replace it when changing records or configuration. |
| `OnNavigate` | `EventCallback<string>` | not set | See the behavior rules and model contract above. |

## Flutter parameters and events

`required` marks a mandatory argument even if its type is nullable. `key` is the standard Flutter Key. The exact constructor below specifies defaults.

| Argument | Type | Purpose |
|---|---|---|
| `items` | `List<NgBreadcrumbItem>` | Input collection. Replace it when changing records or configuration. |
| `onNavigate` | `ValueChanged<String>` | See the behavior rules and model contract above. |

```dart
const NgBreadcrumb({
    super.key,
    required this.items,
    required this.onNavigate,
  });
```

## Integration and troubleshooting

If the UI does not update, confirm that the parent stores callback values and passes them back. Blazor event handlers need interactive rendering; Flutter requires setState or a state manager. Submit form data only after successful validation.

Check accessible labels, empty/invalid states, disabled actions and narrow layouts. Keyboard support is not full screen-reader certification. Current visual verification targets Web in visible Chrome on Linux/iMac; native mobile platforms are a separate phase.

## Source and complete examples

- [Blazor source](../../src/NextgenComponents.Blazor/NgBreadcrumb.razor)
- [Flutter source](../../packages/nextgen_components/lib/src/data.dart)
- [Galleries and launch commands](../../README.md#run)
- [Capability matrix](../catalog.md)

API declarations are generated from current source. Curated examples and behavior live in `scripts/manual_content.py`; regenerate with `python3 scripts/generate_manual.py`.
