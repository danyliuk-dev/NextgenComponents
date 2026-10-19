# NgDateRangePicker — Date range

[Manual](README.md) · [Getting started](getting-started.md) · [Code examples](code-examples.md) · [Models](models.md)

## When to use it

Edit a linked start and end date.

## Appearance and live example

[Try the Blazor example](http://127.0.0.1:5180/preview/NgDateRangePicker) · [Try the Flutter Web example](http://127.0.0.1:5181/?preview=NgDateRangePicker)

The documentation launcher embeds these running examples here. Choose a framework, interact with the component, and compare it with the exact code below. Use Reload example to restore the initial state. Dialogs and drawers start closed; use their Open button. Tooltips appear on hover or keyboard focus.

## Behavior and practical rules

NgDateRange contains nullable Start/End (Blazor DateOnly, Flutter DateTime). An end before the start is invalid. Min/Max constrain both endpoints. Callbacks replace the whole range. A partially filled draft may exist; the form determines whether it is valid for submission. Do not save the last valid model while an invalid draft is visible: submit through NgForm. This is a calendar-date range, not a timezone-aware interval.

ReadOnly/readOnly prevents user changes. Disabled/enabled also disables interaction. Date editors keep readable, focusable text in read-only mode and disable their picker action; Calendar blocks selection and navigation (Flutter also excludes keyboard focus). Bounds must be ordered; invalid configuration throws. Values are Gregorian calendar dates; date text is ISO yyyy-MM-dd, independent of Blazor's current culture. Empty optional input clears to null.

DisabledDate/disabledDate applies to typing and calendar selection. In a range it checks both endpoints, not every date between them. Partial and reversed ranges fail form validation. Flutter range validation reads the current parent value after replacement. Applications own validation of external single-date values. Replace the form key to discard an invalid draft when the model value is unchanged.

Flutter calendars use Material locale/week-start and default bounds 1900–2100; Blazor uses Culture/FirstDayOfWeek and DateOnly bounds. Supply explicit bounds for matching domains. Calendar selection is single-date only. Shared range highlighting, multiple calendar views, cell templates, week numbers, segmented/custom-format input and complete keyboard/screen-reader parity remain open. Flutter popup results are ignored after a parent rebuild, edit or disposal.

## Blazor example

```razor
<NgDateRangePicker Label="Period" DisabledDate="d => d.DayOfWeek == DayOfWeek.Sunday" @bind-Value="range"/>
@code { private NgDateRange? range=new(new(2026,10,20),new(2026,10,23)); }
```

## Flutter example

```dart
NgDateRange? range = NgDateRange(DateTime(2026,10,20), DateTime(2026,10,23));
Widget build(BuildContext context) => NgDateRangePicker(label: 'Period', value: range,
  disabledDate: (d) => d.weekday == DateTime.sunday, required: true, onChanged: (v) => setState(() => range = v));
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
| `ReadOnly` | `bool` | false | Prevent changes while retaining supported viewing actions. |
| `DisabledDate` | `Func<DateOnly,bool>?` | not set | See the behavior rules and model contract above. |
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
| `readOnly` | `bool` | Prevent changes while retaining supported viewing actions. |
| `disabledDate` | `bool Function(DateTime)?` | See the behavior rules and model contract above. |
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
    this.readOnly = false,
    this.disabledDate,
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
