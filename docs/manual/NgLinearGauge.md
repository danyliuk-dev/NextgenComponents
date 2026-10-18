# NgLinearGauge — Linear gauge

[Manual](README.md) · [Getting started](getting-started.md) · [Code examples](code-examples.md) · [Models](models.md)

## When to use it

Display a value within a numeric range.

## Appearance and live example

[Try the Blazor example](http://127.0.0.1:5180/preview/NgLinearGauge) · [Try the Flutter Web example](http://127.0.0.1:5181/?preview=NgLinearGauge)

The documentation launcher embeds these running examples here. Choose a framework, interact with the component, and compare it with the exact code below. Use Reload example to restore the initial state. Dialogs and drawers start closed; use their Open button. Tooltips appear on hover or keyboard focus.

## Behavior and practical rules

Min must be less than Max and values must be finite. The gauge projects the configured value into the range; keep the original business value in the parent. Label and Unit explain the number without relying on color. This is a read-only display, not an input or a multi-scale gauge. Use the shared theme for light/dark contrast.

## Blazor example

```razor
<NgLinearGauge Label="Load" Value="72" Min="0" Max="100" Unit="%"/>
```

## Flutter example

```dart
Widget build(BuildContext context) => const NgLinearGauge(label: 'Load',
  value: 72, min: 0, max: 100, unit: '%');
```

## Blazor parameters and events

Names are case-sensitive. `?` permits null. `EditorRequired` parameters are marked required; other values use the initializer or CLR default.

| Parameter | Type | Default / requirement | Purpose |
|---|---|---|---|
| `Label` | `string` | "Progress" | Visible label or accessible name. |
| `Value` | `double` | 0 | Current value; see state ownership and model rules above. |
| `Min` | `double` | 0 | Inclusive minimum. |
| `Max` | `double` | 100 | Inclusive maximum. |
| `Unit` | `string` | "%" | See the behavior rules and model contract above. |

## Flutter parameters and events

`required` marks a mandatory argument even if its type is nullable. `key` is the standard Flutter Key. The exact constructor below specifies defaults.

| Argument | Type | Purpose |
|---|---|---|
| `label` | `String` | Visible label or accessible name. |
| `unit` | `String` | See the behavior rules and model contract above. |
| `value` | `double` | Current value; see state ownership and model rules above. |
| `min` | `double` | Inclusive minimum. |
| `max` | `double` | Inclusive maximum. |

```dart
const NgLinearGauge({
    super.key,
    this.label = 'Progress',
    required this.value,
    this.min = 0,
    this.max = 100,
    this.unit = '%',
  });
```

## Integration and troubleshooting

If the UI does not update, confirm that the parent stores callback values and passes them back. Blazor event handlers need interactive rendering; Flutter requires setState or a state manager. Submit form data only after successful validation.

Check accessible labels, empty/invalid states, disabled actions and narrow layouts. Keyboard support is not full screen-reader certification. Current visual verification targets Web in visible Chrome on Linux/iMac; native mobile platforms are a separate phase.

## Source and complete examples

- [Blazor source](../../src/NextgenComponents.Blazor/NgLinearGauge.razor)
- [Flutter source](../../packages/nextgen_components/lib/src/visualization.dart)
- [Galleries and launch commands](../../README.md#run)
- [Capability matrix](../catalog.md)

API declarations are generated from current source. Curated examples and behavior live in `scripts/manual_content.py`; regenerate with `python3 scripts/generate_manual.py`.
