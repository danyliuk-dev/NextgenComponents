# NgDialog — Modal dialog

[Manual](README.md) · [Getting started](getting-started.md) · [Code examples](code-examples.md) · [Models](models.md)

## When to use it

Ask for a focused decision in a modal surface.

## Appearance and live example

[Try the Blazor example](http://127.0.0.1:5180/preview/NgDialog) · [Try the Flutter Web example](http://127.0.0.1:5181/?preview=NgDialog)

The documentation launcher embeds these running examples here. Choose a framework, interact with the component, and compare it with the exact code below. Use Reload example to restore the initial state. Dialogs and drawers start closed; use their Open button. Tooltips appear on hover or keyboard focus.

## Behavior and practical rules

Blazor Open/OpenChanged control visibility. Flutter uses the dialog helper shown in the example. Supply a meaningful title, content and explicit actions. Escape dismisses the dialog; opening should move focus into it and closing restore focus to the trigger. Save and Cancel have different application semantics: cancelling must not persist the draft. Nested modal workflows and a full screen-reader certification are outside this release.

## Blazor example

```razor
<NgButton OnClick="()=>open=true">Open</NgButton>
<NgDialog Title="Confirmation" @bind-Open="open"><ChildContent>Continue?</ChildContent><Actions><NgButton OnClick="()=>open=false">Close</NgButton></Actions></NgDialog>
@code { private bool open; }
```

## Flutter example

```dart
Widget build(BuildContext context) => NgButton(child: const Text('Open'),
  onPressed: () => NgDialog.show<void>(context, title: 'Confirmation',
    child: const Text('Continue?'), actions: [TextButton(
      onPressed: () => Navigator.of(context).pop(), child: const Text('Close'))]));
```

## Blazor parameters and events

Names are case-sensitive. `?` permits null. `EditorRequired` parameters are marked required; other values use the initializer or CLR default.

| Parameter | Type | Default / requirement | Purpose |
|---|---|---|---|
| `Open` | `bool` | false | See the behavior rules and model contract above. |
| `OpenChanged` | `EventCallback<bool>` | not set | See the behavior rules and model contract above. |
| `Title` | `string` | "Dialog" | Heading for the section or dialog. |
| `ChildContent` | `RenderFragment?` | not set | Razor content; for a wizard, a RenderFragment<int> receiving the active index. |
| `Actions` | `RenderFragment?` | not set | See the behavior rules and model contract above. |

## Flutter parameters and events

`required` marks a mandatory argument even if its type is nullable. `key` is the standard Flutter Key. The exact constructor below specifies defaults.

| Argument | Type | Purpose |
|---|---|---|
| `title` | `String` | Heading for the section or dialog. |
| `child` | `Widget` | See the behavior rules and model contract above. |
| `actions` | `List<Widget>` | See the behavior rules and model contract above. |

```dart
const NgDialog({
    super.key,
    required this.title,
    required this.child,
    this.actions = const [],
  });
```

## Integration and troubleshooting

If the UI does not update, confirm that the parent stores callback values and passes them back. Blazor event handlers need interactive rendering; Flutter requires setState or a state manager. Submit form data only after successful validation.

Check accessible labels, empty/invalid states, disabled actions and narrow layouts. Keyboard support is not full screen-reader certification. Current visual verification targets Web in visible Chrome on Linux/iMac; native mobile platforms are a separate phase.

## Source and complete examples

- [Blazor source](../../src/NextgenComponents.Blazor/NgDialog.razor)
- [Flutter source](../../packages/nextgen_components/lib/src/components.dart)
- [Galleries and launch commands](../../README.md#run)
- [Capability matrix](../catalog.md)

API declarations are generated from current source. Curated examples and behavior live in `scripts/manual_content.py`; regenerate with `python3 scripts/generate_manual.py`.
