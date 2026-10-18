# NgToggleButton — Toggle button

[Manual](README.md) · [Getting started](getting-started.md) · [Code examples](code-examples.md) · [Models](models.md)

## When to use it

Switch a single setting on or off while keeping the action label visible. Examples include a preview border, a pinned item or a formatting option.

## Behavior and practical rules

### Bind the current state

Value/value is a Boolean owned by the application. Blazor supports @bind-Value; Flutter uses value with onChanged and setState. Each activation requests the opposite value. The component does not save data or change application state independently. Keep the label stable, such as Show border, so its pressed state clearly explains whether the setting is enabled.

### Keyboard and disabled state

Tab focuses the button. Enter or Space activates it. The control exposes its pressed/checked state to accessibility APIs and keeps focus after a change. Disabled/disabled blocks activation. A missing ValueChanged/onChanged callback also disables the control, while external value changes remain visible. This is a button, not a form submission control.

### Limits and composition

Use a nonblank plain-text label up to 120 UTF-16 code units. Icon-only content, arbitrary templates and separate click events are outside this release. Use NgButtonGroup to coordinate several toggles; use NgSwitch for a switch-shaped control. Web is the verified target; native mobile validation remains separate.

## Blazor example

```razor
<NgToggleButton Label="Show border" @bind-Value="showBorder" />
<p>Border: @(showBorder ? "On" : "Off")</p>
@code { private bool showBorder; }
```

## Flutter example

```dart
bool showBorder = false;
Widget build(BuildContext context) => Column(children: [
  NgToggleButton(label: 'Show border', value: showBorder,
    onChanged: (value) => setState(() => showBorder = value)),
  Text('Border: ${showBorder ? "On" : "Off"}'),
]);
```

## Blazor parameters and events

Names are case-sensitive. `?` permits null. `EditorRequired` parameters are marked required; other values use the initializer or CLR default.

| Parameter | Type | Default / requirement | Purpose |
|---|---|---|---|
| `Label` | `string` | required | Visible label or accessible name. |
| `Value` | `bool` | false | Current value; see state ownership and model rules above. |
| `ValueChanged` | `EventCallback<bool>` | not set | New value for the parent to store and pass back. |
| `Disabled` | `bool` | false | Disable user interaction. |

## Flutter parameters and events

`required` marks a mandatory argument even if its type is nullable. `key` is the standard Flutter Key. The exact constructor below specifies defaults.

| Argument | Type | Purpose |
|---|---|---|
| `label` | `String` | Visible label or accessible name. |
| `value` | `bool` | Current value; see state ownership and model rules above. |
| `disabled` | `bool` | Disable user interaction. |
| `onChanged` | `ValueChanged<bool>?` | Store the new value using setState or your state manager. |

```dart
const NgToggleButton({
    super.key,
    required this.label,
    this.value = false,
    this.onChanged,
    this.disabled = false,
  });
```

## Integration and troubleshooting

If the UI does not update, confirm that the parent stores callback values and passes them back. Blazor event handlers need interactive rendering; Flutter requires setState or a state manager. Submit form data only after successful validation.

Check accessible labels, empty/invalid states, disabled actions and narrow layouts. Keyboard support is not full screen-reader certification. Current visual verification targets Web in visible Chrome on Linux/iMac; native mobile platforms are a separate phase.

## Source and complete examples

- [Blazor source](../../src/NextgenComponents.Blazor/NgToggleButton.razor)
- [Flutter source](../../packages/nextgen_components/lib/src/selection.dart)
- [Galleries and launch commands](../../README.md#run)
- [Capability matrix](../catalog.md)

API declarations are generated from current source. Curated examples and behavior live in `scripts/manual_content.py`; regenerate with `python3 scripts/generate_manual.py`.
