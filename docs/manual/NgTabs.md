# NgTabs — Tabs

[Manual](README.md) · [Getting started](getting-started.md) · [Code examples](code-examples.md) · [Models](models.md)

## When to use it

Switch between related content panels.

## Behavior and practical rules

NgTab contains label and content; disabled tabs cannot be activated. SelectedIndex is zero-based and controlled by the parent. Store selection callbacks. Blazor connects tab IDs, aria-controls and panel labels, and installs its keyboard behavior through the packaged JS module; interactive rendering and static assets are required. Flutter uses its platform focus behavior. Keep business state in the parent rather than depending on the lifetime of a panel widget.

## Blazor example

```razor
<NgTabs Items="tabs" @bind-SelectedIndex="index"/>
@code { private int index; private NgTab[] tabs=[new("Overview",b=>b.AddContent(0,"Summary")),new("Details",b=>b.AddContent(0,"Details"))]; }
```

## Flutter example

```dart
int index = 0;
Widget build(BuildContext context) => NgTabs(selectedIndex: index,
  items: const [NgTab('Overview',Text('Summary')),NgTab('Details',Text('Details'))],
  onChanged: (v) => setState(() => index = v));
```

## Blazor parameters and events

Names are case-sensitive. `?` permits null. `EditorRequired` parameters are marked required; other values use the initializer or CLR default.

| Parameter | Type | Default / requirement | Purpose |
|---|---|---|---|
| `Label` | `string` | "Tabs" | Visible label or accessible name. |
| `Items` | `IReadOnlyList<NgTab>` | [] | Input collection. Replace it when changing records or configuration. |
| `SelectedIndex` | `int` | 0 | See the behavior rules and model contract above. |
| `SelectedIndexChanged` | `EventCallback<int>` | not set | See the behavior rules and model contract above. |

## Flutter parameters and events

`required` marks a mandatory argument even if its type is nullable. `key` is the standard Flutter Key. The exact constructor below specifies defaults.

| Argument | Type | Purpose |
|---|---|---|
| `items` | `List<NgTab>` | Input collection. Replace it when changing records or configuration. |
| `selectedIndex` | `int` | See the behavior rules and model contract above. |
| `onChanged` | `ValueChanged<int>?` | Store the new value using setState or your state manager. |

```dart
const NgTabs({
    super.key,
    required this.items,
    this.selectedIndex = 0,
    this.onChanged,
  });
```

## Integration and troubleshooting

If the UI does not update, confirm that the parent stores callback values and passes them back. Blazor event handlers need interactive rendering; Flutter requires setState or a state manager. Submit form data only after successful validation.

Check accessible labels, empty/invalid states, disabled actions and narrow layouts. Keyboard support is not full screen-reader certification. Current visual verification targets Web in visible Chrome on Linux/iMac; native mobile platforms are a separate phase.

## Source and complete examples

- [Blazor source](../../src/NextgenComponents.Blazor/NgTabs.razor)
- [Flutter source](../../packages/nextgen_components/lib/src/components.dart)
- [Galleries and launch commands](../../README.md#run)
- [Capability matrix](../catalog.md)

API declarations are generated from current source. Curated examples and behavior live in `scripts/manual_content.py`; regenerate with `python3 scripts/generate_manual.py`.
