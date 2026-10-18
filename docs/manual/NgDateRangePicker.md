# NgDateRangePicker — Date range

[Manual](README.md) · [Getting started](getting-started.md) · [Code examples](code-examples.md) · [Models](models.md)

## When to use it

Edit a linked start and end date.

## Appearance and live example

[Try the Blazor example](http://127.0.0.1:5180/preview/NgDateRangePicker) · [Try the Flutter Web example](http://127.0.0.1:5181/?preview=NgDateRangePicker)

The documentation launcher embeds these running examples here. Choose a framework, interact with the component, and compare it with the exact code below. Use Reload example to restore the initial state. Dialogs and drawers start closed; use their Open button. Tooltips appear on hover or keyboard focus.

## Behavior and practical rules

NgDateRange contains nullable Start/End (Blazor DateOnly, Flutter DateTime). An end before the start is invalid. Min/Max constrain both endpoints. Callbacks replace the whole range. A partially filled draft may exist; the form determines whether it is valid for submission. Do not save the last valid model while an invalid draft is visible: submit through NgForm. This is a calendar-date range, not a timezone-aware interval.

## Blazor example

```razor
<NgDateRangePicker Label="Period" @bind-Value="range"/>
@code { private NgDateRange? range=new(new(2026,10,20),new(2026,10,23)); }
```

## Flutter example

```dart
NgDateRange? range = NgDateRange(DateTime(2026,10,20), DateTime(2026,10,23));
Widget build(BuildContext context) => NgDateRangePicker(label: 'Period', value: range,
  required: true, onChanged: (v) => setState(() => range = v));
```

## Blazor parameters and events

Names are case-sensitive. `?` permits null. `EditorRequired` parameters are marked required; other values use the initializer or CLR default.

| Parameter | Type | Default / requirement | Purpose |
|---|---|---|---|
| `Label` | `string` | "Date range" | Visible label or accessible name. |
| `Value` | `NgDateRange?` | not set | Current value; see state ownership and model rules above. |
| `ValueChanged` | `EventCallback<NgDateRange?>` | not set | New value for the parent to store and pass back. |
| `ValueExpression` | `Expression<Func<NgDateRange?>>?` | not set | Expression identifying the model field; @bind-Value supplies it automatically. |
| `Min` | `DateOnly?` | not set | Inclusive minimum. |
| `Max` | `DateOnly?` | not set | Inclusive maximum. |
| `Disabled` | `bool` | false | Disable user interaction. |

## Flutter parameters and events

`required` marks a mandatory argument even if its type is nullable. `key` is the standard Flutter Key. The exact constructor below specifies defaults.

| Argument | Type | Purpose |
|---|---|---|
| `label` | `String` | Visible label or accessible name. |
| `value` | `NgDateRange?` | Current value; see state ownership and model rules above. |
| `min` | `DateTime?` | Inclusive minimum. |
| `max` | `DateTime?` | Inclusive maximum. |
| `enabled` | `bool` | See the behavior rules and model contract above. |
| `required` | `bool` | Require a nonempty/selected value during form validation. |
| `onChanged` | `ValueChanged<NgDateRange?>?` | Store the new value using setState or your state manager. |

```dart
const NgDateRangePicker({
    super.key,
    this.label = 'Date range',
    required this.value,
    this.onChanged,
    this.min,
    this.max,
    this.enabled = true,
    this.required = false,
  });
```

## Integration and troubleshooting

If the UI does not update, confirm that the parent stores callback values and passes them back. Blazor event handlers need interactive rendering; Flutter requires setState or a state manager. Submit form data only after successful validation.

Check accessible labels, empty/invalid states, disabled actions and narrow layouts. Keyboard support is not full screen-reader certification. Current visual verification targets Web in visible Chrome on Linux/iMac; native mobile platforms are a separate phase.

## Source and complete examples

- [Blazor source](../../src/NextgenComponents.Blazor/NgDateRangePicker.razor)
- [Flutter source](../../packages/nextgen_components/lib/src/dates.dart)
- [Galleries and launch commands](../../README.md#run)
- [Capability matrix](../catalog.md)

API declarations are generated from current source. Curated examples and behavior live in `scripts/manual_content.py`; regenerate with `python3 scripts/generate_manual.py`.
