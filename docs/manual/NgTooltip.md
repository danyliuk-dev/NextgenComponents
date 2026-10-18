# NgTooltip — Tooltip

[Manual](README.md) · [Getting started](getting-started.md) · [Code examples](code-examples.md) · [Models](models.md)

## When to use it

Explain a control with a short nonessential hint.

## Behavior and practical rules

Supply Text/text and the child control. Tooltips are supplementary: the child still needs an accessible name and essential instructions must remain visible. Use pointer hover or keyboard focus to reveal the hint. Do not place form fields, actions or long documents inside a tooltip.

## Blazor example

```razor
<NgTooltip Text="Create a copy"><NgButton>Copy</NgButton></NgTooltip>
```

## Flutter example

```dart
Widget build(BuildContext context) => NgTooltip(text: 'Create a copy',
  child: NgButton(onPressed: () {}, child: const Text('Copy')));
```

## Blazor parameters and events

Names are case-sensitive. `?` permits null. `EditorRequired` parameters are marked required; other values use the initializer or CLR default.

| Parameter | Type | Default / requirement | Purpose |
|---|---|---|---|
| `Text` | `string` | "" | See the behavior rules and model contract above. |
| `ChildContent` | `RenderFragment?` | not set | Razor content; for a wizard, a RenderFragment<int> receiving the active index. |

## Flutter parameters and events

`required` marks a mandatory argument even if its type is nullable. `key` is the standard Flutter Key. The exact constructor below specifies defaults.

| Argument | Type | Purpose |
|---|---|---|
| `text` | `String` | See the behavior rules and model contract above. |
| `child` | `Widget` | See the behavior rules and model contract above. |

```dart
const NgTooltip({super.key, required this.text, required this.child});
```

## Integration and troubleshooting

If the UI does not update, confirm that the parent stores callback values and passes them back. Blazor event handlers need interactive rendering; Flutter requires setState or a state manager. Submit form data only after successful validation.

Check accessible labels, empty/invalid states, disabled actions and narrow layouts. Keyboard support is not full screen-reader certification. Current visual verification targets Web in visible Chrome on Linux/iMac; native mobile platforms are a separate phase.

## Source and complete examples

- [Blazor source](../../src/NextgenComponents.Blazor/NgTooltip.razor)
- [Flutter source](../../packages/nextgen_components/lib/src/components.dart)
- [Galleries and launch commands](../../README.md#run)
- [Capability matrix](../catalog.md)

API declarations are generated from current source. Curated examples and behavior live in `scripts/manual_content.py`; regenerate with `python3 scripts/generate_manual.py`.
