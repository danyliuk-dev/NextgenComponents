# NgTimePicker — Time picker

[Manual](README.md) · [Getting started](getting-started.md) · [Code examples](code-examples.md) · [Models](models.md)

## When to use it

Select a calendar date or local wall-clock time without automatic timezone conversion.

## Behavior and practical rules

Input format: HH:mm. Min/Max include boundary values. Invalid dates such as April 31 and times such as 24:00 are rejected. Blazor uses DateOnly, TimeOnly or DateTime; Flutter uses DateTime or TimeOfDay. Normalize timezones at application boundaries. Empty optional input is null. Validate required values through the form; Flutter also exposes required. See [forms and dates](../forms-and-dates.md) for supported calendar interactions and parsing limitations.

## Blazor example

```razor
<NgTimePicker Label="Date" @bind-Value="value"/>
@code { private TimeOnly? value=new(9,30); }
```

## Flutter example

```dart
TimeOfDay? value = const TimeOfDay(hour: 9, minute: 30);
Widget build(BuildContext context) => NgTimePicker(value: value,
  onChanged: (v) => setState(() => value = v));
```

## Blazor parameters and events

Names are case-sensitive. `?` permits null. `EditorRequired` parameters are marked required; other values use the initializer or CLR default.

| Parameter | Type | Default / requirement | Purpose |
|---|---|---|---|
| `Id` | `string` | "ng-"+Guid.NewGuid().ToString("N") | See the behavior rules and model contract above. |
| `Label` | `string` | "Time" | Visible label or accessible name. |
| `Min` | `TimeOnly?` | not set | Inclusive minimum. |
| `Max` | `TimeOnly?` | not set | Inclusive maximum. |
| `Disabled` | `bool` | false | Disable user interaction. |
| `Value` | `TimeOnly?` | model value | Current field value. |
| `ValueChanged` | `EventCallback<TimeOnly?>` | not set | Value change callback. |
| `ValueExpression` | `Expression<Func<TimeOnly?>>` | required | Supplied by @bind-Value; pass explicitly with manual binding. |
| `AdditionalAttributes` | HTML attribute dictionary | null | Extra HTML/ARIA attributes. |

## Flutter parameters and events

`required` marks a mandatory argument even if its type is nullable. `key` is the standard Flutter Key. The exact constructor below specifies defaults.

| Argument | Type | Purpose |
|---|---|---|
| `label` | `String` | Visible label or accessible name. |
| `value` | `TimeOfDay?` | Current value; see state ownership and model rules above. |
| `min` | `TimeOfDay?` | Inclusive minimum. |
| `max` | `TimeOfDay?` | Inclusive maximum. |
| `required` | `bool` | Require a nonempty/selected value during form validation. |
| `enabled` | `bool` | See the behavior rules and model contract above. |
| `onChanged` | `ValueChanged<TimeOfDay?>?` | Store the new value using setState or your state manager. |

```dart
const NgTimePicker({
    super.key,
    this.label = 'Time',
    required this.value,
    this.onChanged,
    this.min,
    this.max,
    this.required = false,
    this.enabled = true,
  });
```

## Integration and troubleshooting

If the UI does not update, confirm that the parent stores callback values and passes them back. Blazor event handlers need interactive rendering; Flutter requires setState or a state manager. Submit form data only after successful validation.

Check accessible labels, empty/invalid states, disabled actions and narrow layouts. Keyboard support is not full screen-reader certification. Current visual verification targets Web in visible Chrome on Linux/iMac; native mobile platforms are a separate phase.

## Source and complete examples

- [Blazor source](../../src/NextgenComponents.Blazor/NgTimePicker.razor)
- [Flutter source](../../packages/nextgen_components/lib/src/dates.dart)
- [Galleries and launch commands](../../README.md#run)
- [Capability matrix](../catalog.md)

API declarations are generated from current source. Curated examples and behavior live in `scripts/manual_content.py`; regenerate with `python3 scripts/generate_manual.py`.
