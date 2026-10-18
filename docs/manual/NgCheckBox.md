# NgCheckBox — Checkbox

[Manual](README.md) · [Getting started](getting-started.md) · [Code examples](code-examples.md) · [Models](models.md)

## When to use it

Edit a Boolean option.

## Behavior and practical rules

The parent owns Value/value. Store ValueChanged/onChanged and pass the updated value back; Flutter needs setState or your state manager. Disabled prevents interaction. The label provides the accessible name. Keyboard focus and Space toggle the control. These components represent true/false, not a tri-state value; validate application requirements separately.

## Blazor example

```razor
<NgCheckBox Label="Notifications" @bind-Value="enabled"/>
@code { private bool enabled=true; }
```

## Flutter example

```dart
bool enabled = true;
Widget build(BuildContext context) => NgCheckBox(label: 'Notifications',
  value: enabled, onChanged: (v) => setState(() => enabled = v));
```

## Blazor parameters and events

Names are case-sensitive. `?` permits null. `EditorRequired` parameters are marked required; other values use the initializer or CLR default.

| Parameter | Type | Default / requirement | Purpose |
|---|---|---|---|
| `Label` | `string` | "" | Visible label or accessible name. |
| `Value` | `bool` | false | Current value; see state ownership and model rules above. |
| `ValueChanged` | `EventCallback<bool>` | not set | New value for the parent to store and pass back. |
| `ValueExpression` | `System.Linq.Expressions.Expression<Func<bool>>?` | not set | Expression identifying the model field; @bind-Value supplies it automatically. |
| `Disabled` | `bool` | false | Disable user interaction. |
| `AdditionalAttributes` | `Dictionary<string,object>?` | not set | Additional HTML/ARIA attributes; do not bypass component validation. |

## Flutter parameters and events

`required` marks a mandatory argument even if its type is nullable. `key` is the standard Flutter Key. The exact constructor below specifies defaults.

| Argument | Type | Purpose |
|---|---|---|
| `label` | `String` | Visible label or accessible name. |
| `value` | `bool` | Current value; see state ownership and model rules above. |
| `onChanged` | `ValueChanged<bool>?` | Store the new value using setState or your state manager. |

```dart
const NgCheckBox({
    super.key,
    required this.label,
    required this.value,
    this.onChanged,
  });
```

## Integration and troubleshooting

If the UI does not update, confirm that the parent stores callback values and passes them back. Blazor event handlers need interactive rendering; Flutter requires setState or a state manager. Submit form data only after successful validation.

Check accessible labels, empty/invalid states, disabled actions and narrow layouts. Keyboard support is not full screen-reader certification. Current visual verification targets Web in visible Chrome on Linux/iMac; native mobile platforms are a separate phase.

## Source and complete examples

- [Blazor source](../../src/NextgenComponents.Blazor/NgCheckBox.razor)
- [Flutter source](../../packages/nextgen_components/lib/src/components.dart)
- [Galleries and launch commands](../../README.md#run)
- [Capability matrix](../catalog.md)

API declarations are generated from current source. Curated examples and behavior live in `scripts/manual_content.py`; regenerate with `python3 scripts/generate_manual.py`.
