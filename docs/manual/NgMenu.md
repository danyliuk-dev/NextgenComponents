# NgMenu — Command menu

[Manual](README.md) · [Getting started](getting-started.md) · [Code examples](code-examples.md) · [Models](models.md)

## When to use it

Group related application commands in a horizontal toolbar or a vertical navigation area. Open nested groups to choose a leaf action.

## Appearance and live example

[Try the Blazor example](http://127.0.0.1:5180/preview/NgMenu) · [Try the Flutter Web example](http://127.0.0.1:5181/?preview=NgMenu)

The documentation launcher embeds these running examples here. Choose a framework, interact with the component, and compare it with the exact code below. Use Reload example to restore the initial state. Dialogs and drawers start closed; use their Open button. Tooltips appear on hover or keyboard focus.

## Behavior and practical rules

### Connect commands to your application

Pass a tree of NgMenuItem values. Each item has an ID, visible text, a disabled flag and children. OnInvoke/onInvoke receives only an enabled leaf ID; opening a group does not invoke an action. Store SelectedId/selectedId to mark the last selected command. Use the handler to navigate, export or open a dialog. Text is rendered as plain text; no URL is executed automatically.

### Keyboard and layout

Blazor uses a roving Tab stop, Left/Right in the horizontal bar, Up/Down in a submenu or vertical bar, Home/End, Enter/Space to activate and Escape to close a submenu and restore its opener. Down opens a top-level group; Right opens a nested group. Flutter uses Material menu keyboard handling. Vertical switches the root layout. Disabled groups block their descendants. An empty collection displays No commands.

### Data and platform limits

Use globally unique IDs of 1–64 ASCII letters, digits, underscores or hyphens, and nonblank labels of at most 120 UTF-16 code units. Trees allow at most three levels and 100 total items. Children are copied into read-only collections. Replace the root collection when changing configuration. Blazor requires an interactive render mode and browser Popover API support; Chrome Web is the verified target. Icons, arbitrary templates, context menus and automatic router integration are outside this release.

## Blazor example

```razor
<NgMenu Label="Document commands" Items="commands" SelectedId="@selected" OnInvoke="Invoke" />
<p>Last command: @selected</p>
@code {
    private string? selected;
    private readonly NgMenuItem[] commands = [
        new("file", "File", children: [
            new("new", "New document"),
            new("export", "Export", children: [new("pdf", "PDF"), new("csv", "CSV")]),
            new("delete", "Delete", disabled: true)
        ]), new("help", "Help")
    ];
    private void Invoke(string id) { selected = id; /* Dispatch the application action. */ }
}
```

## Flutter example

```dart
String? selected;
final commands = [
  NgMenuItem('file', 'File', children: [
    NgMenuItem('new', 'New document'),
    NgMenuItem('export', 'Export', children: [NgMenuItem('pdf', 'PDF'), NgMenuItem('csv', 'CSV')]),
    NgMenuItem('delete', 'Delete', disabled: true),
  ]), NgMenuItem('help', 'Help'),
];
Widget build(BuildContext context) => Column(children: [
  NgMenu(label: 'Document commands', items: commands, selectedId: selected,
    onInvoke: (id) => setState(() => selected = id)),
  Text('Last command: ${selected ?? "None"}'),
]);
```

## Blazor parameters and events

Names are case-sensitive. `?` permits null. `EditorRequired` parameters are marked required; other values use the initializer or CLR default.

| Parameter | Type | Default / requirement | Purpose |
|---|---|---|---|
| `Label` | `string` | "Commands" | Visible label or accessible name. |
| `Items` | `IReadOnlyList<NgMenuItem>` | required | Input collection. Replace it when changing records or configuration. |
| `SelectedId` | `string?` | not set | Current selected item ID; the parent owns this value. |
| `OnInvoke` | `EventCallback<string>` | not set | Enabled leaf command ID; dispatch the application action in this handler. |
| `Vertical` | `bool` | false | Use a vertical root layout; see the component keyboard and layout rules. |
| `Disabled` | `bool` | false | Disable user interaction. |

## Flutter parameters and events

`required` marks a mandatory argument even if its type is nullable. `key` is the standard Flutter Key. The exact constructor below specifies defaults.

| Argument | Type | Purpose |
|---|---|---|
| `label` | `String` | Visible label or accessible name. |
| `items` | `List<NgMenuItem>` | Input collection. Replace it when changing records or configuration. |
| `selectedId` | `String?` | Current selected item ID; the parent owns this value. |
| `onInvoke` | `ValueChanged<String>?` | Enabled leaf command ID; dispatch the application action in this handler. |
| `vertical` | `bool` | Use a vertical root layout; see the component keyboard and layout rules. |
| `disabled` | `bool` | Disable user interaction. |

```dart
const NgMenu({
    super.key,
    this.label = 'Commands',
    required this.items,
    this.selectedId,
    this.onInvoke,
    this.vertical = false,
    this.disabled = false,
  });
```

## Integration and troubleshooting

If the UI does not update, confirm that the parent stores callback values and passes them back. Blazor event handlers need interactive rendering; Flutter requires setState or a state manager. Submit form data only after successful validation.

Check accessible labels, empty/invalid states, disabled actions and narrow layouts. Keyboard support is not full screen-reader certification. Current visual verification targets Web in visible Chrome on Linux/iMac; native mobile platforms are a separate phase.

## Source and complete examples

- [Blazor source](../../src/NextgenComponents.Blazor/NgMenu.razor)
- [Flutter source](../../packages/nextgen_components/lib/src/navigation.dart)
- [Galleries and launch commands](../../README.md#run)
- [Capability matrix](../catalog.md)

API declarations are generated from current source. Curated examples and behavior live in `scripts/manual_content.py`; regenerate with `python3 scripts/generate_manual.py`.
