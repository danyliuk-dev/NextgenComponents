# NgDatePicker — Date picker

[Manual](README.md) · [Getting started](getting-started.md) · [Code examples](code-examples.md) · [Models](models.md)

## When to use it

Select a calendar date or local wall-clock time without automatic timezone conversion.

## Appearance and live example

[Try the Blazor example](http://127.0.0.1:5180/preview/NgDatePicker) · [Try the Flutter Web example](http://127.0.0.1:5181/?preview=NgDatePicker)

The documentation launcher embeds these running examples here. Choose a framework, interact with the component, and compare it with the exact code below. Use Reload example to restore the initial state. Dialogs and drawers start closed; use their Open button. Tooltips appear on hover or keyboard focus.

## Behavior and practical rules

Input format: yyyy-MM-dd. Min/Max include boundary values. Invalid dates such as April 31 and times such as 24:00 are rejected. DisabledDate returns true for unavailable days. Blazor uses DateOnly, TimeOnly or DateTime; Flutter uses DateTime or TimeOfDay. Normalize timezones at application boundaries. Empty optional input is null. Validate required values through the form; Flutter also exposes required. See [forms and dates](../forms-and-dates.md) for supported calendar interactions and parsing limitations.

## Blazor example

```razor
<NgDatePicker Label="Date" @bind-Value="value"/>
@code { private DateOnly? value=new(2026,10,20); }
```

## Flutter example

```dart
DateTime? value = DateTime(2026,10,20,9,30);
Widget build(BuildContext context) => NgDatePicker(value: value,
  onChanged: (v) => setState(() => value = v));
```

## Blazor parameters and events

Names are case-sensitive. `?` permits null. `EditorRequired` parameters are marked required; other values use the initializer or CLR default.

| Parameter | Type | Default / requirement | Purpose |
|---|---|---|---|
| `Id` | `string` | "ng-"+Guid.NewGuid().ToString("N") | See the behavior rules and model contract above. |
| `Label` | `string` | "Date" | Visible label or accessible name. |
| `Value` | `DateOnly?` | not set | Current value; see state ownership and model rules above. |
| `ValueChanged` | `EventCallback<DateOnly?>` | not set | New value for the parent to store and pass back. |
| `ValueExpression` | `Expression<Func<DateOnly?>>?` | not set | Expression identifying the model field; @bind-Value supplies it automatically. |
| `Min` | `DateOnly?` | not set | Inclusive minimum. |
| `Max` | `DateOnly?` | not set | Inclusive maximum. |
| `DisabledDate` | `Func<DateOnly,bool>?` | not set | See the behavior rules and model contract above. |
| `Disabled` | `bool` | false | Disable user interaction. |

## Flutter parameters and events

`required` marks a mandatory argument even if its type is nullable. `key` is the standard Flutter Key. The exact constructor below specifies defaults.

| Argument | Type | Purpose |
|---|---|---|
| `label` | `String` | Visible label or accessible name. |
| `value` | `DateTime?` | Current value; see state ownership and model rules above. |
| `min` | `DateTime?` | Inclusive minimum. |
| `max` | `DateTime?` | Inclusive maximum. |
| `required` | `bool` | Require a nonempty/selected value during form validation. |
| `enabled` | `bool` | See the behavior rules and model contract above. |
| `disabledDate` | `bool Function(DateTime)?` | See the behavior rules and model contract above. |
| `onChanged` | `ValueChanged<DateTime?>?` | Store the new value using setState or your state manager. |

```dart
const NgDatePicker({
    super.key,
    this.label = 'Date',
    required this.value,
    this.onChanged,
    this.min,
    this.max,
    this.required = false,
    this.enabled = true,
    this.disabledDate,
  });
```

## Integration and troubleshooting

If the UI does not update, confirm that the parent stores callback values and passes them back. Blazor event handlers need interactive rendering; Flutter requires setState or a state manager. Submit form data only after successful validation.

Check accessible labels, empty/invalid states, disabled actions and narrow layouts. Keyboard support is not full screen-reader certification. Current visual verification targets Web in visible Chrome on Linux/iMac; native mobile platforms are a separate phase.

## Source and complete examples

- [Blazor source](../../src/NextgenComponents.Blazor/NgDatePicker.razor)
- [Flutter source](../../packages/nextgen_components/lib/src/dates.dart)
- [Galleries and launch commands](../../README.md#run)
- [Capability matrix](../catalog.md)

API declarations are generated from current source. Curated examples and behavior live in `scripts/manual_content.py`; regenerate with `python3 scripts/generate_manual.py`.
