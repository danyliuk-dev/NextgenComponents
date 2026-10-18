# NgButton — Button

[Manual](README.md) · [Getting started](getting-started.md) · [Code examples](code-examples.md) · [Models](models.md)

## When to use it

Trigger an application action or submit a form.

## Behavior and practical rules

Use OnClick/onPressed for application actions. In Blazor Type="submit" submits the enclosing form; the default is button. In Flutter a null onPressed disables the button. Disabled actions must also be guarded by your application when starting asynchronous work. Primary uses the shared theme accent. Buttons support Tab and Enter/Space; give icon-only content an accessible name.

## Blazor example

```razor
<NgButton Primary OnClick="()=>count++">Clicked @count times</NgButton>
@code { private int count; }
```

## Flutter example

```dart
int count = 0;
Widget build(BuildContext context) => NgButton(primary: true,
  onPressed: () => setState(() => count++), child: Text('Clicked $count times'));
```

## Blazor parameters and events

Names are case-sensitive. `?` permits null. `EditorRequired` parameters are marked required; other values use the initializer or CLR default.

| Parameter | Type | Default / requirement | Purpose |
|---|---|---|---|
| `ChildContent` | `RenderFragment?` | not set | Razor content; for a wizard, a RenderFragment<int> receiving the active index. |
| `Primary` | `bool` | false | See the behavior rules and model contract above. |
| `Disabled` | `bool` | false | Disable user interaction. |
| `Type` | `string` | "button" | See the behavior rules and model contract above. |
| `OnClick` | `EventCallback<MouseEventArgs>` | not set | Application click handler. |
| `AdditionalAttributes` | `Dictionary<string,object>?` | not set | Additional HTML/ARIA attributes; do not bypass component validation. |

## Flutter parameters and events

`required` marks a mandatory argument even if its type is nullable. `key` is the standard Flutter Key. The exact constructor below specifies defaults.

| Argument | Type | Purpose |
|---|---|---|
| `child` | `Widget` | See the behavior rules and model contract above. |
| `onPressed` | `VoidCallback?` | Application action; null disables the button. |
| `primary` | `bool` | See the behavior rules and model contract above. |

```dart
const NgButton({
    super.key,
    required this.child,
    this.onPressed,
    this.primary = false,
  });
```

## Integration and troubleshooting

If the UI does not update, confirm that the parent stores callback values and passes them back. Blazor event handlers need interactive rendering; Flutter requires setState or a state manager. Submit form data only after successful validation.

Check accessible labels, empty/invalid states, disabled actions and narrow layouts. Keyboard support is not full screen-reader certification. Current visual verification targets Web in visible Chrome on Linux/iMac; native mobile platforms are a separate phase.

## Source and complete examples

- [Blazor source](../../src/NextgenComponents.Blazor/NgButton.razor)
- [Flutter source](../../packages/nextgen_components/lib/src/components.dart)
- [Galleries and launch commands](../../README.md#run)
- [Capability matrix](../catalog.md)

API declarations are generated from current source. Curated examples and behavior live in `scripts/manual_content.py`; regenerate with `python3 scripts/generate_manual.py`.
