# NgNumericTextBox — Numeric input

[Manual](README.md) · [Getting started](getting-started.md) · [Code examples](code-examples.md) · [Models](models.md)

## When to use it

Edit a nullable number with range validation.

## Behavior and practical rules

Min/Max are inclusive. Invalid text must not silently submit the last valid number: submit through NgForm so the displayed draft is validated. Empty optional input is null. Blazor uses its declared numeric type and InputBase expression binding; Flutter uses double?. Keep storage precision and business rounding in the application. Do not treat a numeric input as a currency or timezone service.

## Blazor example

```razor
<NgNumericTextBox Label="Quantity" Min="0" Max="100" Step="1" @bind-Value="quantity"/>
@code { private decimal? quantity=5; }
```

## Flutter example

```dart
double? quantity = 5;
Widget build(BuildContext context) => NgNumericTextBox(label: 'Quantity',
  value: quantity, min: 0, max: 100, required: true,
  onChanged: (v) => setState(() => quantity = v));
```

## Blazor parameters and events

Names are case-sensitive. `?` permits null. `EditorRequired` parameters are marked required; other values use the initializer or CLR default.

| Parameter | Type | Default / requirement | Purpose |
|---|---|---|---|
| `Id` | `string` | "ng-" + Guid.NewGuid().ToString("N") | See the behavior rules and model contract above. |
| `Label` | `string` | "" | Visible label or accessible name. |
| `Value` | `decimal?` | not set | Current value; see state ownership and model rules above. |
| `ValueChanged` | `EventCallback<decimal?>` | not set | New value for the parent to store and pass back. |
| `ValueExpression` | `System.Linq.Expressions.Expression<Func<decimal?>>?` | not set | Expression identifying the model field; @bind-Value supplies it automatically. |
| `Min` | `decimal?` | not set | Inclusive minimum. |
| `Max` | `decimal?` | not set | Inclusive maximum. |
| `Step` | `decimal` | 1 | See the behavior rules and model contract above. |
| `Disabled` | `bool` | false | Disable user interaction. |
| `AdditionalAttributes` | `Dictionary<string,object>?` | not set | Additional HTML/ARIA attributes; do not bypass component validation. |

## Flutter parameters and events

`required` marks a mandatory argument even if its type is nullable. `key` is the standard Flutter Key. The exact constructor below specifies defaults.

| Argument | Type | Purpose |
|---|---|---|
| `label` | `String` | Visible label or accessible name. |
| `value` | `double?` | Current value; see state ownership and model rules above. |
| `min` | `double?` | Inclusive minimum. |
| `max` | `double?` | Inclusive maximum. |
| `onChanged` | `ValueChanged<double?>?` | Store the new value using setState or your state manager. |
| `enabled` | `bool` | See the behavior rules and model contract above. |
| `required` | `bool` | Require a nonempty/selected value during form validation. |

```dart
const NgNumericTextBox({
    super.key,
    required this.label,
    required this.value,
    this.min,
    this.max,
    this.onChanged,
    this.enabled = true,
    this.required = false,
  });
```

## Integration and troubleshooting

If the UI does not update, confirm that the parent stores callback values and passes them back. Blazor event handlers need interactive rendering; Flutter requires setState or a state manager. Submit form data only after successful validation.

Check accessible labels, empty/invalid states, disabled actions and narrow layouts. Keyboard support is not full screen-reader certification. Current visual verification targets Web in visible Chrome on Linux/iMac; native mobile platforms are a separate phase.

## Source and complete examples

- [Blazor source](../../src/NextgenComponents.Blazor/NgNumericTextBox.razor)
- [Flutter source](../../packages/nextgen_components/lib/src/components.dart)
- [Galleries and launch commands](../../README.md#run)
- [Capability matrix](../catalog.md)

API declarations are generated from current source. Curated examples and behavior live in `scripts/manual_content.py`; regenerate with `python3 scripts/generate_manual.py`.
