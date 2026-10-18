# NgDrawer — Navigation drawer

[Manual](README.md) · [Getting started](getting-started.md) · [Code examples](code-examples.md) · [Models](models.md)

## When to use it

Let users switch between application sections while keeping workspace content and navigation state in the parent. Choose a modal overlay or a panel beside the content.

## Appearance and live example

[Try the Blazor example](http://127.0.0.1:5180/preview/NgDrawer) · [Try the Flutter Web example](http://127.0.0.1:5181/?preview=NgDrawer)

The documentation launcher embeds these running examples here. Choose a framework, interact with the component, and compare it with the exact code below. Use Reload example to restore the initial state. Dialogs and drawers start closed; use their Open button. Tooltips appear on hover or keyboard focus.

## Behavior and practical rules

### Own the selected section and visibility

Items uses NgOption: Value/value is the section ID, Label/label is visible text, and Disabled/disabled prevents selection. Store SelectedId/selectedId and Expanded/expanded in the parent. The built-in Open navigation button requests a visibility change. An expanded overlay requires ExpandedChanged/onExpandedChanged; the handler must store the new value and rebuild. Otherwise a modal cannot be dismissed. Selection sends the ID first, then requests closure in Overlay mode. Push mode stays open after selection.

### Overlay and Push

Overlay defaults to true: the panel covers the left side, prevents interaction with the page, traps keyboard focus and closes on Escape, Close navigation or the backdrop. Focus returns to the opener. Set Overlay/overlay to false for Push: the panel shares the content layout and stacks above it below 600 logical pixels. Flutter Push reserves 420 logical pixels of height and scrolls its destinations. Width/width defaults to 260 and accepts 200–400; overlay width is capped to the viewport minus 24 pixels.

### Keep drafts and routing in your application

The child content is application-owned. Keep form models or TextEditingController instances in the parent; mode changes can rebuild child elements. A selected ID marks the destination but does not create a URL or route. A selected ID absent from Items simply leaves every destination unselected. Empty Items displays No destinations. Flutter uses the root Navigator for its modal route and removes only that route on disposal; use the widget under MaterialApp. Blazor requires interactive rendering and native dialog support.

### Data limits and current scope

Use up to 100 flat destinations with unique IDs of 1–64 ASCII letters, digits, underscores or hyphens and nonblank labels of at most 120 UTF-16 code units. Nested destinations, mini mode, custom item templates, swipe gestures and native mobile validation are not included.

## Blazor example

```razor
<NgDrawer Label="Workspace" Items="destinations" @bind-SelectedId="selected" @bind-Expanded="expanded" Overlay="true">
    <h2>@selected</h2>
    <NgTextBox Label="Draft note" @bind-Value="note" />
</NgDrawer>
@code {
    private string? selected = "overview", note;
    private bool expanded;
    private readonly NgOption[] destinations = [new("overview", "Overview"), new("reports", "Reports"), new("settings", "Settings", true)];
}
```

## Flutter example

```dart
bool expanded = false;
String? selected = 'overview';
final note = TextEditingController();
@override void dispose() { note.dispose(); super.dispose(); }
Widget build(BuildContext context) => NgDrawer(
  label: 'Workspace', items: const [NgOption('overview', 'Overview'), NgOption('reports', 'Reports'), NgOption('settings', 'Settings', disabled: true)],
  selectedId: selected, onSelectedIdChanged: (id) => setState(() => selected = id),
  expanded: expanded, onExpandedChanged: (value) => setState(() => expanded = value),
  overlay: true,
  child: Column(children: [Text(selected ?? 'Choose a section'), NgTextBox(label: 'Draft note', controller: note)]),
);
```

## Blazor parameters and events

Names are case-sensitive. `?` permits null. `EditorRequired` parameters are marked required; other values use the initializer or CLR default.

| Parameter | Type | Default / requirement | Purpose |
|---|---|---|---|
| `Label` | `string` | "Navigation" | Visible label or accessible name. |
| `Items` | `IReadOnlyList<NgOption>` | required | Input collection. Replace it when changing records or configuration. |
| `SelectedId` | `string?` | not set | Current selected item ID; the parent owns this value. |
| `SelectedIdChanged` | `EventCallback<string>` | not set | Selected item ID for the parent to store. |
| `Expanded` | `bool` | false | Whether the drawer is open; controlled by the parent. |
| `ExpandedChanged` | `EventCallback<bool>` | not set | Requested open state; store it in the parent. |
| `Overlay` | `bool` | true | Use a modal overlay instead of a Push panel. |
| `Width` | `int` | 260 | See the behavior rules and model contract above. |
| `ChildContent` | `RenderFragment?` | not set | Razor content; for a wizard, a RenderFragment<int> receiving the active index. |

## Flutter parameters and events

`required` marks a mandatory argument even if its type is nullable. `key` is the standard Flutter Key. The exact constructor below specifies defaults.

| Argument | Type | Purpose |
|---|---|---|
| `label` | `String` | Visible label or accessible name. |
| `items` | `List<NgOption>` | Input collection. Replace it when changing records or configuration. |
| `selectedId` | `String?` | Current selected item ID; the parent owns this value. |
| `onSelectedIdChanged` | `ValueChanged<String>?` | Selected item ID for the parent to store. |
| `expanded` | `bool` | Whether the drawer is open; controlled by the parent. |
| `overlay` | `bool` | Use a modal overlay instead of a Push panel. |
| `onExpandedChanged` | `ValueChanged<bool>?` | Requested open state; store it with setState or your state manager. |
| `width` | `int` | See the behavior rules and model contract above. |
| `child` | `Widget` | See the behavior rules and model contract above. |

```dart
const NgDrawer({
    super.key,
    this.label = 'Navigation',
    required this.items,
    this.selectedId,
    this.onSelectedIdChanged,
    this.expanded = false,
    this.onExpandedChanged,
    this.overlay = true,
    this.width = 260,
    required this.child,
  });
```

## Integration and troubleshooting

If the UI does not update, confirm that the parent stores callback values and passes them back. Blazor event handlers need interactive rendering; Flutter requires setState or a state manager. Submit form data only after successful validation.

Check accessible labels, empty/invalid states, disabled actions and narrow layouts. Keyboard support is not full screen-reader certification. Current visual verification targets Web in visible Chrome on Linux/iMac; native mobile platforms are a separate phase.

## Source and complete examples

- [Blazor source](../../src/NextgenComponents.Blazor/NgDrawer.razor)
- [Flutter source](../../packages/nextgen_components/lib/src/navigation.dart)
- [Galleries and launch commands](../../README.md#run)
- [Capability matrix](../catalog.md)

API declarations are generated from current source. Curated examples and behavior live in `scripts/manual_content.py`; regenerate with `python3 scripts/generate_manual.py`.
