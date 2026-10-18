# NgNotification — Notification

[Manual](README.md) · [Getting started](getting-started.md) · [Code examples](code-examples.md) · [Models](models.md)

## When to use it

Show an inline application status message.

## Appearance and live example

[Try the Blazor example](http://127.0.0.1:5180/preview/NgNotification) · [Try the Flutter Web example](http://127.0.0.1:5181/?preview=NgNotification)

The documentation launcher embeds these running examples here. Choose a framework, interact with the component, and compare it with the exact code below. Use Reload example to restore the initial state. Dialogs and drawers start closed; use their Open button. Tooltips appear on hover or keyboard focus.

## Behavior and practical rules

Message is plain text. Tone controls semantic color; do not communicate meaning through color alone. Dismissal invokes the supplied callback; update Visible/visible in the parent. This is not a timed global toast queue. Keep critical validation errors next to their fields and avoid placing confidential exception details in user-facing text.

## Blazor example

```razor
<NgNotification @bind-Visible="visible" Tone="success">Saved</NgNotification>
@code { private bool visible=true; }
```

## Flutter example

```dart
bool visible = true;
Widget build(BuildContext context) => visible ? NgNotification(message: 'Saved',
  onDismiss: () => setState(() => visible = false)) : const SizedBox.shrink();
```

## Blazor parameters and events

Names are case-sensitive. `?` permits null. `EditorRequired` parameters are marked required; other values use the initializer or CLR default.

| Parameter | Type | Default / requirement | Purpose |
|---|---|---|---|
| `Visible` | `bool` | true | See the behavior rules and model contract above. |
| `VisibleChanged` | `EventCallback<bool>` | not set | See the behavior rules and model contract above. |
| `Tone` | `string` | "success" | See the behavior rules and model contract above. |
| `ChildContent` | `RenderFragment?` | not set | Razor content; for a wizard, a RenderFragment<int> receiving the active index. |

## Flutter parameters and events

`required` marks a mandatory argument even if its type is nullable. `key` is the standard Flutter Key. The exact constructor below specifies defaults.

| Argument | Type | Purpose |
|---|---|---|
| `message` | `String` | See the behavior rules and model contract above. |
| `onDismiss` | `VoidCallback?` | See the behavior rules and model contract above. |
| `error` | `bool` | See the behavior rules and model contract above. |

```dart
const NgNotification({
    super.key,
    required this.message,
    this.onDismiss,
    this.error = false,
  });
```

## Integration and troubleshooting

If the UI does not update, confirm that the parent stores callback values and passes them back. Blazor event handlers need interactive rendering; Flutter requires setState or a state manager. Submit form data only after successful validation.

Check accessible labels, empty/invalid states, disabled actions and narrow layouts. Keyboard support is not full screen-reader certification. Current visual verification targets Web in visible Chrome on Linux/iMac; native mobile platforms are a separate phase.

## Source and complete examples

- [Blazor source](../../src/NextgenComponents.Blazor/NgNotification.razor)
- [Flutter source](../../packages/nextgen_components/lib/src/components.dart)
- [Galleries and launch commands](../../README.md#run)
- [Capability matrix](../catalog.md)

API declarations are generated from current source. Curated examples and behavior live in `scripts/manual_content.py`; regenerate with `python3 scripts/generate_manual.py`.
